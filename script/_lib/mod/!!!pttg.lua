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
  recruit_weights = { ["core"] = 50, ["special"] = 5, ["rare"] = 1 },
  recruitable_mercs = {},
  recruit_chances = { 60, 87, 100 },
  elite_recruit_chances = { 50, 90, 100 },
  boss_recruit_chances = { -5, -5, 100 },
  recruit_rarity_offset = -5,
  recruit_count = 3,
  excluded_items = {},
  excluded_shop_items = {},
  replenishment_factor = 0.2,
  excluded_event_pool = {},
  alignment = 0,
  glory_reward_modifier = 1,
  glory_recruit_modifier = 1
}

local persistent_keys = {
  cursor = true,
  cur_phase = true,
  pending_reward = true,
  army_cqi = true,
  event_room_chances = true,
  shop_sizes = true,
  shop_chances = true,
  active_shop_items = true,
  recruit_weights = true,
  recruitable_mercs = true,
  recruit_rarity_offset = true,
  recruit_count = true,
  excluded_items = true,
  excluded_shop_items = true,
  replenishment_factor = true,
  excluded_event_pool = true,
  alignment = true,
  glory_reward_modifier = true,
  glory_recruit_modifier = true
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
    pttg:log('[get_state]' .. state_key .. ' does not exist.')
    return nil
  end

  pttg:log('[get_state]' .. 'Get state ' .. state_key .. ':' .. tostring(state[state_key]))
  return state[state_key]
end

function pttg:set_state(key, value)
  if state[key] == nil then
    pttg:log('[set_state]' .. 'No such state key: ' .. tostring(key))
    return nil
  end

  pttg:log("[set_state] Key persistance: " .. tostring(persistent_keys[key]))
  if persistent_keys[key] then
    pttg:save_state(key, value)
  end

  state[key] = value
  pttg:log('[set_state]' .. 'State set ' .. key .. ':' .. tostring(state[key]))
  return value
end

function pttg:set_cursor(value)
  cm:set_saved_value('pttg_cursor', value)
  state['cursor'] = value
end

function pttg:get_cursor()
  return state['cursor']
end

function pttg:save_state(key, value)
  cm:set_saved_value("pttg_" .. key, value)
end

function pttg:load_state()
  pttg:log('[load_state] Loading state variables: ')

  for key, _ in pairs(persistent_keys) do
    local var = cm:get_saved_value("pttg_" .. key)
    if var then
      state[key] = var
      pttg:log(string.format('[load_state] Loaded: %s| %s', key, tostring(var)))
    end
  end
end

function pttg:set_seed(val)
  pttg:log('[s_seed] Set: ' .. 'gen_seed|' .. tostring(val))
  state['gen_seed'] = val
  self:save_state('gen_seed', val)
end

function pttg:load_seed()
  local var = cm:get_saved_value('pttg_gen_seed')
  if var then
    state['gen_seed'] = var
    pttg:log('[load_seed] Loaded: ' .. 'gen_seed|' .. tostring(var))
  end
end

function math:huge(number)
  return number + 1
end

core:add_static_object("pttg", pttg);
