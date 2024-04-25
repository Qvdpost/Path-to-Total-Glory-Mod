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

    mct:get_notification_system():get_ui():populate_banner()
    mct:get_notification_system():get_ui():refresh_button()

    local cursor = pttg:get_cursor()
    local act = 1
    if cursor then
        act = cursor.z
    end

    map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[act], cursor))

    cm:disable_end_turn(true)

    -- Add upkeep callbacks
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_recruit_glory", pttg_glory.reset_recruit_glory, pttg_glory)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_merc_pool", pttg_merc_pool.reset_active_merc_pool, pttg_merc_pool)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_reset_glory_shop", pttg_glory_shop.reset_rituals, pttg_glory_shop)
    pttg_upkeep:add_callback("pttg_ChoosePath", "pttg_winds_of_magic_down", pttg_mod_wom.decrease, pttg_mod_wom, { 5 })

    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_teleport_region", pttg_tele.teleport_to_random_region, pttg_tele, { 100 })
    pttg_upkeep:add_callback("pttg_ResolveRoom", "pttg_center_camera", pttg_UI.center_camera, pttg_UI, {}, 3)

    pttg_upkeep:add_callback("pttg_Idle", "pttg_center_camera", pttg_UI.center_camera, pttg_UI)


    if not pttg:get_state('army_cqi') then
        pttg:set_state('army_cqi', cm:get_local_faction():faction_leader():military_force():command_queue_index())
    end


    if pttg:get_state('cur_phase') == "" then
        pttg:set_state('cur_phase', "pttg_Idle")
    end

    pttg_UI:enable_next_phase_button()

    core:trigger_custom_event('pttg_init_complete', {})
end

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
    "pttg_Main",
    "pttg_ChooseStart",
    true,
    function(context)
        pttg:set_state('cur_phase', "pttg_ChooseStart")

        pttg_upkeep:resolve("pttg_ChooseStart")

        local cursor = pttg:get_cursor()
        local act = 1
        if cursor then
            act = cursor.z + 1
        end

        map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[act], cursor))


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

        map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[cursor.z], cursor))

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

        -- Trigger chosen room
        map_notif:set_long_text(procgen:format_map(pttg:get_state('maps')[cursor.z], cursor))
        mct:get_notification_system():get_ui():refresh_button()

        if cursor.class == pttg_RoomType.MonsterRoom then
            core:trigger_custom_event('pttg_StartRoomBattle', {})
        elseif cursor.class == pttg_RoomType.MonsterRoomElite then
            core:trigger_custom_event('pttg_StartEliteRoomBattle', {})
        elseif cursor.class == pttg_RoomType.BossRoom then
            core:trigger_custom_event('pttg_Idle', {})
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

        if pttg:get_cursor() then
            pttg_UI:center_camera()
        end

        pttg_UI:enable_next_phase_button()
    end,
    true
)
