local out = function (t)
    out("Quinner: "..tostring(t).." (glory_ui.lua)")
end

local pooled_resource_key = "pttg_glory_points"


local function get_or_create_pooled_resource_ui()
    -- :root:hud_campaign:resources_bar_holder:resources_bar
    local resource_bar = find_uicomponent(core:get_ui_root(), "hud_campaign", "resources_bar_holder", "resources_bar")
    if not resource_bar then
        out("Could not find resource bar")
        return
    end
    local existing_prui = find_uicomponent(resource_bar, pooled_resource_key.."_holder")
    if existing_prui then
        out("Found existing pooled resource UI")
    else
        out("Creating a PR UI for "..pooled_resource_key)
        local prui = UIComponent(resource_bar:CreateComponent(pooled_resource_key.."_holder", "ui/campaign ui/custom_"..pooled_resource_key.."_holder"))
        prui:SetContextObject(cco("CcoCampaignFaction", cm:get_local_faction_name(true)))
        prui:SetVisible(true)
    end
end

local function pooled_resource_check_callback()
    local local_faction = cm:get_local_faction_name(true)
    local ok, err = pcall(get_or_create_pooled_resource_ui)
    if not ok then
        out("Error in pooled_resource_check_callback: "..tostring(err))
    end
end

cm:add_first_tick_callback(function ()
    core:progress_on_loading_screen_dismissed(function ()
        cm:real_callback(pooled_resource_check_callback, 500, "add_pooled_resource_ui")
    end)
    
    core:add_listener(
        "pooled_resource_check",
        "pttg_Idle",
        true,
        pooled_resource_check_callback,
        true)
end)