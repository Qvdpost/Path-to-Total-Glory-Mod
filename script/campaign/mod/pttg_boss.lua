local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_BossRoomBattle",
    "pttg_boss_room",
    true,
    function(context)

        pttg:log("[pttg_ShopRoom] resolving boss: ")
        -- TODO: trigger boss fight

        -- Full heal player army.
        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
        cm:heal_military_force(force)

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

