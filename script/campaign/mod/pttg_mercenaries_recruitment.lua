local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_upkeep = core:get_static_object("pttg_upkeep")

core:add_listener(
    "pttg_RecruitReward",
    "pttg_recruit_reward",
    true,
    function(context)
        pttg_upkeep:resolve("pttg_RecruitReward")

        pttg_glory:add_initial_recruit_glory(context.recruit_glory())
        
        pttg_merc_pool:trigger_recruitment(context.recruit_count(), context.recruit_chances(), context.unique_only())

        pttg:set_state('pending_reward', false)
        
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)
