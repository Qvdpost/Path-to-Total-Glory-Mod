local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")
local pttg_upkeep = core:get_static_object("pttg_upkeep")

core:add_listener(
    "pttg_RecruitReward",
    "pttg_recruit_reward",
    true,
    function(context)
        local faction = cm:get_local_faction()

        pttg_upkeep:resolve("pttg_RecruitReward")

        pttg:log(string.format("[pttg_RecruitReward] Recruiting units for %s", faction:culture()))


        local recruit_chances 
        if context.recruit_chances then
            recruit_chances = context.recruit_chances()
        else
            recruit_chances = pttg:get_state('recruit_chances')
        end
        local rando_tiers = { 0, 0, 0 }

        for i = 1, pttg:get_state('recruit_count') do
            local offset = pttg:get_state('recruit_rarity_offset')
            local rando_tier = cm:random_number(100) - offset
            pttg:log(string.format("[pttg_RecruitReward] Adding tier for roll %s(%s)", rando_tier, offset))
            if rando_tier < recruit_chances[1] then
                rando_tiers[1] = rando_tiers[1] + 1
                pttg:set_state('recruit_rarity_offset', math.min(40, offset + 1))
            elseif rando_tier < recruit_chances[2] then
                rando_tiers[2] = rando_tiers[2] + 1
            else
                rando_tiers[3] = rando_tiers[3] + 1
                pttg:set_state('recruit_rarity_offset', -5)
            end
        end

        for tier, count in pairs(rando_tiers) do
            if count > 0 then
                pttg:log(string.format("[pttg_RecruitReward] Addign %s units of tier %s", count, tier))
                local available_merc_pool = pttg_merc_pool.merc_pool[faction:culture()][tier]


                local recruit_pool_key = "pttg_recruit_reward"
                pttg_pool_manager:new_pool(recruit_pool_key)

                for _, merc in pairs(available_merc_pool) do
                    pttg_pool_manager:add_item(recruit_pool_key, merc.key, 1)
                end

                pttg_merc_pool:add_active_units(pttg_pool_manager:generate_pool(recruit_pool_key, count, true))
            end
        end
    end,
    true
)
