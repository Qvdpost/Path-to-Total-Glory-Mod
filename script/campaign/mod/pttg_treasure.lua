local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_TreasureRoomChosen",
    "pttg_treasure_room",
    true,
    function(context)

        pttg:log("[pttg_TreasureRoom] resolving treasure: ")

        -- TODO Hand out treasure
        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_TreasureRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

