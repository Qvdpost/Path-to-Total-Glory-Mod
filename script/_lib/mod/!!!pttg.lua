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
            merchandise = 5,
            units = 5
        },
        shop_chances = {
            50,
            83,
            100,
            100
        },
        active_shop_items = {},
        recruitable_mercs = {},
        recruit_chances = {
            { 100, 100, 100 }, -- act one, only core units
            { 75, 100, 100 }, -- only core & special
            { 50, 95, 100 },
        },
        elite_recruit_chances = {
            { 50, 100, 100 },
            { 50, 95, 100 },
            { 40, 85, 100 },
        },
        boss_recruit_chances = { -101, -100, 100 },
        recruit_rarity_offset = -5,
        recruit_count = 5,
        excluded_items = {},
        excluded_shop_items = {},
        shop_special_recruit = 8,
        replenishment_factor = 0.4,
        captive_replenishment_factor = 0.2,
        excluded_event_pool = {},
        alignment = 0,
        glory_reward_modifier = 1,
        glory_recruit_modifier = 1,
        excluded_effect_pool = {},
        excluded_army_effect_pool = {},
        glory_recruit_default = {2, 3, 4},
        glory_recruit_elite = {3, 4, 4},
        glory_recruit_boss = 4,
        excluded_army_templates = {},
        add_warband_upgrade_glory = {2, 3, 3},
        tech_completion_rate = 2,
        completed_techs = {},
        wom_efficiency = 0.25,
        faction_resource_factor = 1,
        battle_ongoing = false,
        general_fm_cqi = false,
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
        captive_replenishment_factor = true,
        excluded_event_pool = true,
        alignment = true,
        glory_reward_modifier = true,
        glory_recruit_modifier = true,
        excluded_effect_pool = true,
        excluded_army_effect_pool = true,
        excluded_army_templates = true,
        add_warband_upgrade_glory = true,
        tech_completion_rate = true,
        completed_techs = true,
        wom_efficiency = true,
        faction_resource_factor = true,
        battle_ongoing = true,
        shop_special_recruit = true,
        general_fm_cqi = true,
    },

    difficulties = {['easy'] = 1, ['regular'] = 2, ['hard'] = 3, ['legendary'] = 4},

    difficulty_modifiers = {
        encounter_size = {2, 4, 6},
        random_start_recruit_glory = {16, 14, 12},
        random_start_recruit_merc_count = {25, 20, 20},
        random_start_chances = {{ 70, 200, 100 }, { 90, 200, 100 }, { 90, 200, 100 }},
        ai_army_power_mod = { -1, 0, 1}
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

function math:huge(number)
    return number + 1
end

function string.pttg_split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
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
    if self.state[state_key] == nil then
        pttg:log('[get_state]' .. state_key .. ' does not exist.')
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

function pttg:get_difficulty_index()
    local difficulty = self:get_config('difficulty')
    self:log("Getting diffuclty index for:"..tostring(difficulty))
    return self.difficulties[difficulty]
end

function pttg:get_difficulty_mod(key)
    local index = math.min(3, self:get_difficulty_index())
    return self.difficulty_modifiers[key][index]
end

core:add_static_object("pttg", pttg);
