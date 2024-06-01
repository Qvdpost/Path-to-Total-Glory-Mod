local pttg = core:get_static_object("pttg");
local pttg_glory_shop = core:get_static_object("pttg_glory_shop")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")
local pttg_item_pool = core:get_static_object("pttg_item_pool")
local pttg_upkeep = core:get_static_object("pttg_upkeep")


core:add_listener(
    "pttg_TreasureRoom",
    "pttg_treasure_room",
    true,
    function(context)
        pttg:log("[pttg_TreasureRoom] resolving treasure: ")

        pttg_upkeep:resolve("pttg_TreasureRoom")

        local rando = cm:random_number(100)
        pttg:log("[pttg_TreasureRoom] Rolled a "..rando)
        if rando <= 50 then
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_small_treasure', true)
        elseif rando <= 83 then
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_medium_treasure', true)
        else
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_large_treasure', true)
        end

        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)

local function init()
    -- Is there anything to init?
end

local function pttg_small_treasure_callback(context)
    pttg:log("[pttg_TreasureRoom] resolving small treasure: ")
    local rando = cm:random_number(100)
    pttg:log("[pttg_TreasureRoom] Rolled a "..rando)
    local random_item
    if rando <= 75 then
        local rewards = pttg_item_pool:get_reward_items(1, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    else
        local rewards = pttg_item_pool:get_reward_items(2, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    end

    if not random_item then
        script_error("[pttg_treasure] No item reward available!")
        return false
    end

    cm:add_ancillary_to_faction(context:faction(), random_item.key, false)

    if cm:random_number(100) <= 50 then
        pttg_glory:reward_glory(27, 23)
    end

    pttg_item_pool:exclude_item(random_item)
end

local function pttg_medium_treasure_callback(context)
    pttg:log("[pttg_TreasureRoom] resolving medium treasure: ")
    local rando = cm:random_number(100)
    pttg:log("[pttg_TreasureRoom] Rolled a "..rando)
    local random_item
    if rando <= 35 then
        local rewards = pttg_item_pool:get_reward_items(1, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    elseif rando <= 85 then
        local rewards = pttg_item_pool:get_reward_items(2, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    else
        local rewards = pttg_item_pool:get_reward_items(3, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    end

    if not random_item then
        script_error("[pttg_treasure] No item reward available!")
        return false
    end

    cm:add_ancillary_to_faction(context:faction(), random_item.key, false)

    if cm:random_number(100) <= 35 then
        pttg_glory:reward_glory(55, 45)
    end

    pttg_item_pool:exclude_item(random_item)
end

local function pttg_large_treasure_callback(context)
    pttg:log("[pttg_TreasureRoom] resolving large treasure: ")
    local rando = cm:random_number(100)
    pttg:log("[pttg_TreasureRoom] Rolled a "..rando)
    local random_item
    if rando <= 75 then
        local rewards = pttg_item_pool:get_reward_items(2, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    else
        local rewards = pttg_item_pool:get_reward_items(3, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    end

    if not random_item then
        script_error("[pttg_treasure] No item reward available!")
        return false
    end

    cm:add_ancillary_to_faction(context:faction(), random_item.key, false)

    if cm:random_number(100) <= 50 then
        pttg_glory:reward_glory(82, 68)
    end

    pttg_item_pool:exclude_item(random_item)
end

local function pttg_boss_treasure_callback(context)
    pttg:log("[pttg_TreasureRoom] resolving boss treasure: ")

    local rewards = pttg_item_pool:get_reward_items(4, pttg:get_state("excluded_items"))
    if #rewards > 0 then
        random_item = rewards[cm:random_number(#rewards)]
    end

    if not random_item then
        script_error("[pttg_treasure] No item reward available!")
        return false
    end

    cm:add_ancillary_to_faction(context:faction(), random_item.key, false)

    pttg_item_pool:exclude_item(random_item)
end

local function pttg_random_treasure_callback(context)
    pttg:log("[pttg_TreasureRoom] resolving random treasure: ")
    local rando = cm:random_number(100)
    pttg:log("[pttg_TreasureRoom] Rolled a "..rando)
    local random_item
    if rando <= 50 then
        local rewards = pttg_item_pool:get_reward_items(1, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    elseif rando <= 83 then
        local rewards = pttg_item_pool:get_reward_items(2, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    else
        local rewards = pttg_item_pool:get_reward_items(3, pttg:get_state("excluded_items"))
        if #rewards > 0 then
            random_item = rewards[cm:random_number(#rewards)]
        end
    end

    if not random_item then
        script_error("[pttg_treasure] No item reward available!")
        return false
    end

    cm:add_ancillary_to_faction(context:faction(), random_item.key, false)

    pttg_item_pool:exclude_item(random_item)
end

core:add_listener(
    "pttg_TreasureRoom",
    "pttg_random_treasure",
    true,
    function(context)
        pttg:log("[pttg_TreasureRoom] resolving random treasure: ")

        pttg_random_treasure_callback(context)
    end,
    true
)

core:add_listener(
    "pttg_treasure_chest",
    "IncidentOccuredEvent",
    true,
    function(context)
        if context:dilemma() == "pttg_small_treasure" then
            pttg_small_treasure_callback(context)
        elseif context:dilemma() == "pttg_medium_treasure" then
            pttg_medium_treasure_callback(context)
        elseif context:dilemma() == "pttg_large_treasure" then
            pttg_large_treasure_callback(context)
        elseif context:dilemma() == "pttg_boss_treasure" then
            pttg_boss_treasure_callback(context)
        end
    end,
    true
)

core:add_listener(
    "init_TreasureRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)
