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
    pttg:log("[pttg_RestRoom] Training mercenary: ")
    pttg_glory:add_warband_upgrade_glory(1)
    core:trigger_custom_event('pttg_Idle', {})
end

local function train_general()
    -- TODO: add an intenisty increasing buff perhaps?
    pttg:log("[pttg_RestRoom] Training general: ")
    pttg_side_effects:grant_general_levels(5)
    core:trigger_custom_event('pttg_Idle', {})
end


-- core:add_listener(
--     "pttg_rest_train",
--     "UnitEffectPurchased",
--     true,
--     function(context)
--         pttg:log("Training merc: ", context:unit():unit_key())
--         cm:add_experience_to_unit(context:unit(), 9);
--     end,
--     true
-- )

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
