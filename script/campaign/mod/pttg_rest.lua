local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_RestRoomChosen",
    "pttg_rest_room",
    true,
    function(context)

        pttg:log("[pttg_RestRoom] resolving rest: ")
        cm:heal_military_force(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')))
        
        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_RestRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

