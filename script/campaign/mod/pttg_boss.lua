local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_BossRoomBattle",
    "pttg_boss_room",
    true,
    function(context)

        pttg:log("[pttg_ShopRoom] resolving boss: ")
        -- TODO: trigger boss fight
        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_BossRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

