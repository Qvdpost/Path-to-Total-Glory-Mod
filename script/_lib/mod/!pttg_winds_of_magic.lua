local pttg = core:get_static_object("pttg");

local pttg_mod_wom = {

}

function pttg_mod_wom:increase(change)
    if change <= 0 then
        return false
    end
    pttg:log("[pttg_WoM] Increasing Winds of Magic by %s", tostring(change))

    local womcident = cm:create_incident_builder("pttg_WoM_increase")

    local womload = cm:create_payload()

    womload:military_force_pooled_resource_transaction(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')),
        'wh3_main_winds_of_magic', 'winds_of_magic_positive', change, true)
    womcident:set_payload(womload)

    womcident:add_target('target_military_1')

    cm:launch_custom_incident_from_builder(womcident, cm:get_local_faction())
end

function pttg_mod_wom:decrease(change)
    if change <= 0 then
        return false
    end
    pttg:log("[pttg_WoM] Decreasing Winds of Magic by %s", tostring(change))

    local womcident = cm:create_incident_builder("pttg_WoM_decrease")

    local womload = cm:create_payload()

    womload:military_force_pooled_resource_transaction(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')),
        'wh3_main_winds_of_magic', 'winds_of_magic_positive', -change, true)
    womcident:set_payload(womload)

    womcident:add_target('target_military_1')

    cm:launch_custom_incident_from_builder(womcident, cm:get_local_faction())
end

core:add_static_object("pttg_mod_wom", pttg_mod_wom);
