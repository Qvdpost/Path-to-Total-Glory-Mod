local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_side_effects = core:get_static_object("pttg_side_effects")


local function rest()
    pttg:log("[pttg_RestRoom] Resting troops: ")

    pttg_side_effects:heal_force(pttg:get_state('replenishment_factor'))
    core:trigger_custom_event('pttg_Idle', {})
end

local function upgrade_mercenary()
    pttg:log("[pttg_RestRoom] Upgrading mercenary: ")
    
    local cursor = pttg:get_cursor()
    pttg_glory:add_warband_upgrade_glory(pttg:get_state("add_warband_upgrade_glory")[cursor.z])
    core:trigger_custom_event('pttg_Idle', {})
end

core:add_listener(
    "pttg_RestRoom",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_RestRoom'
    end,
    function(context)
        pttg:log(string.format("[pttg_RestRoom] Choice: %s", context:choice_key()))

        if context:choice_key() == 'FIRST' then
            rest()
        elseif context:choice_key() == 'SECOND' then
            upgrade_mercenary()
        else
            cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_general_training')
        end
    end,
    true
)

core:add_listener(
    "pttg_RestRoom",
    "pttg_rest_room",
    true,
    function(context)
        pttg:log("[pttg_RestRoom] resolving rest: ")

        pttg_upkeep:resolve("pttg_RestRoom")

        cm:trigger_dilemma(cm:get_local_faction():name(), 'pttg_RestRoom')
    end,
    true
)

core:add_listener(
    "pttg_GeneralTraining",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_general_training'
    end,
    function(context)
        pttg:log("[pttg_RestRoom] Training general: ")
        pttg_side_effects:grant_general_levels(5)
        
        local choice = context:choice_key()

        local general = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()

        if choice == 'FIRST' then -- Dueling
            pttg_side_effects:character_melee_mastery_training(general)
        end
        if choice == 'SECOND' then -- Resilience
            pttg_side_effects:character_defense_mastery_training(general)
        end
        if choice == 'THIRD' then -- The Arcane
            pttg_side_effects:character_spell_mastery_training(general)
        end
        if choice == 'FOURTH' then -- Ranged Combat
            pttg_side_effects:character_ranged_mastery_training(general)
        end
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_RestRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)
