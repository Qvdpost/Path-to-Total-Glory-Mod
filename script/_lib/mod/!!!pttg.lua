local pttg = {
    config = {
        seed = 34,
        random_seed = true,
        difficulty = "regular",
        logging_enabled = true,
        map_height = 12,
        map_width = 7,
        map_density = 4
    },
    
    state = {
        maps = {},
        cursor = nil,
        cur_phase = "",
        gen_seed = false,
        pending_reward = false,
        army_cqi = false,
        event_room_chances = { monster = 10, shop = 3, treasure = 2 },
        shop_sizes = {
            merchandise = 1,
            units = 5
        },
        shop_chances = {
            50,
            10,
            5,
            2
        },
        active_shop_items = {},
        recruitable_mercs = {},
        recruit_chances = { 90, 99, 100 },
        elite_recruit_chances = { 50, 90, 100 },
        boss_recruit_chances = { -5, -5, 100 },
        recruit_rarity_offset = -5,
        recruit_count = 5,
        excluded_items = {},
        excluded_shop_items = {},
        replenishment_factor = 0.3,
        excluded_event_pool = {},
        alignment = 0,
        glory_reward_modifier = 1,
        glory_recruit_modifier = 1,
        excluded_effect_pool = {}
    },
    
    persistent_keys = {
        cursor = true,
        cur_phase = true,
        pending_reward = true,
        army_cqi = true,
        event_room_chances = true,
        shop_sizes = true,
        shop_chances = true,
        active_shop_items = true,
        recruitable_mercs = true,
        recruit_rarity_offset = true,
        recruit_count = true,
        excluded_items = true,
        excluded_shop_items = true,
        replenishment_factor = true,
        excluded_event_pool = true,
        alignment = true,
        glory_reward_modifier = true,
        glory_recruit_modifier = true,
        excluded_effect_pool = true
    },

    difficulties = {['easy'] = 1, ['regular'] = 2, ['hard'] = 3},

    difficulty_modifiers = {
        encounter_size = {2, 4, 6}
    }
};


-- UTILS --
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true;
        end
    end
    return false;
end

-- GENERIC --
function pttg:log(str)
    if pttg:get_config("logging_enabled") then
        out("[Quinner][pttg]:" .. str);
    end
end

function pttg:gls(localised_string_key)
    return common.get_localised_string("pttg_" .. localised_string_key);
end

function pttg:get_config(config_key)
    if get_mct then
        local mct = get_mct();

        if mct ~= nil then
            local mod_cfg = mct:get_mod_by_key("tot_glory");
            if mod_cfg:get_option_by_key(config_key) then
                return mod_cfg:get_option_by_key(config_key):get_finalized_setting();
            end
        end
    end

    return self.config[config_key];
end

function pttg:set_config(config_key, config_value)
    if get_mct then
        local mct = get_mct();

        if mct ~= nil then
            local mod_cfg = mct:get_mod_by_key("tot_glory");
            if mod_cfg:get_option_by_key(config_key) then
                return mod_cfg:get_option_by_key(config_key):set_selected_setting(config_value, false);
            end
        end
    end

    return self.config[config_key];
end

function pttg:get_state(state_key)
    if not self.state[state_key] then
        pttg:log('[get_state]' .. state_key .. ' does not exist.')
        return nil
    end

    pttg:log('[get_state]' .. 'Get state ' .. state_key .. ':' .. tostring(self.state[state_key]))
    return self.state[state_key]
end

function pttg:set_state(key, value)
    if self.state[key] == nil then
        pttg:log('[set_state]' .. 'No such state key: ' .. tostring(key))
        return nil
    end

    pttg:log("[set_state] Key persistance: " .. tostring(self.persistent_keys[key]))
    if self.persistent_keys[key] then
        pttg:save_state(key, value)
    end

    self.state[key] = value
    pttg:log('[set_state]' .. 'State set ' .. key .. ':' .. tostring(self.state[key]))
    return value
end

function pttg:add_persistent_state(key, value)
    self.persistent_keys[key] = true
    self:set_state(key, value)
end

function pttg:set_cursor(value)
    cm:set_saved_value('pttg_cursor', value)
    self.state['cursor'] = value
end

function pttg:get_cursor()
    return self.state['cursor']
end

function pttg:save_state(key, value)
    cm:set_saved_value("pttg_" .. key, value)
end

function pttg:load_state()
    pttg:log('[load_state] Loading state variables: ')

    for key, _ in pairs(self.persistent_keys) do
        local var = cm:get_saved_value("pttg_" .. key)
        if var then
            self.state[key] = var
            pttg:log(string.format('[load_state] Loaded: %s| %s', key, tostring(var)))
        end
    end
end

function pttg:set_seed(val)
    pttg:log('[s_seed] Set: ' .. 'gen_seed|' .. tostring(val))
    self.state['gen_seed'] = val
    self:save_state('gen_seed', val)
end

function pttg:load_seed()
    local var = cm:get_saved_value('pttg_gen_seed')
    if var then
        self.state['gen_seed'] = var
        pttg:log('[load_seed] Loaded: ' .. 'gen_seed|' .. tostring(var))
    end
end

function pttg:get_difficulty_mod(key)
    local index = self.difficulties[self:get_config('difficulty')]
    return self.difficulty_modifiers[key][index]
end

function math:huge(number)
    return number + 1
end

core:add_static_object("pttg", pttg);
