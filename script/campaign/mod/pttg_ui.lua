local pttg = core:get_static_object("pttg");
local pttg_shop = core:get_static_object("pttg_glory_shop");
local pttg_glory = core:get_static_object("pttg_glory")

local pttg_UI = {
    faction_buttons = {
        button_missions = true,
        button_diplomacy = true,
        button_rituals = true,
        button_slaves = true,
        button_skaven_corruption = true,
        sword_of_khaine = true,

        -- pttg_map_button = true,
        -- button_mortuary_cult = true,
        -- button_technology = true,
        -- button_ikit_workshop = true,
        -- button_beastmen_panel = true,
        -- button_chaos_gifts = true,
        -- button_hellforge = true,
        -- button_great_game_rituals = true,
        -- button_sotek_sacrifices = true,
        -- button_hunters = true,
        -- button_districts_of_nuln = true,
        -- button_black_tower = true,
        -- button_college_of_magic = true,
        -- button_matters_of_state = true,
        -- button_schemes = true,
        -- button_changing_of_the_ways = true,
        -- button_tamurkhan_chiefs = true,
        -- button_nurgle_plagues = true,
        -- button_book_of_grudges = true,
        -- button_toz = true,
    }
}

function pttg_UI:init()
    pttg:log("[pttg_ui] Initialising UI and listeners")
    self:ui_created()
    self:disable_event_feed()
    self:hide_faction_buttons()
end

function pttg_UI:get_or_create_map()
    local parent = core:get_ui_root()
    local map_ui_name = "pttg_map"

    local map_ui = find_uicomponent(parent, map_ui_name)
    if map_ui then
        return map_ui
    end

    local cursor = pttg:get_cursor()
    local act = 1
    if cursor then
        act = cursor.z
        if cursor.class == pttg_RoomType.BossRoom then
            act = act + 1
            cursor = nil
        end
    end
    local map = pttg:get_state('maps')[act]

    map_ui = core:get_or_create_component(map_ui_name, "ui/campaign ui/pttg_map_panel", parent)

    map_ui:MoveTo(40, 80)

    map_ui:Resize(420, 900)

    local map_title = find_uicomponent(map_ui, 'panel_title')
    if not map_title then
        script_error("Could not find the map title! How can this be?")
        return
    end
    map_title:SetStateText("The Path Act " .. act)

    local rows = core:get_or_create_component("rows", "ui/campaign ui/vlist", map_ui)

    local boss = core:get_or_create_component('boss', "ui/templates/panel_title", rows)
    local boss_text = core:get_or_create_component('text', "ui/common ui/text_box", boss)
    boss_text:SetDockOffset(0, 0)
    boss_text:SetDockingPoint(5)
    boss_text:SetStateText("Boss")
    boss_text:SetInteractive(false)

    for i = pttg:get_config("map_height"), 1, -1 do
        local row = core:get_or_create_component("row" .. i, "ui/campaign ui/hlist", rows)
        for j = 1, pttg:get_config("map_width") do
            local node = core:get_or_create_component("node" .. i .. "," .. j, "ui/templates/room_frame", row)
            local map_node = map[i][j]
            node:Resize(50, 50)

            if #map_node.edges > 0 and node then
                if cursor then
                    if i == cursor.y and j == cursor.x then
                        node:SetState('ActiveState')
                    else
                        node:SetState("NewState")
                    end
                end

                node:SetTextHAlign('centre')
                node:SetTextVAlign('centre')
                node:SetStateText(pttg_get_room_symbol(map_node.class))

                for k, edge in ipairs(map_node.edges) do
                    -- TODO Maybe use better connectors (these cost a lot of frames). E.G. beastemen link pngs
                    local connection = UIComponent(node:CreateComponent("connection" .. k, "ui/templates/line_smoke"))
                    connection:PropagatePriority(55)
                    if edge.dst_x == map_node.x then
                        connection:Resize(30, 30, true)
                        connection:SetCurrentStateImageDockingPoint(0, 5)
                        connection:SetDockOffset(0, -30)
                        connection:ResizeCurrentStateImage(0, 20, 15)
                        connection:SetImageRotation(0, math.pi * 0.5)
                    elseif edge.dst_x < map_node.x then
                        connection:Resize(30, 30, true)
                        connection:SetCurrentStateImageDockingPoint(0, 5)
                        connection:SetDockOffset(-28, -28)
                        connection:ResizeCurrentStateImage(0, 45, 15)
                        connection:SetImageRotation(0, math.pi * 0.25)
                    else
                        connection:Resize(30, 30, true)
                        connection:SetCurrentStateImageDockingPoint(0, 5)
                        connection:SetDockOffset(28, -28)
                        connection:ResizeCurrentStateImage(0, 45, 15)
                        connection:SetImageRotation(0, math.pi * 0.75)
                    end
                end
            else
                node:SetState('EmptyState')
            end
        end
    end

    local seed = core:get_or_create_component('seed', "ui/common ui/text_box", rows)
    seed:SetStateText("Seed: " .. pttg:get_state("gen_seed"))
    seed:SetInteractive(false)

    local close_button_uic = core:get_or_create_component("pttg_map_close", "ui/templates/round_small_button", rows)
    close_button_uic:SetImagePath("ui/skins/warhammer3/icon_check.png")
    close_button_uic:SetTooltipText("Close map", true)
    close_button_uic:SetDockingPoint(5)


    self:hide_map()
end

function pttg_UI:destroy_map()
    local parent = core:get_ui_root()
    local map_ui_name = "pttg_map"
    local map_ui = core:get_or_create_component(map_ui_name, "ui/campaign ui/pttg_map_panel", parent)
    if map_ui then
        pttg:log("Destroying map.")
        map_ui:Destroy()
    end
    pttg:log("No map to destroy.")
end

function pttg_UI:show_map()
    local parent = core:get_ui_root()
    local map_ui_name = "pttg_map"
    local map_ui = find_uicomponent(parent, map_ui_name)
    if not map_ui then
        script_error("Could not find the map! How can this be?")
        return
    end
    map_ui:SetVisible(true)
end

function pttg_UI:populate_and_show_map()
    self:populate_map()
    self:show_map()
end

function pttg_UI:hide_map()
    local parent = core:get_ui_root()
    local map_ui_name = "pttg_map"
    local map_ui = find_uicomponent(parent, map_ui_name)
    if not map_ui or not map_ui:Visible() then
        return
    end
    map_ui:SetVisible(false)
end

function pttg_UI:populate_map()
    local map_ui = self:get_or_create_map()

    local cursor = pttg:get_cursor()
    local act = 1
    if cursor then
        act = cursor.z
        if cursor.class == pttg_RoomType.BossRoom then
            act = act + 1
            cursor = nil
        end
    end
    pttg:log("Populating map act: "..tostring(act))
    local map = pttg:get_state('maps')[act]

    if not map then
        pttg:log("No map to populate")
        return
    end

    local map_title = find_uicomponent(map_ui, 'panel_title')
    if not map_title then
        script_error("Could not find the map title! How can this be?")
        return
    end
    map_title:SetStateText("The Path Act " .. tostring(act))

    local rows = find_uicomponent(map_ui, 'rows')

    -- TODO: Preset boss?
    -- local boss = core:get_or_create_component('boss', "ui/templates/panel_title", rows)
    -- boss:SetStateText("Boss")

    for i = pttg:get_config("map_height"), 1, -1 do
        local row = find_uicomponent(rows, "row" .. i)
        for j = 1, #map[i] do
            local node = find_uicomponent(row, "node" .. i .. "," .. j)
            local map_node = map[i][j]

            -- TODO: add visited nodes and mark them
            if #map_node.edges > 0 and node then
                if cursor then
                    if i == cursor.y and j == cursor.x then
                        node:SetState('ActiveState')
                    else
                        node:SetState("NewState")
                    end
                end
                node:SetTextHAlign('centre')
                node:SetTextVAlign('centre')
                node:SetStateText(pttg_get_room_symbol(map_node.class))
            end
        end
    end
end

function pttg_UI:get_or_create_map_button()
    pttg:log("Getting/Creating Map Button")
    local root = core:get_ui_root()
    local faction_buttons = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management")
    
    if not faction_buttons then
        script_error("Could not find the faction buttons! How can this be?")
        return
    end

    local map_button = find_uicomponent(faction_buttons, "pttg_map_button")
    if map_button then
        return map_button
    end

    map_button = core:get_or_create_component("pttg_map_button", "ui/templates/round_hud_button_toggle", faction_buttons)

    map_button:SetImagePath("ui/skins/default/minimap_compass.png")
    map_button:SetTooltipText(common.get_localised_string("pttg_map_tooltip"), true)
    map_button:SetVisible(true)


    core:add_listener(
        "pttg_UI_button",
        "ComponentLClickUp",
        function(context)
            return context.string == "pttg_map_button"
        end,
        function(context)
            core:get_tm():real_callback(function()
                local parent = core:get_ui_root()

                local map_ui = find_uicomponent(parent, "pttg_map")
                if map_ui:Visible() then
                    self:hide_map()
                    return
                end

                self:show_map()
            end, 5, "pttg_map_button")
        end,
        true
    )

    return map_button
end

function pttg_UI:get_or_create_next_phase()
    pttg:log("Getting/Creating Next Phase Button")
    local root = core:get_ui_root()
    local end_turn_docker = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "end_turn_docker")
    
    if not end_turn_docker then
        script_error("Could not find the faction buttons! How can this be?")
        return
    end

    local pttg_next_phase = find_uicomponent(end_turn_docker, "pttg_next_phase")
    if pttg_next_phase then
        return pttg_next_phase
    end

    pttg_next_phase = core:get_or_create_component("pttg_next_phase", "ui/templates/round_extra_large_button", end_turn_docker)
    local end_turn_button = find_uicomponent(end_turn_docker, "button_end_turn")

    end_turn_button:SetVisible(false)
    pttg_next_phase:SetDockingPoint(9)

    pttg_next_phase:SetImagePath("ui/skins/default/button_indicator_arrow_active.png")
    pttg_next_phase:SetTooltipText("Proceed to the next phase.", true)

    return pttg_next_phase
end

function pttg_UI:ui_created()
    pttg:log("[pttg_ui] Creating UI")
    
    self:get_or_create_next_phase()

    pttg:log("[pttg_ui] Creating The Path")
    self:get_or_create_map()

    self:get_or_create_map_button()
end

function pttg_UI:disable_next_phase_button()
    pttg:log("[pttg_ui] Disabling next phase button.")
    local phase_button = self:get_or_create_next_phase()


    if not phase_button then
        pttg:log("[pttg_ui] Could not find next phase button.")
        return
    end
    phase_button:SetDisabled(true)
    phase_button:SetState('inactive')
end

function pttg_UI:enable_next_phase_button()
    pttg:log("[pttg_ui] Highlighting next phase button.")
    local phase_button = self:get_or_create_next_phase()

    if not phase_button then
        pttg:log("[pttg_ui] Could not find next phase button.")
        return
    end
    phase_button:SetDisabled(false)
    phase_button:SetState('active')
end

function pttg_UI:center_camera()
    cm:callback(
        function()
            local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
            common.call_context_command("CcoCampaignCharacter", character:command_queue_index(), "SelectAndZoom(false)")
        end,
        0.2
    )
end

function pttg_UI:disable_event_feed()
    local events = {
        "character_dies_battle",
        "diplomacy_faction_destroyed",
        "agent_recruited",
        "diplomacy_trespassing",
        "conquest_battle",
        "character_ancillary_lost",
        "character_ancillary_lost_stolen",
        "faction_ancillary_gained_stolen",
        "military_unit_recruited",
        "diplomacy_faction_encountered",
        "diplomacy_faction_emerges",
        "character_rank_gained",
        "mercenary_unit_character_level_restriction_lifted"
    }
    
    for _, event in pairs(events) do
        cm:disable_event_feed_events(true, "", "", event)
    end
end

function pttg_UI:highlight_recruitment(should_highlight)
    pttg:log("Setting Recruitment highlight to: "..tostring(should_highlight))
    local root = core:get_ui_root()
    local army_buttons = find_uicomponent(root, "hud_campaign", "hud_center_docker", "small_bar",
        "button_subpanel_parent", "button_subpanel", "button_group_army")
    if not army_buttons then
        pttg:log("Could not find army buttons. Not highlighting.")
        return
    end
    local pttg_recruit = find_uicomponent(army_buttons, "mercenary_recruitment_button_container", "button_mercenary_recruit_pttg_raise_dead")
    if pttg_recruit then
        pttg_recruit:Highlight(should_highlight, true)
    end
end

function pttg_UI:hide_faction_buttons()
    local root = core:get_ui_root()
    local faction_buttons = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management")
    
    if not faction_buttons then
        script_error("Could not find the faction buttons! How can this be?")
        return
    end

    for i = 0, faction_buttons:ChildCount() - 1 do
		local uic_child = UIComponent(faction_buttons:Find(i));
		if pttg_UI.faction_buttons[uic_child:Id()] then
            uic_child:SetVisible(false)
        end
	end;

    -- TODO: instead of hiding, make use of notifications for leftover upgrades/recruitments
    local notification_frame = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "notification_frame");
    if notification_frame then
        notification_frame:SetVisible(false)
    end
end

function pttg_UI:highlight_event_accept(should_highlight)
    local root = core:get_ui_root()
    local accept_button = find_uicomponent(root, "events", "button_set", "accept_holder", "button_accept")

    if accept_button then
        accept_button:Highlight(should_highlight)
    end
end

core:add_listener(
    "pttg_UI_button_listener",
    "ComponentLClickUp",
    function(context)
        return context.string == "pttg_map_close"
    end,
    function(context)
        pttg_UI:hide_map()
        local map_button = pttg_UI:get_or_create_map_button()
        if map_button then
            map_button:SetState('active')
        end
    end,
    true
)


core:add_listener(
    "pttg_next_phase_listener",
    "ComponentLClickUp",
    function(context)
        return "pttg_next_phase" == context.string
    end,
    function(context)
        pttg:log("[pttg_ui] Next phase triggered")

        local uim = cm:get_campaign_ui_manager();
        if uim:get_open_blocking_panel() then
            return
        end

        pttg_UI:disable_next_phase_button()
        pttg_shop:disable_shop_button()

        local cur_phase = pttg:get_state("cur_phase")

        if cur_phase == "pttg_Idle" then
            if pttg:get_state("pending_reward") then
                pttg:log("[pttg_ui] Pending reward found. Triggering rewards")
                local im = cm:get_intervention_manager()
                if im:is_another_intervention_queued() then
                    im:start_next_intervention(true)
                else
                    core:trigger_custom_event('pttg_Rewards', {})
                end
            else
                if pttg:get_cursor() == nil or pttg:get_cursor().class == pttg_RoomType.BossRoom then
                    pttg:log("[pttg_ui] Triggering start")
                    pttg_UI:destroy_map()
                    pttg_UI:get_or_create_map()
                    core:trigger_custom_event('pttg_ChooseStart', {})
                    return
                end

                core:trigger_custom_event('pttg_ChoosePath', {})
            end
        elseif cur_phase == "pttg_ResolveRoom" then
            -- If next phase is trigered but the battle is not completed, assume a misfire of the post-battle completion.
            if pttg:get_state("battle_ongoing") then
                cm:trigger_incident(cm:get_local_faction_name(), pttg:get_state("battle_ongoing"), true)
            else
                core:trigger_custom_event(cur_phase, {})
            end
        else -- assume we're stuck in a phase where an intervention misfired
            core:trigger_custom_event(cur_phase, {})
        end
    end,
    true
)

core:add_listener(
    "pttg_next_phase_button_listener",
    "PanelOpenedCampaign",
    true,
    function(context)
        pttg:log("[pttg_ui] panel opened: "..context.string)

        pttg_UI:hide_faction_buttons()

        local uim = cm:get_campaign_ui_manager();
        if uim:get_open_blocking_panel() then
            pttg_UI:disable_next_phase_button()
            return
        end

        local events = find_uicomponent("events", "event_layouts")
        if events and events:Visible() then
            pttg_UI:disable_next_phase_button()
            return
        end
    end,
    true
)

core:add_listener(
    "pttg_next_phase_button_listener",
    "PanelClosedCampaign",
    true,
    function()
        pttg:log("[pttg_ui] panel closed.")

        pttg_UI:hide_faction_buttons()

        local uim = cm:get_campaign_ui_manager();
        if uim:get_open_blocking_panel() then
            return
        end

        local events = find_uicomponent("events", "event_layouts")
        if events and events:Visible() then
            return
        end

        pttg_UI:enable_next_phase_button()
    end,
    true
)

core:add_listener(
    "pttg_highlight_recruitment",
    "pttg_recruit_reward",
    true,
    function(context)
        pttg_UI:highlight_recruitment(true)
        pttg_UI:disable_next_phase_button()
    end,
    true
)

core:add_listener(
    "pttg_highlight_recruitment",
    "PanelOpenedCampaign",
    function(context)
        return context.string == "mercenary_recruitment"
    end,
    function(context)
        pttg_UI:highlight_recruitment(false)
    end,
    true
)

core:add_listener(
    "pttg_UI",
    "pttg_init_complete",
    true,
    function(context)
        pttg_UI:init()
    end,
    false
)

function pttg_UI:hide_flesh_lab_upgrades()
    local scrap_upgrades = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "scrap_upgrades")
    if not scrap_upgrades then
        return
    end
    local scrap_upgrades_unit_panel = find_uicomponent(scrap_upgrades, "units_panel_scrap_upgrades")
    if not scrap_upgrades_unit_panel then
        return
    end
    local scrap_upgrades_parent = find_uicomponent(scrap_upgrades_unit_panel, "scrap_upgrades_parent")
    if not scrap_upgrades_parent then
        return
    end
    local list_clip = find_uicomponent(scrap_upgrades_parent, "list_clip")
    if not list_clip then
        return
    end
    local list_box = find_uicomponent(list_clip, "list_box")
    if not list_box then
        return
    end
    local upgrade_count = list_box:ChildCount()

    for i = 0, upgrade_count-1 do 
        local uic = UIComponent(list_box:Find(i))

        if uic:Id():find("flesh_lab") then
            uic:SetVisible(false)
            upgrade_count = upgrade_count - 1
        end
    end
    local new_height = 90 * (upgrade_count - 1)

    scrap_upgrades:SetCanResizeHeight(true)
    local width, height = scrap_upgrades:Dimensions()
    scrap_upgrades:Resize(width, new_height)

    scrap_upgrades_unit_panel:SetCanResizeHeight(true)
    local width, height = scrap_upgrades_unit_panel:Dimensions()
    scrap_upgrades_unit_panel:Resize(width, new_height)

    scrap_upgrades_parent:SetCanResizeHeight(true)
    local width, height = scrap_upgrades_parent:Dimensions()
    scrap_upgrades_parent:Resize(width, new_height)

    list_clip:SetCanResizeHeight(true)
    local width, height = list_clip:Dimensions()
    list_clip:Resize(width, new_height)
end

core:add_listener(
    "pttg_scrap_upgrades",
    "ComponentLClickUp",
    function(context)
        return context.string == "button_purchasable_effects"
    end,
    function(context)

        cm:callback(
            function(context)
                pttg_UI:hide_flesh_lab_upgrades()
                cm:callback(pttg_UI.hide_flesh_lab_upgrades, 0.1)
            end,
            0.05
        )
        
    end,
    true
)

function pttg_UI:highlight_upgrade()
    local function highlight_button()

        if pttg_glory:get_training_glory() == 0 then
            core:remove_listener("pttg_highlight_upgrade_button")
            return
        end
        
        
        local events = find_uicomponent(core:get_ui_root(), "events")
        if events and events:Visible() then
            return
        end

        local units_uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "units")
        if not units_uic then
            return
        end

        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
        local char_count = force:character_list():num_items()

        local unit_count = units_uic:ChildCount() - 1
        local random_unit_uic = find_uicomponent(units_uic, "LandUnit "..tostring(cm:random_number(unit_count, char_count)))
        if not random_unit_uic then
            return
        end

        

        random_unit_uic:Highlight(true, true)

        cm:callback(
            function()
                random_unit_uic:Highlight(false)
            end,
            2
        )

        core:add_listener(
            "pttg_unstuck_mouse",
            "ComponentLClickUp",
            function(context)
                return context.string == random_unit_uic:Id()
            end,
            function (context)
                cm:callback(
                    function()
                        local panel = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel")
                        local button = find_uicomponent(panel, "button_group_unit", "button_purchasable_effects")
                        if button then
                            button:Highlight(true)

                            core:remove_listener("pttg_highlight_upgrade_button")
            
                            cm:callback(
                                function()
                                    button:Highlight(false)
                                    cm:set_saved_value("pttg_upgrade_highlight_shown", true)
                                end,
                                2
                            )
                        end
                    end,
                    0.4
                )
            end,
            false
        )
    end

    core:add_listener(
        "pttg_highlight_upgrade_button",
        "PanelOpenedCampaign",
        function(context)
            return context.string == "units_panel" and pttg:get_state("cur_phase") == "pttg_Idle"
        end,
        function(context)
            cm:callback(highlight_button, 0.4)
        end,
        true
    )
end

function pttg_UI:show_custom_effect_bundle()
    local enemy_uic = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "enemy_combatants_panel")
    if not enemy_uic then
        return
    end

    local character_cco = cco("CcoCampaignCharacter", enemy_uic:GetContextObjectId("CcoCampaignCharacter"))
    -- local effect_bundles = character_cco:Call("MilitaryForceContext.EffectBundleList")
    local effect_bundles = character_cco:Call("EffectBundleList")

    local effect_subpanel = find_uicomponent(enemy_uic, "army", "effect_bundles_docker_enemy", "subpanel_effect_bundles")
    local effect_docker = find_uicomponent(effect_subpanel, "effect_background")
    local effect_list = find_uicomponent(effect_docker, "effect_list")

    if not (effect_subpanel and effect_docker and effect_list) then
        return
    end

    if #effect_bundles > 0 then
        effect_subpanel:SetVisible(true)
        effect_docker:SetVisible(true)
        effect_list:SetVisible(true)
    end

    for _, effect_bundle in pairs(effect_bundles) do
        local custom_effect_address = effect_list:CreateComponent("custom_effect_"..effect_bundle:Call("Name"), "ui/templates/effect_bundle_entry.twui.xml")
        local custom_effect = UIComponent(custom_effect_address)

        custom_effect:SetContextObject(effect_bundle)
        custom_effect:SetImagePath(effect_bundle:Call("IconPath"))

        custom_effect:Layout()
    end


end

core:add_listener(
    "pttg_show_army_effect_bundles",
    "PanelOpenedCampaign",
    function(context)
        return context.string == "popup_pre_battle"
    end,
    function(context)
        cm:callback(pttg_UI.show_custom_effect_bundle, 0.4)
    end,
    true
)


core:add_static_object("pttg_UI", pttg_UI);


