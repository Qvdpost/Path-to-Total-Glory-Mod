local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")

local function rest()
    pttg:log("[pttg_RestRoom] Resting troops: ")
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100
        local bonus = pttg:get_state('replenishment_factor')

        pttg:log(string.format("[pttg_RestRoom] Healing %s to  %s(%s + %s).", unit:unit_key(), base + bonus, base,
            bonus))
        if unit:unit_class() ~= "com" then
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + bonus, 0.01, 1))
        else -- TODO: Heal characters for half (should we?)
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (bonus / 2), 0.01, 1))
        end
    end

    core:trigger_custom_event('pttg_Idle', {})
end

local function train_mercenary()
    core:trigger_custom_event('pttg_Idle', {})
end

local function train_general()
    local character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    local lookup = cm:char_lookup_str(character)
    local current_character_rank = character:rank()
    local character_rank = 3
    ---@diagnostic disable-next-line: undefined-field
    local xp = cm.character_xp_per_level[math.min(current_character_rank + character_rank, 50)] - cm.character_xp_per_level[current_character_rank]

    cm:add_agent_experience(lookup, xp)
    
    core:trigger_custom_event('pttg_Idle', {})
end

core:add_listener(
    "path_chose_LMR",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_RestRoom'
    end,
    function(context)
        pttg:log(string.format("[pttg_RestRoom] Choice: %s", context:choice_key()))

        if context:choice_key() == 'FIRST' then
            rest()
        elseif context:choice_key() == 'SECOND' then
            train_mercenary()
        else
            train_general()
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
