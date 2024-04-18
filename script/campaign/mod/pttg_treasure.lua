local pttg = core:get_static_object("pttg");
local pttg_glory_shop = core:get_static_object("pttg_glory_shop")
local pttg_glory = core:get_static_object("pttg_glory")

core:add_listener(
    "pttg_TreasureRoomChosen",
    "pttg_treasure_room",
    true,
    function(context)
        pttg:log("[pttg_TreasureRoom] resolving treasure: ")

        local rando = cm:random_number(100)
        if rando <= 50 then
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_small_treasure', true)
        elseif rando <= 83 then
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_medium_treasure', true)
        else
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_large_treasure', true)
        end
    end,
    true
)

local function init()

end

function pttg_small_treasure_callback(context)
    local rando = cm:random_number(100)
    if rando <= 75 then
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[1])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    else
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[2])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    end

    rando = cm:random_number(100)
    if rando <= 50 then
        pttg_glory:reward_glory(27, 23)
    end
end

function pttg_medium_treasure_callback(context)
    local rando = cm:random_number(100)
    if rando <= 35 then
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[1])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    elseif rando <= 85 then
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[2])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    else
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[3])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    end

    rando = cm:random_number(100)
    if rando <= 35 then
        pttg_glory:reward_glory(55, 45)
    end
end

function pttg_large_treasure_callback(context)
    local rando = cm:random_number(100)
    if rando <= 75 then
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[2])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    else
        local random_item = pttg_glory_shop.shop_items.merchandise[1]
            [cm:random_number(#pttg_glory_shop.shop_items.merchandise[3])]
        cm:perform_ritual(context:faction():name(), context:faction():name(), random_item.ritual)
    end

    rando = cm:random_number(100)
    if rando <= 50 then
        pttg_glory:reward_glory(82, 68)
    end
end

function pttg_boss_treasure_callback(context)
    --body of the callback; what should happen for each choice?
end

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
            pttg_boss_treasure_callback(context)
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
