local pttg = {};
local config = {
    seed = 34,
    random_seed = true,
    difficulty = "regular",
    logging_enabled = true,
    map_height = 12,
    map_width = 7,
    map_density = 4
}

local state = {
    maps = {},
    cursor = nil,
    cur_phase = "",
    gen_seed = false,
    pending_reward = false,
    army_cqi = false,
    event_room_chances = { monster = 10, shop = 3, treasure = 2 },
    shop_sizes = { 
        merchandise = 6,
        units = 5
    },
    shop_chances = {
        50,
        10,
        5,
        2
    },
    active_shop_items = {},
    recruit_weights = { ["core"] = 40, ["special"] = 5, ["rare"] = 1 },
    recruitable_mercs = {},
    excluded_items = {},
    replenishment_factor = 0.3
}

local persistent_keys = {
    cursor = true,
    cur_phase = true,
    gen_seed = true,
    pending_reward = true,
    army_cqi = true,
    event_room_chances = true,
    shop_sizes = true,
    shop_chances = true,
    active_shop_items = true,
    recruit_weights = true,
    recruitable_mercs = true,
    excluded_items = true,
    replenishment_factor = true
}

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

  return config[config_key];
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

  return config[config_key];
end

function pttg:get_state(state_key)
    
    if not state[state_key] then
        pttg:log('[get_state]'..state_key..' does not exist.')
        return nil
    end
    
    pttg:log('[get_state]'..'Get state '..state_key..':' .. tostring(state[state_key]))
    return state[state_key]
end

function pttg:set_state(key, value)
    if state[key] == nil then
        pttg:log('[set_state]'..'No such state key: '..tostring(key))
        return nil
    end
    
    pttg:log("[set_state] Key persistance: " .. tostring(persistent_keys[key]))
    if persistent_keys[key] then
        cm:set_saved_value(key, value)
    end
      
    state[key] = value
    pttg:log('[set_state]'..'State set '..key..':' .. tostring(state[key]))
    return value
end

function pttg:set_cursor(value)
    cm:set_saved_value('pttg_cursor', value)
    state['cursor'] = value
end

function pttg:get_cursor()
    return state['cursor']
end

function pttg:load_state()
    pttg:log('[load_state] Loading state')
    
    local cursor = cm:get_saved_value('pttg_cursor')
    if cursor then
        state['cursor'] = pttg:get_state('maps')[cursor.z][cursor.y][cursor.x]
        pttg:log('[load_state] Loaded: '..'cursor|'..pttg:get_cursor():repr())
    end
    local cur_phase = cm:get_saved_value('cur_phase')
    if cur_phase then
        state['cur_phase'] = cur_phase
        pttg:log('[load_state] Loaded: '..'cur_phase|'..cur_phase)
    end
    local var = cm:get_saved_value('pending_reward')
    if var then
        state['pending_reward'] = var
        pttg:log('[load_state] Loaded: '..'pending_reward|'.. tostring(var))
    end
    local var = cm:get_saved_value('army_cqi')
    if var then
        state['army_cqi'] = var
        pttg:log('[load_state] Loaded: '..'army_cqi|'.. tostring(var))
    end
    local var = cm:get_saved_value('event_room_chances')
    if var then
        state['event_room_chances'] = var
        pttg:log('[load_state] Loaded: '..'event_room_chances|'.. tostring(var))
    end
    local var = cm:get_saved_value('shop_sizes')
    if var then
        state['shop_sizes'] = var
        pttg:log('[load_state] Loaded: '..'shop_sizes|'.. tostring(var))
    end
    local var = cm:get_saved_value('active_shop_items')
    if var then
        state['active_shop_items'] = var
        pttg:log('[load_state] Loaded: '..'active_shop_items|'.. tostring(var))
    end
    local var = cm:get_saved_value('shop_chances')
    if var then
        state['shop_chances'] = var
        pttg:log('[load_state] Loaded: '..'shop_chances|'.. tostring(var))
    end
    local var = cm:get_saved_value('recruit_weights')
    if var then
        state['recruit_weights'] = var
        pttg:log('[load_state] Loaded: '..'recruit_weights|'.. tostring(var))
    end
    local var = cm:get_saved_value('recruitable_mercs')
    if var then
        state['recruitable_mercs'] = var
        pttg:log('[load_state] Loaded: '..'recruitable_mercs|'.. tostring(var))
    end
    local var = cm:get_saved_value('excluded_items')
    if var then
        state['excluded_items'] = var
        pttg:log('[load_state] Loaded: '..'excluded_items|'.. tostring(var))
    end
    local var = cm:get_saved_value('replenishment_factor')
    if var then
        state['replenishment_factor'] = var
        pttg:log('[load_state] Loaded: '..'replenishment_factor|'.. tostring(var))
    end
end

function pttg:load_seed()
    local var = cm:get_saved_value('gen_seed')
    if var then
        state['gen_seed'] = var
        pttg:log('[load_seed] Loaded: '..'gen_seed|'.. tostring(var))
    end
end

core:add_static_object("pttg", pttg);
