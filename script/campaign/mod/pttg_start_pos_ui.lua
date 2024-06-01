local pttg = core:get_static_object("pttg")

local function hide_recruit_buttons()
    local root = core:get_ui_root()
    local army_buttons = find_uicomponent(root, "hud_campaign", "hud_center_docker", "small_bar",
        "button_subpanel_parent", "button_subpanel", "button_group_army")
    if not army_buttons then
        return
    end
    local button_ids = { "button_recruitment", "button_renown", "button_renown", "button_allied_recruitment",
        "button_blessed_spawn_pool", "button_imperial_supplies_pool", "button_contained_army_panel", "button_navy_panel",
        "button_army_panel", "button_setrapy", "button_raise_dead", "button_mercenaries", "button_flesh_lab_pool",
        "button_monster_pen_pool", "button_nurgle_mercenaries", "button_detachments" }
    for _, button_id in pairs(button_ids) do
        local button_uic = find_uicomponent(army_buttons, button_id)
        if button_uic then
            button_uic:SetVisible(false)
        end
    end

    local mercenary_button_ids = { "button_mercenary_recruit_raise_dead", "button_mercenary_recruit_flesh_lab",
        "button_mercenary_recruit_monster_pen", "button_mercenary_recruit_blessed_spawning",
        "button_mercenary_recruit_nurgle_buildings", "button_mercenary_recruit_amethyst_units",
        "button_mercenary_recruit_imperial_supply", "button_mercenary_recruit_dwarf_grudges_units",
        "button_mercenary_recruit_tamurkhan_chieftains", "button_mercenary_recruit_malakai_adventure_units",
        "button_mercenary_recruit_daemonic_summoning", "button_mercenary_recruit_renown",
        "button_mercenary_recruit_mercenary_recruitment", "button_mercenary_recruit_setrapy" }
    for _, button_id in pairs(mercenary_button_ids) do
        local button_uic = find_uicomponent(army_buttons, button_id)
        if button_uic then
            button_uic:SetVisible(false)
        end
    end

    cm:real_callback(
        function() 
            if pttg_glory:get_warband_glory_value() == 0 then
                local button_uic = find_uicomponent(army_buttons, "button_warbands_upgrade")
                if button_uic then
                    button_uic:SetVisible(false)
                end
                local warband_uic = find_uicomponent(root, "units_panel","main_units_panel","warband_upgrades_docker","warband_upgrades")
                if warband_uic then
                    warband_uic:SetVisible(false)
                end
            else
                local button_uic = find_uicomponent(army_buttons, "button_warbands_upgrade")
                if button_uic then
                    button_uic:SetVisible(true)
                end
            end
        end,
        50
    )
end


cm:add_first_tick_callback(
    function()

        core:add_listener(
            "pttg_show_upgrade_button",
            "PanelOpenedCampaign",
            function(context) return context.string == "units_panel" end,
            function(context)
                               
                cm:repeat_callback(
                    function()
                        local uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "button_group_unit", "button_purchasable_effects")
                        if uic and not uic:Visible() then
                            uic:SetVisible(true)
                        end
                    end, 
                    0.05, 
                    "pttg_repeat_show_upgrade_button"
                )
            end,
            true
        )
        
        core:add_listener(
            "pttg_hide_recruit_buttons",
            "PanelOpenedCampaign",
            function(context) return context.string == "units_panel" end,
            function(context)
                hide_recruit_buttons()
                cm:repeat_callback(hide_recruit_buttons, 0.05, "pttg_repeat_hide_recruit_buttons")
            end,
            true
        )
        
        core:add_listener(
            "pttg_hide_recruit_buttons",
            "PanelClosedCampaign",
            function(context) return context.string == "units_panel" end,
            function(context)
                cm:remove_callback("pttg_repeat_hide_recruit_buttons")
                cm:remove_callback("pttg_repeat_show_upgrade_button")
            end,
            true
        )
    end
)