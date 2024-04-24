local pttg = core:get_static_object("pttg");
local pttg_events = core:get_static_object("pttg_event_pool")

core:add_listener(
    "pttg_EventRoomChosen",
    "pttg_event_room",
    true,
    function(context)
        pttg:log("[pttg_EventRoom] resolving event: ")

        local chances = pttg:get_state('event_room_chances')

        local chance = cm:random_number(100, 1)
        pttg:log("[pttg_EventRoom] random number: ", chance)
        if chance <= chances.monster then
            chances.monster = 10
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif chance <= chances.monster + chances.shop then
            chances.shop = 3
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_shop_room', {})
        elseif chance <= chances.monster + chances.shop + chances.treasure then
            chances.treasure = 2
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_treasure_room', {})
        else
            chances.monster = chances.monster + 10
            chances.shop = chances.shop + 3
            chances.treasure = chances.treasure + 2
            pttg:set_state('event_room_chances', chances)

            local event = pttg_events:random_event()
            cm:trigger_dilemma(cm:get_local_faction():name(), event)

            core:add_listener(
                "pttg_event_resolved",
                "DilemmaChoiceMadeEvent",
                function(context)
                    return context:dilemma() == event
                end,
                function(context)
                    -- TODO: add event to the excluded events if non-repeatable.

                    pttg_events:get_event_callback(event)(context)
                    core:trigger_custom_event('pttg_idle', {})
                end,
                false
            )
        end
    end,
    true
)

local function init()
    pttg:log("[pttg_EventRoom] initialising events")
    local chances = pttg:get_state('event_room_chances')
end

core:add_listener(
    "init_EventRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)
