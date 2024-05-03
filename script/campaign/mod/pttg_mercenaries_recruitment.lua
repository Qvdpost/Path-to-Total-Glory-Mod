local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_upkeep = core:get_static_object("pttg_upkeep")

core:add_listener(
    "pttg_RecruitReward",
    "pttg_recruit_reward",
    true,
    function(context)
        pttg_upkeep:resolve("pttg_RecruitReward")

        local cursor = pttg:get_cursor()

        local recruit_chances
        if context.recruit_chances then
            recruit_chances = context.recruit_chances()
        else
            recruit_chances = pttg:get_state('recruit_chances')[cursor.z]
        end
        
        pttg_merc_pool:trigger_recruitment(context.recruit_count or pttg:get_state('recruit_count'), recruit_chances, context.unique_only or false)
        
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)
