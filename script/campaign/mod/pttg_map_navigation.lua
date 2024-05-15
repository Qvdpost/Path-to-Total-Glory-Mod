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
            ['FOURTH'] = 4,
            ['FIFTH'] = 5,
            ['SIXTH'] = 6,
            ['SEVENTH'] = 7,
        }

        local choice = choices[context:choice_key()]
        local cursor = pttg:get_cursor()
        local act = 1
        if cursor then
            act = cursor.z + 1
        end

        pttg:set_cursor(pttg:get_state('maps')[act][1][choice])
        pttg:log("[PathToTotalGlory] Cursor set: " .. pttg:get_cursor():repr())
        core:trigger_custom_event('pttg_ResolveRoom', {})

        return true
    end,
    true
)

core:add_listener(
    "path_chose_path",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChoosePath'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_ChoosePath] updating cursor: ")

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
        core:trigger_custom_event('pttg_ResolveRoom', {})

        return true
    end,
    true
)