local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_ShopRoomChosen",
    "pttg_shop_room",
    true,
    function(context)

        pttg:log("[pttg_ShopRoom] resolving shop: ")
        -- TODO: implement a shop...
        core:trigger_custom_event('pttg_populate_shop', {})
        local pttg_shop = core:get_static_object("pttg_glory_shop");
        pttg_shop:enable_shop_button()
        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_ShopRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

