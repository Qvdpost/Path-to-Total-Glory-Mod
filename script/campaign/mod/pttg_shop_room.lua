local pttg = core:get_static_object("pttg");
local pttg_shop = core:get_static_object("pttg_glory_shop");
local pttg_upkeep = core:get_static_object("pttg_upkeep")

local function init()

end


core:add_listener(
    "pttg_ShopRoom",
    "pttg_shop_room",
    true,
    function(context)
        pttg:log("[pttg_ShopRoom] resolving shop: ")

        pttg_upkeep:resolve("pttg_ShopRoom")

        cm:trigger_incident(cm:get_local_faction():name(), 'pttg_shop_room', true)
    end,
    true
)

core:add_listener(
    "pttg_ShopRoom",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_shop_room" end,
    function(context)
        pttg:log("[pttg_ShopRoom] resolving shop: ")

        core:trigger_custom_event('pttg_populate_shop', {})
        pttg_shop:enable_shop_button()
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)

core:add_listener(
    "pttg_ShopRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)
