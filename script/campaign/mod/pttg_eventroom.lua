local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_EventRoomChosen",
    "pttg_event_room",
    true,
    function(context)

        pttg:log("[pttg_EventRoom] resolving event: ")
        
        local chances = pttg:get_state('event_room_chances')
        
        local chance = cm:random_number(100,1)
        
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
            -- TODO Trigger events
            core:trigger_custom_event('pttg_idle', {})
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

