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

                local glory_cost_uic_check = find_uicomponent(unit_uic, "unit_icon", "glory_cost")

                if glory_cost_uic_check == false then
                    UIComponent(recruitment_cost_uic:CopyComponent("glory_cost"))
                end

                -- repositioning cost components
                local glory_cost_parent_uic = find_uicomponent(unit_uic, "unit_icon", "glory_cost")
                local glory_cost_uic = find_uicomponent(glory_cost_parent_uic, "Cost")
                glory_cost_parent_uic:SetDockOffset(8, -5)

                local faction = cm:get_faction(cm:get_local_faction_name(true))
                local player_glory = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()

                if player_glory >= glory_cost then
                    -- setting cost text
                    glory_cost_uic:SetStateText(tostring(glory_cost), "")
                    unit_uic:SetState("active")
                    unit_uic:SetDisabled(false)

                    pttg:log("[pttg_glory_cost] - Enabling component: " .. unit)
                else
                    -- setting cost text
                    glory_cost_uic:SetStateText(tostring("[[col:red]]" .. glory_cost .. "[[/col]]"), "")
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

                -- setting cost icon
                glory_cost_uic:SetImagePath("ui/skins/default/icon_oathgold.png", 0)

                -- setting cost tooltip
                glory_cost_parent_uic:SetTooltipText(common.get_localised_string("pttg_glory_cost_tooltip"), "", true)

                -- setting the cost modified icon to invisible as the CCO is still for recruitment cost so make it appear when intended
                local cost_modified_icon_uic = find_uicomponent(glory_cost_uic, "cost_modified_icon")
                cost_modified_icon_uic:SetVisible(false)
            end
        end
    end
end


local function initialise_uics()
    pttg:log("[pttg_glory_cost] - Initialising components.")

    local recruitment_uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "recruitment_docker",
        "recruitment_options", "mercenary_display")
    if recruitment_uic then
        local recruitment_docker_uic = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel",
            "recruitment_docker")
        local unit_list = find_uicomponent(recruitment_uic, "mercenary_display", "frame")
        local listview_uic = find_uicomponent(unit_list, "listview")
        local hslider_uic = find_uicomponent(listview_uic, "hslider")
        local list_clip_uic = find_uicomponent(listview_uic, "list_clip")
        local list_box_uic = find_uicomponent(list_clip_uic, "list_box")

        -- TODO: Is any of this necessary??

        -- gets the reference unit from the table
        local reference_unit = nil
        for unit, unit_info in pairs(pttg_merc_pool.merc_units) do
            local unit_uic = find_uicomponent(list_box_uic, unit .. "_mercenary")

            if unit_uic then
                reference_unit = unit .. "_mercenary"
                break
            end
        end

        pttg:log("[pttg_glory_cost] - Reference_unit is: " .. tostring(reference_unit))
        if reference_unit ~= nil then
            local unit_uic = find_uicomponent(list_box_uic, reference_unit)
            local recruitment_cost_uic = find_uicomponent(unit_uic, "unit_icon", "RecruitmentCost")

            -- dimensions for resizing components
            local width_rcc, height_rcc = recruitment_cost_uic:Dimensions()

            -- if the slider if there to scroll through multiple units we need to resize things differently
            if hslider_uic then
                -- resizing recruitment_docker
                local width_rdc, height_rdc = recruitment_docker_uic:Dimensions()
                recruitment_docker_uic:SetCanResizeHeight(true)
                recruitment_docker_uic:SetCanResizeWidth(true)
                recruitment_docker_uic:Resize(width_rdc, (height_rdc + (height_rcc * 4)), false)

                -- resizing unit_list
                local width_lrc, height_lrc = unit_list:Dimensions()
                unit_list:SetCanResizeHeight(true)
                unit_list:SetCanResizeWidth(true)
                unit_list:Resize(width_lrc, (height_lrc + (height_rcc * 2)), false)
            else
                -- resizing recruitment_docker
                local width_rdc, height_rdc = recruitment_docker_uic:Dimensions()
                recruitment_docker_uic:SetCanResizeHeight(true)
                recruitment_docker_uic:SetCanResizeWidth(true)
                recruitment_docker_uic:Resize(width_rdc, (height_rdc + (height_rcc * 2)), false)

                -- resizing unit_list
                local width_lrc, height_lrc = unit_list:Dimensions()
                unit_list:SetCanResizeHeight(true)
                unit_list:SetCanResizeWidth(true)
                unit_list:Resize(width_lrc, (height_lrc + height_rcc), false)
            end

            -- resizing list_clip
            local width_lcc, height_lcc = list_clip_uic:Dimensions()
            list_clip_uic:SetCanResizeHeight(true)
            list_clip_uic:SetCanResizeWidth(true)
            list_clip_uic:Resize(width_lcc, (height_lcc + (height_rcc * 2) + 5), false) -- the plus 5 is to make sure there's no clipping at the bottom of the upkeep cost component
        end
    end
    -- handling pr cost components
    pttg:log("[pttg_glory_cost] - finalise_uics() from initialise_uics().")
    finalise_uics()
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

            if cm:get_saved_value("pttg_glory_cost_uics_initialised") ~= true then
                cm:set_saved_value("pttg_glory_cost_uics_initialised", true)
                hide_disabled()
                initialise_uics()
            else
                pttg:log("[pttg_glory_cost] - finalise_uics() from pr_unit_cost_units_recruitment_opened.")
                hide_disabled()
                finalise_uics()
            end
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


    -- handles the saved values
    core:add_listener(
        "pttg_glory_unit_cost_units_panel_closed",
        "PanelClosedCampaign",
        function(context)
            return context.string == "mercenary_recruitment"
        end,
        function(context)
            pttg:log("[pttg_glory_cost] - mercenary_panel panel closed.")
            cm:set_saved_value("pttg_glory_cost_uics_initialised", false)
        end,
        true
    )
end


cm:add_first_tick_callback(function() init_glory_units() end)
cm:add_first_tick_callback(function() glory_cost_listeners() end)
