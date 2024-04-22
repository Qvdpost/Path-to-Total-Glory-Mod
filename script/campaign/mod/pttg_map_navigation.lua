local pttg = core:get_static_object("pttg");


core:add_listener(
    "start_chosen",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChooseStart'
    end,
    function(context)
        pttg:log("[PathToTotalGlory] initialising cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local choices = {
            ['FIRST'] = 1,
            ['SECOND'] = 2,
            ['THIRD'] = 3,
            ['FOURTH'] = 4
        }
        
        local choice = choices[context:choice_key()]
        local cursor = pttg:get_cursor()
        local act = 1
        if cursor then
           act = cursor.z + 1
        end
        
        
        for _, node in pairs(pttg:get_state('maps')[act][1]) do
            if node:is_connected() then
                choice = choice - 1
                if choice == 0 then
                    pttg:set_cursor(pttg:get_state('maps')[act][1][node.x])
                    pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
                    core:trigger_custom_event('pttg_phase2', {})
                    return true
                end
            end
        end
        
        -- If there's less than 4 choices, and the player chose an index beyond available options.
        choice = choices[context:choice_key()] - choice
        
        for _, node in pairs(pttg:get_state('maps')[act][1]) do
            if node:is_connected() then
                choice = choice - 1
                if choice == 0 then
                    pttg:set_cursor(pttg:get_state('maps')[act][1][node.x])
                    pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
                    core:trigger_custom_event('pttg_phase2', {})
                    return true
                end
            end

        end
        
        return false
        
    end,
    false
)

core:add_listener(
    "path_chose_LMR",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePathLMR'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_ChoosePathLMR] updating cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local node = pttg:get_cursor()
        
        if context:choice_key() == 'FIRST' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x - 1])
        elseif context:choice_key() == 'SECOND' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x])
        else
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x + 1])
        end
        
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        core:trigger_custom_event('pttg_phase2', {})
        
        return true
    end,
    true
)

core:add_listener(
    "path_chose_LM",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePathLM'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_ChoosePathLM] updating cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local node = pttg:get_cursor()
        
        if context:choice_key() == 'FIRST' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x - 1])
        elseif context:choice_key() == 'SECOND' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x])
        end
        
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        core:trigger_custom_event('pttg_phase2', {})
        
        return true
    end,
    true
)

core:add_listener(
    "path_chose_MR",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePathMR'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_ChoosePathMR] updating cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local node = pttg:get_cursor()
        
        if context:choice_key() == 'FIRST' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x + 1])
        elseif context:choice_key() == 'SECOND' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x])
        end
        
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        core:trigger_custom_event('pttg_phase2', {})
        
        return true
    end,
    true
)

core:add_listener(
    "path_chose_LR",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePathLR'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_ChoosePathLR] updating cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local node = pttg:get_cursor()
        
        if context:choice_key() == 'FIRST' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x - 1])
        elseif context:choice_key() == 'SECOND' then
            pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.x + 1])
        end
        
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        
        core:trigger_custom_event('pttg_phase2', {})
        
        return true
    end,
    true
)

core:add_listener(
    "path_chose_L/M/R",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePathL' or context:dilemma() == 'pttg_ChoosePathM' or context:dilemma() == 'pttg_ChoosePathR'
    end,
    function(context)

        pttg:log("[PathToTotalGlory][pttg_ChoosePathL/M/R] updating cursor: ")
        
        pttg:log(string.format("Choice: %s", context:choice_key()))
        
        local node = pttg:get_cursor()
                
        pttg:set_cursor(pttg:get_state('maps')[node.z][node.y + 1][node.edges[1].dst_x])
        
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        
        core:trigger_custom_event('pttg_phase2', {})
        
        return true
    end,
    true
)

