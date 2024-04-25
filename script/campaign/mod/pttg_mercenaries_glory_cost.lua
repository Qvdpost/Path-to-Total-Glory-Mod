local ttc = core:get_static_object("tabletopcaps");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool");
local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")


local available_merc_units = {}
local merc_in_queue = {}

local function init_glory_units()
    pttg_merc_pool = core:get_static_object("pttg_merc_pool");
    pttg = core:get_static_object("pttg");

    -- Disable TTC MercPanel Listeners
    ttc.add_listeners_to_mercenary_panel = function() return nil end
end

local function hide_disabled()
    pttg:log("[pttg_glory_cost] - Hiding disabled units.")
    local recruitment_uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "recruitment_docker",
        "recruitment_options", "mercenary_display")
    if recruitment_uic then
        local unit_list = find_uicomponent(recruitment_uic, "mercenary_display", "frame")
        local listview_uic = find_uicomponent(unit_list, "listview")
        local list_clip_uic = find_uicomponent(listview_uic, "list_clip")
        local list_box_uic = find_uicomponent(list_clip_uic, "list_box")

        for unit, unit_info in pairs(pttg_merc_pool.merc_units) do
            local reference_unit = unit .. "_mercenary"
            local unit_uic = find_uicomponent(list_box_uic, reference_unit)

            if unit_uic then
                if unit_uic:CurrentState() == "active" then
                    pttg:log(string.format("[pttg_glory_cost] - Adding %s to available mercs.", unit))
                    available_merc_units[unit] = unit_info
                else
                    unit_uic:SetVisible(false)
                    unit_uic:SetDisabled(true)
                end
            end
        end
    end
end

local function finalise_uics()
    pttg:log("[pttg_glory_cost] - Handling components.")

    local recruitment_uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "recruitment_docker",
        "recruitment_options", "mercenary_display")
    if recruitment_uic then
        for unit, unit_info in pairs(available_merc_units) do
            pttg:log("[pttg_glory_cost] - Available Merc: " .. string.format("%s (%s)", unit, unit_info.cost))
            local glory_cost = unit_info.cost
            local listview_uic = find_uicomponent(recruitment_uic, "frame", "listview")
            local unit_uic = find_uicomponent(listview_uic, "list_clip", "list_box", unit .. "_mercenary")

            if unit_uic then
                local recruitment_cost_uic = find_uicomponent(unit_uic, "unit_icon", "RecruitmentCost")

                if recruitment_cost_uic then
                    recruitment_cost_uic:SetVisible(false)
                end

                local faction = cm:get_faction(cm:get_local_faction_name(true))
                local player_glory = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()

                if player_glory >= glory_cost then
                    -- setting cost text
                    unit_uic:SetState("active")
                    unit_uic:SetDisabled(false)

                    pttg:log("[pttg_glory_cost] - Enabling component: " .. unit)
                else
                    -- setting cost text
                    local unit_uic_tooltip = unit_uic:GetTooltipText()
                    local cannot_recruit_loc = common.get_localised_string(
                        "random_localisation_strings_string_StratHudbutton_Cannot_Recruit_Unit0")
                    local insufficient_gl_loc = common.get_localised_string("pttg_insufficient_pttg_glory_tooltip")
                    local unit_uic_tooltip_gsub = unit_uic_tooltip:gsub('[%W]', '')
                    local left_click_loc_gsub = (common.get_localised_string("random_localisation_strings_string_StratHud_Unit_Card_Recruit_Selection"))
                        :gsub('[%W]', '')

                    if string.match(unit_uic_tooltip_gsub, left_click_loc_gsub) then
                        unit_uic:SetTooltipText(cannot_recruit_loc .. "\n\n" .. insufficient_gl_loc, "", true)
                        pttg:log("[pttg_glory_cost] - Tooltip for just insufficient glory.")
                    else
                        unit_uic:SetTooltipText(unit_uic_tooltip .. "\n" .. insufficient_gl_loc, "", true)
                        pttg:log("[pttg_glory_cost] - Tooltip for glory plus stuff.")
                    end

                    -- disabling recruitment of unit
                    pttg:log("[pttg_glory_cost] - Disabling component: " .. unit)
                    unit_uic:SetState("inactive")
                    unit_uic:SetDisabled(true)
                end
            end
        end
    end
end



local function glory_cost_listeners()
    core:add_listener(
        "pttg_MercPanelOpened",
        "PanelOpenedCampaign",
        function(context)
            return context.string == "mercenary_recruitment"
        end,
        function()
            pttg:log("[pttg_glory_cost] - mercenary_recruitment panel opened.")

            pttg:log(string.format("Refunding %i mercenaries.", #merc_in_queue))
            for int_pos, merc in pairs(merc_in_queue) do
                local unit_record = pttg_merc_pool.merc_units[merc]

                pttg_glory:add_recruit_glory(unit_record.cost)
                table.remove(merc_in_queue, int_pos)
            end

            hide_disabled()
            finalise_uics()
        end,
        true
    )

    --when a mercenary is added to queue, apply cost.
    core:add_listener(
        "pttg_glory_merc_shop",
        "ComponentLClickUp",
        function(context)
            return ttc.is_merc_panel_open()
        end,
        function(context)
            local uic = UIComponent(context.component)
            local pin = find_uicomponent(uic, "pin_parent", "button_pin")
            if pin and string.find(pin:CurrentState(), "hover") then return end
            local component_id = tostring(uic:Id())
            pttg:log("Click detected " .. tostring(component_id))
            --is our clicked component a unit?

            if component_id == "button_hire_mercenary" then
                pttg:log("Mercenaries hired. Clearing queue.")
                for int_pos, merc in pairs(merc_in_queue) do
                    table.remove(merc_in_queue, int_pos)
                end
            elseif string.find(component_id, "_mercenary") and not uic:IsDisabled() then
                pttg:log("Component Clicked was a mercenary")
                local unit_key = string.gsub(component_id, "_mercenary", "")


                merc_in_queue[#merc_in_queue + 1] = unit_key
                local armyList = find_uicomponent_from_table(core:get_ui_root(),
                    { "units_panel", "main_units_panel", "units" })
                local merc = find_uicomponent(armyList, "temp_merc_" .. tostring(#merc_in_queue - 1))
                if merc ~= false then
                    pttg:log("The new queued mercenary appeared")
                    local unit_record = pttg_merc_pool.merc_units[unit_key]
                    pttg_glory:remove_recruit_glory(unit_record.cost)
                else
                    pttg:log("No queued mercenary appeared - it probably isn't a valid click")
                    merc_in_queue[#merc_in_queue] = nil
                end
                finalise_uics()
            end
        end,
        true);

    --When a mercenary is removed from queue, refund.
    core:add_listener(
        "pttg_glory_merc_shop",
        "ComponentLClickUp",
        function(context)
            return ttc.is_merc_panel_open()
        end,
        function(context)
            --# assume context: CA_UIContext
            local component = UIComponent(context.component)
            local component_id = tostring(component:Id())
            if string.find(component_id, "temp_merc_") and not component:IsDisabled() then
                local position = component_id:gsub("temp_merc_", "")
                pttg:log("Component Clicked was a Queued Mercenary Unit @ [" .. position .. "]!")

                local int_pos = math.floor(tonumber(position) + 1)
                local unit_key = merc_in_queue[int_pos]
                local unit_record = pttg_merc_pool.merc_units[unit_key]
                pttg:log("Component Clicked was Mercenary [" .. unit_key .. "]")

                pttg_glory:add_recruit_glory(unit_record.cost)

                table.remove(merc_in_queue, int_pos)
                finalise_uics()
            end
        end,
        true);
end

cm:add_first_tick_callback(function() init_glory_units() end)
cm:add_first_tick_callback(function() glory_cost_listeners() end)
