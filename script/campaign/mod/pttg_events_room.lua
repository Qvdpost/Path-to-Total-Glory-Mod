local pttg = core:get_static_object("pttg");
local pttg_events = core:get_static_object("pttg_event_pool")
local pttg_upkeep = core:get_static_object("pttg_upkeep")


core:add_listener(
    "pttg_EventRoom",
    "pttg_event_room",
    true,
    function(context)
        pttg:log("[pttg_EventRoom] resolving event: ")

        pttg_upkeep:resolve("pttg_EventRoom")

        local chances = pttg:get_state('event_room_chances')

        local chance = cm:random_number(100, 1)
        pttg:log("[pttg_EventRoom] random number: ".. chance)
        if chance <= chances.monster then
            pttg:log("[pttg_EventRoom] resolving event: Battle")
            chances.monster = 10
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif chance <= chances.monster + chances.shop then
            pttg:log("[pttg_EventRoom] resolving event: Shop")
            chances.shop = 3
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_shop_room', {})
        elseif chance <= chances.monster + chances.shop + chances.treasure then
            pttg:log("[pttg_EventRoom] resolving event: Treasure")
            chances.treasure = 2
            pttg:set_state('event_room_chances', chances)
            core:trigger_custom_event('pttg_treasure_room', {})
        else
            pttg:log("[pttg_EventRoom] resolving event: Event")
            chances.monster = chances.monster + 10
            chances.shop = chances.shop + 3
            chances.treasure = chances.treasure + 2
            pttg:set_state('event_room_chances', chances)

            local event = pttg_events:random_event()
            if event.type == 'dilemma' then
                cm:trigger_dilemma(cm:get_local_faction():name(), event.key)

                core:add_listener(
                    "pttg_event_resolved",
                    "DilemmaChoiceMadeEvent",
                    function(context)
                        return context:dilemma() == event.key
                    end,
                    function(context)
                        -- TODO: add event to the excluded events if non-repeatable.

                        event.callback(context)
                        core:trigger_custom_event('pttg_Idle', {})
                    end,
                    false
                )
            elseif event.type == 'incident' then
                cm:trigger_incident(cm:get_local_faction():name(), event.key, true)

                core:add_listener(
                    "pttg_event_resolved",
                    "IncidentOccuredEvent",
                    function(context)
                        return context:dilemma() == event.key
                    end,
                    function(context)
                        -- TODO: add event to the excluded events if non-repeatable.

                        event.callback(context)
                        core:trigger_custom_event('pttg_Idle', {})
                    end,
                    false
                )
            else 
                script_error("Event type not recognized: "..tostring(event.type))
                core:trigger_custom_event('pttg_Idle', {})
            end
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
