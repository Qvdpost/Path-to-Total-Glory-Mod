local pttg = core:get_static_object("pttg");
local pttg_shop = core:get_static_object("pttg_glory_shop");

local function init()
    pttg_shop = core:get_static_object("pttg_glory_shop");
    if #pttg:get_state('active_shop_items') > 0 then
        pttg_shop:enable_shop_button()
    else
        pttg_shop:disable_shop_button()
    end
end

core:add_listener(
    "pttg_ShopRoom",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_shop_room" end,
    function(context)
        pttg:log("[pttg_ShopRoom] resolving shop: ")

        core:trigger_custom_event('pttg_populate_shop', {})
        pttg_shop:enable_shop_button()
        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

core:add_listener(
    "init_ShopRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)
