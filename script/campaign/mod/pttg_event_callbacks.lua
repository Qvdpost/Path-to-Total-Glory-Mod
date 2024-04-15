local pttg = core:get_static_object("pttg");


function pttg_EventGlory_callback(context) 
    if context:choice_key() == 'FIRST' then
        cm:faction_add_pooled_resource(cm:get_local_faction_name(), "pttg_glory_points", "pttg_glory_point_reward", 15) 

    elseif context:choice_key() == 'SECOND' then
        cm:faction_add_pooled_resource(cm:get_local_faction_name(), "pttg_glory_points", "pttg_glory_point_reward", 30) 
        pttg:set_state('alignment', pttg:get_state('alignment') + 15)
    end
end