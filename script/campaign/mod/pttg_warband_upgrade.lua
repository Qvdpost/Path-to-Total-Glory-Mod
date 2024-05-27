local pttg = core:get_static_object("pttg");

local pttg_warband_upgrade = {

}

function pttg_warband_upgrade:get_or_create_pooled_resource_ui()
    local pooled_resource_key = "pttg_warband_upgrade_glory"

    local resource_bar = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "warband_upgrades_docker","warband_upgrades", "warbands_header")
    if not resource_bar then
        pttg:log("Could not find resource bar")
        return
    end
    local existing_prui = find_uicomponent(resource_bar, pooled_resource_key.."_holder")
    if existing_prui then
        pttg:log("Found existing pooled resource UI")
        return existing_prui
    else
        pttg:log("Creating a PR UI for "..pooled_resource_key)
        local prui = UIComponent(resource_bar:CreateComponent(pooled_resource_key.."_holder", "ui/campaign ui/custom_"..pooled_resource_key.."_holder"))
        prui:SetContextObject(cco("CcoCampaignFaction", cm:get_local_faction_name(true)))
        prui:SetVisible(true)
        prui:MoveTo(358, 94)
        return prui
    end
end

function pttg_warband_upgrade:highlight_warband(should_highlight)
    pttg:log("Setting Warband Upgrade highlight to: "..tostring(should_highlight))
    local root = core:get_ui_root()
    local army_buttons = find_uicomponent(root, "hud_campaign", "hud_center_docker", "small_bar",
        "button_subpanel_parent", "button_subpanel", "button_group_army")
    if not army_buttons then
        pttg:log("Could not find army buttons. Not highlighting.")
        return
    end
    local button = find_uicomponent(army_buttons, "button_warbands_upgrade")
    if button then
        button:Highlight(should_highlight, true)
    end
end

function pttg_warband_upgrade:update_warband_glory()
    local glory_uic = pttg_warband_upgrade:get_or_create_merchant_glory()
    if glory_uic then
        glory_uic:SetStateText(tostring(pttg_glory:get_warband_glory_value()), "")
    end
end

core:add_listener(
    "pttg_WarbandUpgradePanelOpened",
    "PanelClosedCampaign",
    function(context)
        return context.string == "recruitment_options"
    end,
    function()
        local warband_display = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "warband_upgrades_docker", "warband_upgrades")
        
        if (is_uicomponent(warband_display) and warband_display:Visible(true)) then
            pttg:log("[pttg_warband_upgrade] - warband upgrades panel opened.")

            pttg_warband_upgrade:get_or_create_pooled_resource_ui()

            pttg_warband_upgrade:highlight_warband(false)
        end

    end,
    true
)

core:add_listener(
    "pttg_WarbandUpgradePurchased",
    "UnitEffectPurchased",
    true,
    function(context)
        pttg:log("Upgrading Warband Glory for upgrade: ", context:unit():unit_key())
        pttg_warband_upgrade:update_warband_glory()
    end,
    true
)

core:add_static_object("pttg_warband_upgrade", pttg_warband_upgrade);
