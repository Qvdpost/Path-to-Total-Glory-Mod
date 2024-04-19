local pttg_UI = {}
local pttg = core:get_static_object("pttg");
local pttg_shop = core:get_static_object("pttg_glory_shop");

function pttg_UI:init()
    pttg:log("[pttg_ui] Initialising UI and listeners")
    core:add_ui_created_callback(function()
        self:ui_created()
    end)
end

function pttg_UI:ui_created()
    pttg:log("[pttg_ui] Creating UI")
    local root = core:get_ui_root()
    local faction_buttons = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management")

    local pttg_next_phase = UIComponent(faction_buttons:CreateComponent("pttg_next_phase",
        "ui/templates/round_hud_button_toggle"))

    pttg_next_phase:SetImagePath("ui/skins/default/button_indicator_arrow_active.png")
    pttg_next_phase:SetTooltipText("Proceed to the next phase.", true)
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

core:add_listener(
    "pttg_next_phase_listener",
    "ComponentLClickUp",
    function(context)
        return "pttg_next_phase" == context.string
    end,
    function(context)
        pttg:log("[pttg_ui] Next phase triggered")
        pttg_UI:disable_next_phase_button()
        pttg_shop:disable_shop_button()

        local cur_phase = pttg:get_state("cur_phase")

        if cur_phase == "pttg_idle" then
            if pttg:get_state("pending_reward") then
                pttg:log("[pttg_ui] Pending reward found. Triggering phase 3")
                core:trigger_custom_event('pttg_phase3', {})
            else
                if pttg:get_cursor() == nil then
                    pttg:log("[pttg_ui] Triggering start")
                    core:trigger_custom_event('pttg_phase0', {})
                    return
                end

                core:trigger_custom_event('pttg_phase1', {})
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

pttg_UI:init()

core:add_static_object("pttg_UI", pttg_UI);
