local pttg = core:get_static_object("pttg");
local procgen = core:get_static_object("procgen")
local pttg_UI = core:get_static_object("pttg_UI")
local pttg_tele = core:get_static_object("pttg_tele")
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_glory_shop = core:get_static_object("pttg_glory_shop")
local pttg_upkeep = core:get_static_object("pttg_upkeep")

local mct = get_mct();

local map_notif = mct:get_notification_system():create_error_notification()

map_notif:set_title("This is the PtTG Map!")
    :set_short_text("See the paths you can take here:")
    :set_error_text(
        "Below you can see the map and choose a path accordingly. The path of Order is on the left, Chaos to the right and the Neutral path is in the middle.")
    :set_persistent(true)

local function init()
    pttg:load_state();
    pttg_merc_pool:init_active_merc_pool()
    mct = get_mct();

    local cursor = pttg:get_cursor()
    local act = 1
    if cursor then
        act = cursor.z
    end

    map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[act], cursor))

    mct:get_notification_system():get_ui():populate_banner()
    mct:get_notification_system():get_ui():refresh_button()

    cm:disable_end_turn(true)

    -- Add upkeep callbacks
    pttg_upkeep:add_callback("pttg_reset_recruit_glory", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_reset_glory_shop", pttg_glory_shop.reset_rituals, pttg_glory_shop)
    pttg_upkeep:add_callback("pttg_winds_of_magic_down", pttg_mod_wom.decrease, pttg_mod_wom, { -5 })
    pttg_upkeep:add_callback("pttg_reset_merc_pool", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)


    if not pttg:get_state('army_cqi') then
        pttg:set_state('army_cqi', cm:get_local_faction():faction_leader():military_force():command_queue_index())
    end

    core:trigger_custom_event('pttg_init_complete', {})

    if pttg:get_state('cur_phase') == "" then
        pttg:set_state('cur_phase', "pttg_idle")
    end

    pttg_UI:enable_next_phase_button()
end

core:add_listener(
    "pttg_RewardChosen",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChooseReward'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_RewardChosen] resolving reward: ")

        pttg:log(string.format("Choice: %s", context:choice_key()))

        local node = pttg:get_cursor()

        if context:choice_key() == 'FIRST' then -- Recruit Reward
            pttg_glory:add_initial_recruit_glory(1)

            core:trigger_custom_event('pttg_recruit_reward', {})
        elseif context:choice_key() == 'SECOND' then -- WoM reward
            pttg:log("[pttg_RewardChosen] Increasing WoM.")
            pttg_mod_wom:increase(15)
        elseif context:choice_key() == 'THIRD' then -- Glory Reward
            pttg_glory:reward_glory(40, 25)
        else                                        -- Decide Later
            pttg:set_state('pending_reward', true)
            core:trigger_custom_event('pttg_idle', {})
            return true
        end

        pttg:set_state('pending_reward', false)
        core:trigger_custom_event('pttg_idle', {})

        return true
    end,
    true
)


core:add_listener(
    "init_PathToTotalGlory",
    "pttg_procgen_finished",
    true,
    function(context)
        init()
    end,
    false
)

core:add_listener(
    "pttg_ChooseStartPath",
    "pttg_phase0",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_phase1")
        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChooseStart')
    end,
    true
)

core:add_listener(
    "pttg_ChoosePath",
    "pttg_phase1",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_phase1")

        pttg_upkeep:resolve()

        local cursor = pttg:get_cursor()
        -- Choose a path dilemma
        if #cursor.edges == 3 then
            cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathLMR')
        elseif #cursor.edges == 2 then
            if (cursor.edges[1].dst_x < cursor.x and cursor.edges[2].dst_x == cursor.x) or
                (cursor.edges[2].dst_x < cursor.x and cursor.edges[1].dst_x == cursor.x) then
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathLM')
            elseif (cursor.edges[1].dst_x == cursor.x and cursor.edges[2].dst_x > cursor.x) or
                (cursor.edges[2].dst_x == cursor.x and cursor.edges[1].dst_x > cursor.x) then
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathMR')
            else
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathLR')
            end
        else
            if cursor.edges[1].dst_x < cursor.x then
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathL')
            elseif cursor.edges[1].dst_x > cursor.x then
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathR')
            else
                cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChoosePathM')
            end
        end
    end,
    true
)

core:add_listener(
    "pttg_PathChosen",
    "pttg_phase2",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_phase2")

        local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
        pttg_tele:teleport_to_random_region(character, 100)

        local cursor = pttg:get_cursor()

        -- Trigger chosen room
        map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[cursor.z], cursor))
        mct:get_notification_system():get_ui():refresh_button()



        if cursor.class == pttg_RoomType.MonsterRoom then
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif cursor.class == pttg_RoomType.MonsterRoomElite then
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif cursor.class == pttg_RoomType.BossRoom then
            core:trigger_custom_event('pttg_idle', {})
        elseif cursor.class == pttg_RoomType.RestRoom then
            core:trigger_custom_event('pttg_rest_room', {})
        elseif cursor.class == pttg_RoomType.EventRoom then
            core:trigger_custom_event('pttg_event_room', {})
        elseif cursor.class == pttg_RoomType.ShopRoom then
            cm:trigger_incident(cm:get_local_faction():name(), 'pttg_shop_room', true)
        elseif cursor.class == pttg_RoomType.TreasureRoom then
            core:trigger_custom_event('pttg_treasure_room', {})
        end
    end,
    true
)

core:add_listener(
    "pttg_RoomCompleted",
    "pttg_phase3",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_phase3")
        -- Trigger reward dilemma
        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChooseReward')
    end,
    true
)

core:add_listener(
    "pttg_IdleMode",
    "pttg_idle",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_idle")

        if pttg:get_cursor() then
            local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
            cm:callback( -- we need to wait a tick for this to work, for some reason
                function()
                    cm:replenish_action_points(cm:char_lookup_str(character));
                    cm:scroll_camera_from_current(false, 1,
                        { character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0 });
                end,
                0.2
            )
        end

        pttg_UI:enable_next_phase_button()
    end,
    true
)
