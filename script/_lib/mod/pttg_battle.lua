local pttg = core:get_static_object("pttg");

pttg_battle = {
    completed_wom_reserves = nil
}

function pttg_battle:battle_started()
    pttg:log("Battle started")
    -- setup any varaibles requried to track battle performance.
end

function pttg_battle:battle_ended()
    pttg:log("Battle ended")
    -- setup any varaibles requried to track battle performance.
    local battle = cco("CcoBattleRoot", "CcoBattleRoot")
    local player_context = battle:Call("PlayerArmyContext")
    local player_wom = player_context:Call("WindsOfMagicPoolContext")
    
    pttg_battle.completed_wom_reserves = player_wom:Call("ReserveWind") + player_wom:Call("CurrentWind")
    
    core:svr_save_string("completed_wom_reserves", tostring(pttg_battle.completed_wom_reserves))
    pttg:log("Final WoM: "..tostring(pttg_battle.completed_wom_reserves))
end

local function pttg_battle_init()
    local wom = core:svr_load_string("completed_wom_reserves")

    if wom then
        pttg:log("Setting completed wom reserves to: "..wom)
        pttg_battle.completed_wom_reserves = tonumber(wom)
    end
end

if core:is_campaign() then
    cm:add_first_tick_callback(pttg_battle_init)
end

core:add_static_object("pttg_battle", pttg_battle);
