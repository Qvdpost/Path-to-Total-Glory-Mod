local pttg = core:get_static_object("pttg");
local pttg_setup = core:get_static_object("pttg_setup");
local pttg_UI = core:get_static_object("pttg_UI")
local pttg_tele = core:get_static_object("pttg_tele")
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_glory_shop = core:get_static_object("pttg_glory_shop")
local pttg_upkeep = core:get_static_object("pttg_upkeep")
local pttg_side_effects = core:get_static_object("pttg_side_effects")
local pttg_effect_pool = core:get_static_object("pttg_effect_pool")


local function init()
    pttg:load_state();


    pttg_merc_pool:init_active_merc_pool()


    pttg_effect_pool:load_campaign_effects()
    pttg_effect_pool:apply_campaign_effects()

    pttg_upkeep:resolve("pttg_init")

    -- Add upkeep callbacks
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_recruit_glory", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_merc_pool", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_glory_shop", pttg_glory_shop.reset_rituals, pttg_glory_shop)

    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_recruit_glory_start", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_merc_pool_start", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)
    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_glory_shop_start", pttg_glory_shop.reset_rituals, pttg_glory_shop)

    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_teleport_region", pttg_tele.teleport_to_random_region, pttg_tele, { 100 })
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_center_camera_on_resolve",  pttg_UI.center_camera, pttg_UI, {}, 3)

    pttg_upkeep:add_callback("pttg_Idle", "pttg_center_camera_idle", pttg_UI.center_camera, pttg_UI)
    pttg_upkeep:add_callback("pttg_Idle", "pttg_level_characters", pttg_side_effects.grant_characters_passive_levels, pttg_side_effects, {1, 2})

    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_show_map_start",  pttg_UI.populate_and_show_map, pttg_UI, {}, 3)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_show_map_path",  pttg_UI.populate_and_show_map, pttg_UI, {}, 3)
    
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_hide_map_resolve_room", pttg_UI.hide_map, pttg_UI, {}, 1)
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_update_map", pttg_UI.populate_map, pttg_UI, {}, 3)
    
    pttg_upkeep:add_callback("pttg_PostRoomBattle", "pttg_center_camera_post_battle",  pttg_UI.center_camera, pttg_UI)

    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_lock_in_general", 
        function() 
            pttg:set_state("general_fm_cqi", cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character():family_member():command_queue_index())
        end
    )

    pttg_upkeep:add_callback("pttg_Idle", "pttg_check_locked_general_alive", 
        function()
            if cm:get_family_member_by_cqi(pttg:get_state("general_fm_cqi")):character():is_null_interface() or cm:get_family_member_by_cqi(pttg:get_state("general_fm_cqi")):character():is_wounded() then
                cm:callback(
                    function()
                        cm:trigger_incident(cm:get_local_faction_name(), "pttg_battle_defeat", true)
                    end,
                    0.4
                )
            end
        end
    )
    
    if not pttg:get_state('army_cqi') then
        local faction = cm:get_local_faction()
        local force = faction:faction_leader():military_force()
        if not force:is_null_interface() then
            pttg:set_state('army_cqi', force:command_queue_index())
        else
            for i = 0, faction:character_list():num_items() - 1 do
                local character = faction:character_list():item_at(i)
                if not character:military_force():is_null_interface() and character:character_type_key() ~= 'colonel' then
                    pttg:set_state('army_cqi', character:military_force():command_queue_index())
                    break
                end
            end
        end
    end


    if pttg:get_state('cur_phase') == "" then
        pttg:set_state('cur_phase', "pttg_Idle")
    end

    if cm:is_new_game() then
        pttg_side_effects:zero_merc_cost()     
    end

    pttg_UI:enable_next_phase_button()

    pttg_setup:post_init()

    core:trigger_custom_event('pttg_init_complete', {})
end

core:add_listener(
    "pttg_Main",
    "pttg_ChooseStart",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ChooseStart")

        pttg_upkeep:resolve("pttg_ChooseStart")

        local choose_start = cm:create_dilemma_builder('pttg_ChooseStart')

        local cursor = pttg:get_cursor()
        local act = 1
        if cursor then
            act = cursor.z + 1
        end

        local payload_map = {
            "FIRST", "SECOND", "THIRD", "FOURTH", "FIFTH", "SIXTH", "SEVENTH", "EIGHTH"
        }
        local payload = cm:create_payload()
        for _, node in pairs(pttg:get_state('maps')[act][1]) do
            if node:is_connected() then
                choose_start:add_choice_payload(payload_map[node.x], payload)
            end
        end

        cm:launch_custom_dilemma_from_builder(choose_start, cm:get_local_faction())
    end,
    true
)

core:add_listener(
    "pttg_Main",
    "pttg_ChoosePath",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ChoosePath")

        local cursor = pttg:get_cursor()

        pttg_upkeep:resolve("pttg_ChoosePath")

        local choose_path = cm:create_dilemma_builder('pttg_ChoosePath')

        local payload = cm:create_payload()
        -- 3 loops to ensure button order
        for _, edge in pairs(cursor.edges) do
            if edge.dst_x < cursor.x then
                choose_path:add_choice_payload("FIRST", payload)
                break
            end
        end
        for _, edge in pairs(cursor.edges) do
            if edge.dst_x == cursor.x then
                choose_path:add_choice_payload("SECOND", payload)
                break
            end
        end
        for _, edge in pairs(cursor.edges) do
            if edge.dst_x > cursor.x then
                choose_path:add_choice_payload("THIRD", payload)
                break
            end
        end

        cm:launch_custom_dilemma_from_builder(choose_path, cm:get_local_faction())
    end,
    true
)

core:add_listener(
    "pttg_Main",
    "pttg_ResolveRoom",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ResolveRoom")

        local cursor = pttg:get_cursor()

        pttg_upkeep:resolve("pttg_ResolveRoom")

        -- TODO: verify this works for legendary and is not intrusive
        if cm:get_difficulty() == 5 then -- legendary
            cm:save()
        end

        if cursor.class == pttg_RoomType.MonsterRoom then
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif cursor.class == pttg_RoomType.MonsterRoomElite then
            core:trigger_custom_event('pttg_StartEliteRoomBattle', {})
        elseif cursor.class == pttg_RoomType.BossRoom then
            core:trigger_custom_event('pttg_StartBossRoomBattle', {})
        elseif cursor.class == pttg_RoomType.RestRoom then
            core:trigger_custom_event('pttg_rest_room', {})
        elseif cursor.class == pttg_RoomType.EventRoom then
            core:trigger_custom_event('pttg_event_room', {})
        elseif cursor.class == pttg_RoomType.ShopRoom then
            core:trigger_custom_event('pttg_shop_room', {})
        elseif cursor.class == pttg_RoomType.TreasureRoom then
            core:trigger_custom_event('pttg_treasure_room', {})
        end
    end,
    true
)

core:add_listener(
    "pttg_Main",
    "pttg_Rewards",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_Rewards")
        
        pttg_upkeep:resolve("pttg_Rewards")
        
        pttg_UI:highlight_event_accept(false)

        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChooseReward')
        
        pttg:set_state('pending_reward', true)
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)

core:add_listener(
    "pttg_Main",
    "pttg_Idle",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_Idle")

        pttg_upkeep:resolve("pttg_Idle")

        pttg_UI:enable_next_phase_button()
    end,
    true
)

cm:add_first_tick_callback(
    function()
        -- if not cm:is_new_game() then
        --     return
        -- end
        local how_its_played = intervention:new("pttg_how_its_played", 60, function() end)
        if cm:is_new_game() then
            if how_its_played then
                pttg:log("adding pttg_how_its_played")
                how_its_played:set_must_trigger(true)
                how_its_played:set_callback(function()
                    cm:trigger_incident(cm:get_local_faction_name(), 'pttg_how_its_played', true)
                    how_its_played:complete()
                end)
            
                how_its_played:add_trigger_condition(
                    "ScriptEventIntroCutsceneFinished", 
                    function() return cm:is_new_game() end
                )
            
                how_its_played:start()
            end
        end
    end
)

core:add_listener(
    "pttg_mode_selection",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_how_its_played" end,
    function(context)
        if not cm:get_saved_value("pttg_RandomStart") then
            pttg_UI:hide_map()
            cm:trigger_dilemma(cm:get_local_faction_name(), 'pttg_RandomStart')
            cm:set_saved_value("pttg_RandomStart", true)
            return
        end
    end,
    false
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