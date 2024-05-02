local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")

function pttg_EventGlory_callback(context)
    if context:choice_key() == 'FIRST' then
        pttg_glory:reward_glory(15)
    elseif context:choice_key() == 'SECOND' then
        pttg_glory:reward_glory(30)
        pttg:set_state('alignment', pttg:get_state('alignment') + 15)
    end
end

function pttg_EventGlory_eligibility_callback(context)
    
    if context.act ~= 1 and context.act ~= 2 then
        return false
    end

    -- if context.alignment > 20 then
    --     return false
    -- end

    local faction_set = 'all'
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    return true
end
