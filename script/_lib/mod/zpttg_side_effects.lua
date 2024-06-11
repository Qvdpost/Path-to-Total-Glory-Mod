local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_tele = core:get_static_object("pttg_tele")
local pttg_effect_pool = core:get_static_object("pttg_effect_pool")


local pttg_side_effects = {

}


core:add_listener(
    "pttg_research_active_tech",
    "PanelClosedCampaign",
    function(context) return context.string == 'technology_panel' end,
    function(context)
        if pttg_glory:get_tech_glory_value() > 0 then
            local faction_key = cm:get_local_faction_name()
            local record = cco("CcoCampaignFaction", faction_key)
            local active_research = record:Call("TechnologyManagerContext.CurrentResearchingTechnologyContext")
            if active_research then
                pttg_side_effects:unlock_tech(active_research:Call("RecordContext.Key"))
                pttg_glory:remove_tech_glory(1)
            end
        end
    end,
    true
)

function pttg_side_effects:unlock_active_tech()
    local faction_key = cm:get_local_faction_name()
    local record = cco("CcoCampaignFaction", faction_key)
    local active_research = record:Call("TechnologyManagerContext.CurrentResearchingTechnologyContext")
    if active_research then
        pttg_side_effects:unlock_tech(active_research:Call("RecordContext.Key"))
        pttg_glory:remove_tech_glory(1)
    end    
end

function pttg_side_effects:unlock_tech(tech_key)
    local faction_key = cm:get_local_faction_name()
    local completed_techs = pttg:get_state('completed_techs')

    for key, _ in pairs(completed_techs) do
        ---@diagnostic disable-next-line: undefined-field
        cm:instantly_research_technology(faction_key, key, false)
    end

    completed_techs[tech_key] = true
    pttg:set_state('completed_techs', completed_techs)

    ---@diagnostic disable-next-line: undefined-field
    cm:instantly_research_technology(faction_key, tech_key, true)
end

function pttg_side_effects:heal_force(factor, use_tier_scale)
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    local scale = 1

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100

        
        if unit:unit_class() ~= "com" then
            if use_tier_scale and pttg_merc_pool.merc_units[unit:unit_key()].cost > 1 then
                scale = 1 / pttg_merc_pool.merc_units[unit:unit_key()].cost
            end
            pttg:log(string.format("[pttg_RestRoom] Healing unit %s to  %s(%s + %s).", unit:unit_key(), base + (factor * scale), base, (factor * scale)))
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor * scale), 0.01, 1))
        else -- TODO: Heal characters for less (should we?)
            ---@diagnostic disable-next-line: undefined-field
            pttg:log(string.format("[pttg_RestRoom] Healing character %s to  %s(%s + %s).", unit:unit_key(), base + (factor / 2), base, (factor / 2)))
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor / 1.5), 0.01, 1))
        end
    end
end

function pttg_side_effects:attrition_force(factor, use_tier_scale)
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    local scale = 1

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100

        pttg:log(string.format("[pttg_RestRoom] Attritioning %s to  %s(%s - %s).", unit:unit_key(), base - factor, base,
        factor))
        if unit:unit_class() ~= "com" then
            if use_tier_scale then
                scale = 1 / pttg_merc_pool.merc_units[unit:unit_key()].tier
            end
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base - (factor * scale), 0.01, 1))
        else -- TODO: Heal characters for half (should we?)
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base - (factor / 2), 0.01, 1))
        end
    end
end

function pttg_side_effects:grant_general_levels(amount)
    local character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    local lookup = cm:char_lookup_str(character)
    local current_character_rank = character:rank()
    local character_rank = amount

    ---@diagnostic disable-next-line: undefined-field
    local xp = cm.character_xp_per_level[math.min(current_character_rank + character_rank, 50)] - cm.character_xp_per_level[current_character_rank]

    cm:add_agent_experience(lookup, xp)
end

function pttg_side_effects:grant_characters_levels(amount, force)
    if not force then
        force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))
    end

    local army_chars = force:character_list()
    for i = 0, army_chars:num_items()-1 do
        local character = army_chars:item_at(i)
        local lookup = cm:char_lookup_str(character)
        local current_character_rank = character:rank()
        local character_rank = amount

        pttg:log("Adding experience to: "..character:get_forename().." with rank "..tostring(current_character_rank))
    
        if current_character_rank > 0 then
            ---@diagnostic disable-next-line: undefined-field
            local xp = cm.character_xp_per_level[math.min(current_character_rank + character_rank, 50)] - cm.character_xp_per_level[current_character_rank]
        
            cm:add_agent_experience(lookup, xp)
            core:trigger_event("CharacterRankUp", character)
        end
    end
end

function pttg_side_effects:grant_characters_random_skills(number, force)
    pttg:log("Assigning random skills to characters: ")
    if not force then
        force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))
    end

    local army_chars = force:character_list()
    for i = 0, army_chars:num_items()-1 do
        local character = army_chars:item_at(i)
        local character_cco = cco("CcoCampaignCharacter", character:cqi())
        if character_cco then
            local tries = 0
            local skill_count = number

            pttg:log("Assigning "..skill_count.. " skills to "..character_cco:Call("Name"))

            while skill_count > 0 and tries < 150 do
                if character_cco:Call("SkillList.Size") == 0 then
                    break
                end
                tries = tries + 1
                local random_skill_index = cm:random_number(character_cco:Call("SkillList.Size")-1, 0)
                local random_skill = character_cco:Call("SkillList.At("..random_skill_index..")")

                pttg:log("Checking "..random_skill:Call("Name"))
                local current_level = random_skill:Call("CurrentLevelContext.Level")
                if random_skill:Call("CurrentLevelContext.Level") < random_skill:Call("TotalLevels") then
                    ---@diagnostic disable-next-line: undefined-field
                    cm:add_skill(character, random_skill:Call("Key"), true, true)
                    if current_level < random_skill:Call("CurrentLevelContext.Level") then
                        pttg:log("Assigned: "..random_skill:Call("Name").." at level: "..random_skill:Call("CurrentLevelContext.Level"))
                        skill_count = skill_count - 1
                        tries = 0
                    end
                end
            end
        end
    end
end

function pttg_side_effects:grant_characters_passive_levels(amount, step)
    local cursor = pttg:get_cursor()
    if cursor and cursor.y % step == 0 then
        self:grant_characters_levels(amount)
    end
end

function pttg_side_effects:character_ranged_mastery_training(general)
    if not character then
        character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    end

    cm:force_add_trait(cm:char_lookup_str(character), "pttg_ranged_mastery", true, 1)
end

function pttg_side_effects:character_melee_mastery_training(character)
    if not character then
        character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    end

    cm:force_add_trait(cm:char_lookup_str(character), "pttg_melee_mastery", true, 1)
end

function pttg_side_effects:character_spell_mastery_training(character)
    if not character then
        character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    end

    cm:force_add_trait(cm:char_lookup_str(character), "pttg_spell_mastery", true, 1)
end

function pttg_side_effects:character_defense_mastery_training(character)
    if not character then
        character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    end

    cm:force_add_trait(cm:char_lookup_str(character), "pttg_defense_mastery", true, 1)
end

function pttg_side_effects:add_agent_to_force(agent_info, level, force)
    pttg:log("Adding an agent [".. agent_info.subtype .."] of level: "..tostring(level))
    if not force then
        force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))
    end
    local faction = force:faction()

    local home = faction:home_region()

    if not home.name then
        home = pttg_tele:get_random_region()
    end

    local agent_x, agent_y = cm:find_valid_spawn_location_for_character_from_settlement(faction:name(), home:name(), false, true, 10)
    ---@diagnostic disable-next-line: param-type-mismatch
    local agent = cm:create_agent(faction:name(), agent_info.type, agent_info.subtype, agent_x, agent_y, true)

    cm:add_agent_experience(cm:char_lookup_str(agent:command_queue_index()), level, true)
    cm:embed_agent_in_force(agent, force)

    return agent
end

function pttg_side_effects:grant_units_chevrons(chevrons, force)
    if not force then
        force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))
    end

    local unit_list = force:unit_list()

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);

        pttg:log(string.format("[pttg_side_effects] Giving unit chevrons: %s|%s", unit:unit_key(), chevrons))
        if unit:unit_class() ~= "com" then
            cm:add_experience_to_unit(unit, chevrons)
        end
    end
end

function pttg_side_effects.zany_mode(factions)
    if not factions or type(factions) ~= 'table' then
        script_error("Adding zany factions without valid faction array.")
        return false
    end

    local faction_mili_groups = {}
    for _, faction in pairs(factions) do
        faction_mili_groups[pttg_merc_pool.faction_to_military_grouping[faction]] = true
    end

    function faction_mili_groups:contains_any_of(tbl) 
        for _, key in pairs(tbl) do
            if self[key] then
                return true
            end
        end
        return false
    end

    for _, merc in pairs(pttg_merc_pool.merc_units) do
        if faction_mili_groups:contains_any_of(merc.military_groupings) then
            info_override =  { key = merc.key, info = { military_groupings = {pttg_merc_pool.faction_to_military_grouping[cm:get_local_faction_name()]} }}
            pttg_merc_pool:update_merc(info_override)
        end
    end

    local faction_key = cm:get_local_faction_name()
    local faction_table = {}
    for _, faction in pairs(factions) do
        faction_table[faction] = true
    end
    for _, agent in pairs(pttg_merc_pool.agents) do
        if faction_table[agent.faction] then
            if not pttg_merc_pool.faction_to_agents[faction_key][agent.type] then
                pttg_merc_pool.faction_to_agents[faction_key][agent.type] = {}
            end
            if agent.recruitable then
                table.insert(pttg_merc_pool.faction_to_agents[faction_key][agent.type], agent)
            end
        end
    end

    pttg_merc_pool.merc_pool = {}
    pttg_merc_pool:reset_merc_pool()
    pttg_merc_pool:init_merc_pool()

    pttg_effect_pool:activate_campaign_effect('pttg_zany_mode', {factions})
end
pttg_effect_pool:add_campaign_effect('pttg_zany_mode', {callback=pttg_side_effects.zany_mode})


function pttg_side_effects:randomize_start(random_general)
    pttg:log("Randomizing start")
    local pttg_UI = core:get_static_object('pttg_UI')

    local military_force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))
    local general = military_force:general_character()
    cm:set_character_immortality(cm:char_lookup_str(general), false)
    local faction = cm:get_local_faction()

    local home = faction:home_region()
    if not home.name then
        home = pttg_tele:get_random_region()
    end

    x, y = cm:find_valid_spawn_location_for_character_from_settlement(cm:get_local_faction_name(),
    home:name(), false, true, 10)

    if random_general then
        cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
        pttg:log("Clearing out starting agents.")
        pttg:log("Agent count: "..faction:character_list():num_items())
        local characters = {}
        for i = 0, faction:character_list():num_items() - 1 do
            table.insert(characters, faction:character_list():item_at(i))
        end
        for _, char in pairs(characters) do
            pttg:log("Clearing out: ".. char:character_subtype_key().."|"..char:character_type_key())
            cm:kill_character(cm:char_lookup_str(char), true)
        end
        pttg:log("Clearing out starting agents done.")
        cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, 1) 

    
        cm:create_force_with_general(
            faction:name(),
            "",
            home:name(),
            x,
            y,
            "general",
            pttg_merc_pool:get_random_general(faction:name()).subtype,
            "",
            "",
            "",
            "",
            true,			
            -- Generals created this way does not come with a trait and aren't immortal
            function(cqi)
                pttg:log("[pttg_side_effects] Post processing new lord");
                pttg:set_state('army_cqi', cm:get_character_by_cqi(cqi):military_force():command_queue_index())

                local char_str = cm:char_lookup_str(cqi)
                cm:set_character_immortality(char_str, true)
                cm:set_character_unique(char_str, true);

                cm:zero_action_points(cm:char_lookup_str(cqi))

                pttg_UI:center_camera()
            end
        ); 
    else
        cm:teleport_to(cm:char_lookup_str(general), x, y)
        cm:remove_all_units_from_general(general)
        cm:real_callback(function() pttg_UI:center_camera() end, 500)
    end
    
    pttg_merc_pool:trigger_recruitment(pttg:get_difficulty_mod('random_start_recruit_merc_count'), pttg:get_difficulty_mod('random_start_chances'))

    -- Guarantee one rare.
    pttg_merc_pool:trigger_recruitment(1, { -10, -5, 100 })
    
    pttg_glory:add_recruit_glory(pttg:get_difficulty_mod('random_start_recruit_glory'))
    pttg_UI:highlight_recruitment(true)
end

function pttg_RandomStart_callback(context)
    local choice = context:choice_key()

    if choice == 'SECOND' then
        pttg_side_effects:randomize_start(true)
    elseif choice == 'THIRD' then
        pttg_side_effects:randomize_start(false)
    elseif choice == 'FOURTH' then
        cm:trigger_dilemma(cm:get_local_faction_name(),'pttg_ZanyMode')
    end
end

core:add_listener(
    "pttg_event_resolved",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ZanyMode'
    end,
    function(context)
        local choice = context:choice_key()
    
        if choice == 'FIRST' then -- Ordertide
            pttg_side_effects.zany_mode({
                "wh2_main_hef_nagarythe",
                "wh2_main_lzd_itza",
                "wh_main_dwf_karak_kadrin",
                "wh2_main_hef_order_of_loremasters",
                "wh2_dlc13_lzd_spirits_of_the_jungle",
                "wh2_dlc13_emp_golden_order",
                "wh_main_brt_bordeleaux",
                "wh3_main_dwf_the_ancestral_throng",
                "wh_main_dwf_karak_izor",
                "wh2_main_lzd_tlaqua",
                "wh2_dlc17_lzd_oxyotl",
                "wh_main_brt_bretonnia",
                "wh3_main_cth_the_western_provinces",
                "wh_main_dwf_dwarfs",
                "wh3_main_ksl_the_great_orthodoxy",
                "wh3_main_emp_cult_of_sigmar",
                "wh2_main_hef_yvresse",
                "wh2_main_lzd_last_defenders",
                "wh3_main_ksl_ursun_revivalists",
                "wh_main_brt_carcassonne",
                "wh2_main_hef_avelorn",
                "wh2_main_hef_eataine",
                "wh2_dlc12_lzd_cult_of_sotek",
                "wh_main_emp_wissenland",
                "wh2_main_lzd_hexoatl",
                "wh2_dlc14_brt_chevaliers_de_lyonesse",
                "wh2_dlc15_hef_imrik",
                "wh3_main_ksl_the_ice_court",
                "wh2_dlc17_dwf_thorek_ironbrow",
                "wh3_dlc24_cth_the_celestial_court",
                "wh2_dlc13_emp_the_huntmarshals_expedition",
                "wh_main_emp_empire",
                "wh3_main_cth_the_northern_provinces",
                "wh3_dlc25_dwf_malakai",
                "wh3_dlc24_ksl_daughters_of_the_forest",
            })
        elseif choice == 'SECOND' then -- End Times
            pttg_side_effects.zany_mode({
                "wh3_dlc20_chs_valkia",
                "wh3_dlc20_chs_festus",
                "wh2_main_skv_clan_eshin",
                "wh_dlc03_bst_beastmen",
                "wh3_main_sla_seducers_of_slaanesh",
                "wh_dlc08_nor_norsca",
                "wh3_main_dae_daemon_prince",
                "wh3_dlc25_nur_tamurkhan",
                "wh2_main_skv_clan_mors",
                "wh3_dlc23_chd_astragoth",
                "wh3_main_nur_poxmakers_of_nurgle",
                "wh2_main_skv_clan_moulder",
                "wh_dlc08_nor_wintertooth",
                "wh2_main_skv_clan_pestilens",
                "wh3_dlc23_chd_legion_of_azgorh",
                "wh3_main_tze_oracles_of_tzeentch",
                "wh2_dlc09_skv_clan_rictus",
                "wh_dlc05_bst_morghur_herd",
                "wh2_dlc17_bst_malagor",
                "wh3_dlc20_chs_kholek",
                "wh3_dlc24_tze_the_deceivers",
                "wh2_dlc17_bst_taurox",
                "wh2_main_skv_clan_skryre",
                "wh3_dlc23_chd_zhatan",
                "wh3_dlc20_chs_vilitch",
                "wh3_dlc20_chs_azazel",
                "wh3_main_kho_exiles_of_khorne",
                "wh3_dlc20_chs_sigvald",
                "wh3_dlc25_nur_epidemius",
                "wh_main_chs_chaos",
                "wh3_main_chs_shadow_legion",
            })
        elseif choice == 'THIRD' then -- Deathless Legions
            pttg_side_effects.zany_mode({
                "wh2_dlc11_cst_pirates_of_sartosa",
                "wh2_dlc09_tmb_khemri",
                "wh_main_vmp_vampire_counts",
                "wh2_dlc09_tmb_followers_of_nagash",
                "wh2_dlc11_vmp_the_barrow_legion",
                "wh2_dlc11_cst_vampire_coast",
                "wh2_dlc09_tmb_lybaras",
                "wh_main_vmp_schwartzhafen",
                "wh2_dlc09_tmb_exiles_of_nehek",
                "wh2_dlc11_cst_the_drowned",
                "wh2_dlc11_cst_noctilus",
                "wh3_main_vmp_caravan_of_blue_roses",
            })
        elseif choice == 'FOURTH' then -- Destruction
            pttg_side_effects.zany_mode({
                "wh_main_grn_greenskins",
                "wh3_main_ogr_goldtooth",
                "wh_main_grn_crooked_moon",
                "wh2_dlc15_grn_bonerattlaz",
                "wh2_dlc15_grn_broken_axe",
                "wh3_main_ogr_disciples_of_the_maw",
                "wh_main_grn_orcs_of_the_bloody_hand",
            })
        elseif choice == 'FIFTH' then -- EVERYTHING
            pttg_side_effects.zany_mode({
                "wh3_main_ksl_ursun_revivalists",
                "wh_main_emp_wissenland",
                "wh2_main_skv_clan_eshin",
                "wh2_dlc16_wef_drycha",
                "wh2_dlc11_vmp_the_barrow_legion",
                "wh3_dlc20_chs_festus",
                "wh_main_brt_bordeleaux",
                "wh2_dlc12_lzd_cult_of_sotek",
                "wh_main_grn_greenskins",
                "wh3_dlc20_chs_valkia",
                "wh3_dlc23_chd_astragoth",
                "wh_dlc05_bst_morghur_herd",
                "wh_main_brt_bretonnia",
                "wh2_main_def_har_ganeth",
                "wh2_main_hef_avelorn",
                "wh2_main_skv_clan_mors",
                "wh2_main_lzd_hexoatl",
                "wh3_main_cth_the_western_provinces",
                "wh_main_dwf_karak_izor",
                "wh_main_grn_orcs_of_the_bloody_hand",
                "wh2_twa03_def_rakarth",
                "wh2_main_lzd_tlaqua",
                "wh3_dlc24_tze_the_deceivers",
                "wh_main_dwf_dwarfs",
                "wh_main_vmp_schwartzhafen",
                "wh3_main_tze_oracles_of_tzeentch",
                "wh3_main_kho_exiles_of_khorne",
                "wh3_dlc20_chs_sigvald",
                "wh_main_emp_empire",
                "wh2_dlc09_skv_clan_rictus",
                "wh_dlc05_wef_wood_elves",
                "wh2_dlc15_grn_bonerattlaz",
                "wh2_main_def_cult_of_pleasure",
                "wh_dlc08_nor_wintertooth",
                "wh2_main_lzd_last_defenders",
                "wh2_dlc11_cst_the_drowned",
                "wh2_dlc11_cst_noctilus",
                "wh2_main_skv_clan_pestilens",
                "wh_dlc03_bst_beastmen",
                "wh3_dlc23_chd_legion_of_azgorh",
                "wh2_dlc09_tmb_exiles_of_nehek",
                "wh2_dlc17_lzd_oxyotl",
                "wh2_dlc16_wef_sisters_of_twilight",
                "wh2_dlc11_cst_pirates_of_sartosa",
                "wh2_dlc13_emp_golden_order",
                "wh2_dlc13_lzd_spirits_of_the_jungle",
                "wh2_main_hef_eataine",
                "wh3_dlc23_chd_zhatan",
                "wh2_dlc17_bst_taurox",
                "wh2_main_lzd_itza",
                "wh_dlc05_wef_argwylon",
                "wh3_main_cth_the_northern_provinces",
                "wh3_main_ksl_the_ice_court",
                "wh2_dlc11_def_the_blessed_dread",
                "wh2_dlc09_tmb_followers_of_nagash",
                "wh3_dlc20_chs_kholek",
                "wh_main_brt_carcassonne",
                "wh_main_dwf_karak_kadrin",
                "wh2_dlc13_emp_the_huntmarshals_expedition",
                "wh2_main_def_hag_graef",
                "wh2_dlc14_brt_chevaliers_de_lyonesse",
                "wh3_main_chs_shadow_legion",
                "wh_main_vmp_vampire_counts",
                "wh3_dlc25_dwf_malakai",
                "wh3_dlc24_ksl_daughters_of_the_forest",
                "wh2_main_hef_nagarythe",
                "wh3_dlc25_nur_tamurkhan",
                "wh2_dlc09_tmb_lybaras",
                "wh2_dlc17_dwf_thorek_ironbrow",
                "wh3_main_dwf_the_ancestral_throng",
                "wh2_dlc17_bst_malagor",
                "wh3_main_nur_poxmakers_of_nurgle",
                "wh3_main_emp_cult_of_sigmar",
                "wh2_main_skv_clan_moulder",
                "wh2_main_skv_clan_skryre",
                "wh2_main_def_naggarond",
                "wh3_dlc24_cth_the_celestial_court",
                "wh2_dlc09_tmb_khemri",
                "wh3_main_vmp_caravan_of_blue_roses",
                "wh3_main_ogr_disciples_of_the_maw",
                "wh3_dlc20_chs_vilitch",
                "wh2_dlc15_hef_imrik",
                "wh2_dlc11_cst_vampire_coast",
                "wh3_main_ksl_the_great_orthodoxy",
                "wh3_main_ogr_goldtooth",
                "wh_main_grn_crooked_moon",
                "wh2_main_hef_yvresse",
                "wh_dlc08_nor_norsca",
                "wh_main_chs_chaos",
                "wh3_dlc20_chs_azazel",
                "wh3_dlc25_nur_epidemius",
                "wh3_main_dae_daemon_prince",
                "wh2_main_hef_order_of_loremasters",
                "wh3_main_sla_seducers_of_slaanesh",
                "wh2_dlc15_grn_broken_axe",
            })
        elseif choice == 'SIXTH' then -- The Everliving
            pttg_side_effects.zany_mode({
                "wh2_main_def_har_ganeth",
                "wh2_dlc11_def_the_blessed_dread",
                "wh2_main_def_hag_graef",
                "wh2_main_def_naggarond",
                "wh2_dlc16_wef_sisters_of_twilight",
                "wh2_main_hef_eataine",
                "wh_dlc05_wef_argwylon",
                "wh2_main_hef_yvresse",
                "wh2_main_hef_order_of_loremasters",
                "wh2_main_hef_nagarythe",
                "wh_dlc05_wef_wood_elves",
                "wh2_dlc15_hef_imrik",
            })
        else -- Regrets
            cm:trigger_dilemma(cm:get_local_faction_name(), 'pttg_RandomStart')
            return
        end

        pttg_side_effects:randomize_start(false)
    end,
    false
)

-- core:add_listener(
--     "pttg_rest_train",
--     "UnitEffectPurchased",
--     true,
--     function(context)
--         pttg:log("Training merc: ", context:unit():unit_key())
--         cm:add_experience_to_unit(context:unit(), 3);
--     end,
--     true
-- )

core:add_listener(
    "pttg_event_resolved",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_RandomStart'
    end,
    function(context)
        pttg_RandomStart_callback(context)
    end,
    false
)

function pttg_side_effects:zero_merc_cost()
    local recruitment_cost_bundle_key = "pttg_merc_recruit_cost_down";
	local faction = cm:get_local_faction()

    if faction:has_effect_bundle(recruitment_cost_bundle_key) then
        return
    end

    local recruitment_cost_bundle = cm:create_new_custom_effect_bundle(recruitment_cost_bundle_key);
    
    ---@diagnostic disable-next-line: undefined-field
    recruitment_cost_bundle:add_effect("wh3_main_effect_mercenary_cost_mod", "faction_to_character_own_factionwide_armytext", -10000);
    ---@diagnostic disable-next-line: undefined-field
    recruitment_cost_bundle:set_duration(0);

    ---@diagnostic disable-next-line: undefined-field
    recruitment_cost_bundle:add_effect("wh_main_effect_force_all_campaign_recruitment_cost_all", "faction_to_character_own_factionwide_armytext", -10000);
    ---@diagnostic disable-next-line: undefined-field
    recruitment_cost_bundle:set_duration(0);

    cm:apply_custom_effect_bundle_to_faction(recruitment_cost_bundle, faction);
end

function pttg_side_effects:game_over()
    local faction = cm:get_local_faction()

    local characters = {}
    for i = 0, faction:character_list():num_items() - 1 do
        table.insert(characters, faction:character_list():item_at(i))   
    end
    for _, character in pairs(characters) do
        if not character:is_wounded() then
            pttg:log("Killing: ".. character:character_subtype_key().. "|" .. character:character_type_key())
            cm:kill_character(cm:char_lookup_str(character), true)
        end
    end

    local regions = {}
    for i = 0, faction:region_list():num_items() - 1 do
        table.insert(regions, faction:region_list():item_at(i))
    end
    for _, region in pairs(regions) do
        pttg:log("Abandoning: ".. region:name())
        cm:set_region_abandoned(region:name())
    end
end

core:add_static_object("pttg_side_effects", pttg_side_effects);
