local pttg_UI = {}
local pttg = core:get_static_object("pttg");
local pttg_shop = core:get_static_object("pttg_glory_shop");

function pttg_UI:init()
    pttg:log("[pttg_ui] Initialising UI and listeners")
    self:ui_created()
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
    if not map_ui then
        script_error("Could not find the map! How can this be?")
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
    local map = pttg:get_state('maps')[act]


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
    local parent = find_uicomponent("menu_bar", "buttongroup")
    local map_button = core:get_or_create_component("pttg_map_button", "ui/templates/round_small_button_toggle", parent)

    map_button:SetImagePath("ui/skins/warhammer3/icon_cathay_compass.png")
    map_button:SetTooltipText(common.get_localised_string("pttg_map_tooltip"), true)
    map_button:SetVisible(true)
    map_button:SetDockingPoint(6)
    map_button:SetDockOffset(map_button:Width() * -2.8, 0)

    core:add_listener(
        "pttg_UI_button",
        "ComponentLClickUp",
        function(context)
            return context.string == "pttg_map_button"
        end,
        function(context)
            core:get_tm():real_callback(function()
                self:show_map()
            end, 5, "pttg_map_button")
        end,
        true
    )

    return map_button
end

function pttg_UI:get_or_create_next_phase()
    local root = core:get_ui_root()
    local faction_buttons = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management")

    if not faction_buttons then
        script_error("Could not find the faction buttons! How can this be?")
        return
    end

    local pttg_next_phase = UIComponent(faction_buttons:CreateComponent("pttg_next_phase",
        "ui/templates/round_hud_button_toggle"))

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
    local root = core:get_ui_root()

    local phase_button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management",
        "pttg_next_phase")

    if not phase_button then
        pttg:log("[pttg_ui] Could not find next phase button.")
        return
    end
    phase_button:SetDisabled(true)
    phase_button:StopPulseHighlight()
    phase_button:Highlight(false)
end

function pttg_UI:enable_next_phase_button()
    pttg:log("[pttg_ui] Highlighting next phase button.")
    local root = core:get_ui_root()

    local phase_button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management",
        "pttg_next_phase")

    if not phase_button then
        pttg:log("[pttg_ui] Could not find next phase button.")
        return
    end

    phase_button:SetDisabled(false)
    phase_button:StartPulseHighlight(2)
    phase_button:Highlight(true)
end

function pttg_UI:center_camera()
    cm:callback( -- we need to wait a tick for this to work, for some reason
        function()
            local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
            cm:replenish_action_points(cm:char_lookup_str(character));
            -- cm:scroll_camera_from_current(false, 1,
            --     { character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0 });

            common.call_context_command("CcoCampaignCharacter", character:command_queue_index(), "SelectAndZoom(false)")
        end,
        0.2
    )
end

function pttg_UI:flush_event_feed()
    
end

core:add_listener(
    "pttg_UI_button_listener",
    "ComponentLClickUp",
    function(context)
        return context.string == "pttg_map_close"
    end,
    function(context)
        pttg_UI:hide_map()
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

        if not cm:get_saved_value("pttg_RandomStart") then
            pttg_UI:hide_map()
            cm:trigger_dilemma(cm:get_local_faction_name(), 'pttg_RandomStart')
            cm:set_saved_value("pttg_RandomStart", true)
            return
        end

        pttg_UI:disable_next_phase_button()
        pttg_shop:disable_shop_button()

        local cur_phase = pttg:get_state("cur_phase")

        if cur_phase == "pttg_Idle" then
            if pttg:get_state("pending_reward") then
                pttg:log("[pttg_ui] Pending reward found. Triggering phase 3")
                core:trigger_custom_event('pttg_Rewards', {})
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
        else -- assume we're stuck in a phase where an intervention misfired
            core:trigger_custom_event(cur_phase, {})
        end
    end,
    true
)

core:add_listener(
    "pttg_PanelOpened",
    "PanelOpenedCampaign",
    true,
    function()
        pttg:log("[pttg_ui] panel opened.")

        pttg_UI:disable_next_phase_button()
    end,
    true
)

core:add_listener(
    "pttg_PanelOpened",
    "PanelClosedCampaign",
    true,
    function()
        pttg:log("[pttg_ui] panel opened.")

        pttg_UI:enable_next_phase_button()
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

core:add_static_object("pttg_UI", pttg_UI);
