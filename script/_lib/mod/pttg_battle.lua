local pttg = core:get_static_object("pttg");

pttg_battle = {
    intial_wom_reserves = nil,
    completed_wom_reserves = nil,
    spent_wom_reserves = nil,
}

function pttg_battle:battle_started()
    pttg:log("Battle started")
    -- setup any varaibles requried to track battle performance.
    local battle = cco("CcoBattleRoot", "CcoBattleRoot")
    local player_context = battle:Call("PlayerArmyContext")
    local player_wom = player_context:Call("WindsOfMagicPoolContext")
    
    pttg_battle.intial_wom_reserves = player_wom:Call("ReserveWind")
end

function pttg_battle:battle_ended()
    pttg:log("Battle ended")
    -- setup any varaibles requried to track battle performance.
    local battle = cco("CcoBattleRoot", "CcoBattleRoot")
    local player_context = battle:Call("PlayerArmyContext")
    local player_wom = player_context:Call("WindsOfMagicPoolContext")
    
    self.completed_wom_reserves = player_wom:Call("ReserveWind") + player_wom:Call("CurrentWind")
    self.spent_wom_reserves = math.max(self.intial_wom_reserves - self.completed_wom_reserves, 0)
    
    core:svr_save_string("spent_wom_reserves", tostring(pttg_battle.spent_wom_reserves))
    pttg:log("Spent WoM: "..tostring(pttg_battle.spent_wom_reserves))
end

local function pttg_battle_init()
    local wom = core:svr_load_string("spent_wom_reserves")

    if wom then
        pttg:log("Setting spent wom reserves to: "..wom)
        pttg_battle.spent_wom_reserves = tonumber(wom)
    end
end

if core:is_campaign() then
    cm:add_first_tick_callback(pttg_battle_init)
end

core:add_static_object("pttg_battle", pttg_battle);
