local pttg = core:get_static_object("pttg");
local procgen = core:get_static_object("procgen")
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

    cm:disable_end_turn(true)

    pttg_effect_pool:load_campaign_effects()
    pttg_effect_pool:apply_campaign_effects()

    pttg_upkeep:resolve("pttg_init")

    -- Add upkeep callbacks
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_recruit_glory", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_merc_pool", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_glory_shop", pttg_glory_shop.reset_rituals, pttg_glory_shop)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_winds_of_magic_down", pttg_mod_wom.decrease, pttg_mod_wom, { 5 })

    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_recruit_glory_start", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_merc_pool_start", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)
    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_reset_glory_shop_start", pttg_glory_shop.reset_rituals, pttg_glory_shop)

    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_teleport_region", pttg_tele.teleport_to_random_region, pttg_tele, { 100 })
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_center_camera_on_resolve",  pttg_UI.center_camera, pttg_UI, {}, 3)

    pttg_upkeep:add_callback("pttg_Idle", "pttg_center_camera_idle", pttg_UI.center_camera, pttg_UI)
    
    pttg_upkeep:add_callback("pttg_ChooseStart", "pttg_show_map_start",  pttg_UI.populate_and_show_map, pttg_UI, {}, 3)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_show_map_path",  pttg_UI.populate_and_show_map, pttg_UI, {}, 3)
    
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_hide_map_resolve_room", pttg_UI.hide_map, pttg_UI, {}, 1)
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_update_map", pttg_UI.populate_map, pttg_UI, {}, 3)
    
    pttg_upkeep:add_callback("pttg_PostRoomBattle", "pttg_heal_post_battle", pttg_side_effects.heal_force, pttg_side_effects, {0.1, true})
    pttg_upkeep:add_callback("pttg_PostRoomBattle", "pttg_level_characters", pttg_side_effects.grant_characters_levels, pttg_side_effects, {1})
    pttg_upkeep:add_callback("pttg_PostRoomBattle", "pttg_center_camera_post_battle",  pttg_UI.center_camera, pttg_UI)
    

    if not pttg:get_state('army_cqi') then
        pttg:set_state('army_cqi', cm:get_local_faction():faction_leader():military_force():command_queue_index())
    end


    if pttg:get_state('cur_phase') == "" then
        pttg:set_state('cur_phase', "pttg_Idle")
    end

    if cm:is_new_game() then
        pttg_side_effects:zero_merc_cost()     
    end

    pttg_UI:enable_next_phase_button()


    core:trigger_custom_event('pttg_init_complete', {})
end

core:add_listener(
    "pttg_Main",
    "pttg_ChooseStart",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ChooseStart")

        pttg_upkeep:resolve("pttg_ChooseStart")

        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChooseStart')
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
    "pttg_Main",
    "pttg_ResolveRoom",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ResolveRoom")

        local cursor = pttg:get_cursor()

        pttg_upkeep:resolve("pttg_ResolveRoom")

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

        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_ChooseReward')
        
        pttg:set_state('cur_phase', "pending_reward")
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
        local how_its_played = intervention:new("pttg_how_its_played", 60, function() end)
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