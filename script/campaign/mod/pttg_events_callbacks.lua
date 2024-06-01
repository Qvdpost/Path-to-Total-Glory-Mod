local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_side_effects = core:get_static_object("pttg_side_effects")
local pttg_events = core:get_static_object("pttg_event_pool")


function pttg_EventGlory_callback(context)
    if context:choice_key() == 'FIRST' then
        pttg_glory:reward_glory(15)
    elseif context:choice_key() == 'SECOND' then
        pttg_glory:reward_glory(30)
        pttg:set_state('alignment', pttg:get_state('alignment') + 15)
    end
end

function pttg_EventGlory_eligibility_callback(context)
    
    if context.act ~= 1 and context.act ~= 2 then
        return false
    end

    -- if context.alignment > 20 then
    --     return false
    -- end

    local faction_set = 'all'
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    return true
end

function pttg_HiringBoard_callback(context)
	-- body of the callback; what should happen for each choice?
    local hiring_board = cm:create_dilemma_builder('pttg_AgentRecruit')
    local faction = cm:get_local_faction()

    for agent_type, _ in pairs(pttg_merc_pool:recruitable_agents(faction:name())) do 
        local agent_payload = cm:create_payload()
        if agent_type == 'champion' then
			hiring_board:add_choice_payload("FIRST", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'dignitary' then
			hiring_board:add_choice_payload("SECOND", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'engineer' then
			hiring_board:add_choice_payload("THIRD", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'runesmith' then
			hiring_board:add_choice_payload("FOURTH", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'spy' then
			hiring_board:add_choice_payload("FIFTH", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'wizard' then
			hiring_board:add_choice_payload("SIXTH", agent_payload);
            agent_payload:clear()
        end
    end

    local hiring_payload = cm:create_payload()
    -- hiring_payload:text_display("pttg_RecruitAgent_seventh");
    hiring_board:add_choice_payload("SEVENTH", hiring_payload);
    hiring_payload:clear()

    if cm:random_number(100, 1) < 5 then
        -- hiring_payload:text_display("pttg_RecruitAgent_eighth");
        hiring_board:add_choice_payload("EIGHTH", hiring_payload);
        hiring_payload:clear()
    end

    core:add_listener(
        "pttg_agent_recruit",
        "DilemmaChoiceMadeEvent",
        function(context) return context:dilemma() == 'pttg_AgentRecruit' end,
        pttg_AgentRecruit_callback,
        false
    )

    cm:launch_custom_dilemma_from_builder(hiring_board, faction)
end

function pttg_HiringBoard_eligibility_callback(context)
    
    if context.act ~= 1 and context.act ~= 2 then -- only triggers in act 1 or 2
        return false
    end

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    if force:character_list():num_items() > 3 then
        return false
    end

    if force:character_list():num_items() == 1 then
        context.event.weight = 25
    elseif force:character_list():num_items() == 2 then
        context.event.weight = 15
    elseif force:character_list():num_items() == 3 then
        context.event.weight = 5
    end

    return true
end

function pttg_AgentRecruit_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local cursor = pttg:get_cursor()
    local level = 0.6 * cursor.y + 12 * cursor.z
    -- TODO: add prices per agent
	if choice == 'FIRST' then -- a Champion
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'champion'}), level, force)
	end
    if choice == 'SECOND' then -- a Dignitary
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'dignitary'}), level, force)
    end
    if choice == 'THIRD' then -- an Engineer
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'engineer'}), level, force)
    end
    if choice == 'FOURTH' then -- a Runesmith
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'runesmith'}), level, force)
    end
    if choice == 'FIFTH' then -- a Spy
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'spy'}), level, force)
    end
	if choice == 'SIXTH' then -- a Wizard
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'wizard'}), level, force)
	end
	if choice == 'EIGhTH' then -- Illegible
        -- TODO: make this something cool. Unique hero perhaps?
        local factions = cm:model():world():faction_list()
        local random_faction = factions:item_at(cm:random_number(factions:num_items()-1, 0))
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(random_faction:name(), 'random'), level, force)
	end
end