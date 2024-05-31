local pttg = core:get_static_object("pttg");

local pttg_mod_wom = {

}

function pttg_mod_wom:increase(change)
    if change <= 0 then
        return false
    end
    pttg:log("[pttg_WoM] Increasing Winds of Magic by " .. tostring(change))

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local wom = force:pooled_resource_manager():resource("wh3_main_winds_of_magic")
    
    cm:pooled_resource_factor_transaction(wom, "winds_of_magic_positive", change)
end

function pttg_mod_wom:decrease(change)
    if change <= 0 then
        return false
    end
    pttg:log("[pttg_WoM] Decreasing Winds of Magic by " .. tostring(change))

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local wom = force:pooled_resource_manager():resource("wh3_main_winds_of_magic")
    
    cm:pooled_resource_factor_transaction(wom, "winds_of_magic_negative", -change)
end

function pttg_mod_wom:set_wom(amount)
    -- TODO: find actual max amount
    pttg:log("Setting Winds of Magic to: "..tostring(amount))
    amount = math.clamp(amount, pttg:get_state("wom_lower_threshold"), pttg:get_state("wom_upper_threshold"))

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local wom = force:pooled_resource_manager():resource("wh3_main_winds_of_magic")
    local current_wom = wom:value()
    
    cm:pooled_resource_factor_transaction(wom, "winds_of_magic_positive", amount - current_wom)
end

core:add_static_object("pttg_mod_wom", pttg_mod_wom);
