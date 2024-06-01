local pttg = core:get_static_object("pttg");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")

PttG_MercInfo = {
}

function PttG_MercInfo:new(key, unit_info)
    local self = {}
    if not key or not unit_info.category or #unit_info.military_groupings == 0 then
        script_error("Cannot add merc without a name_key, category and military_groupings.")
        return false
    end
    self.key = key
    self.category = unit_info.category
    self.military_groupings = unit_info.military_groupings
    self.weight = unit_info.weight
    self.tier = unit_info.tier
    self.cost = unit_info.cost

    setmetatable(self, { __index = PttG_MercInfo })
    return self
end

function PttG_MercInfo:repr()
    return string.format("Merc(%s): %s, %s, tier|%s, weight|%s, cost|%s", self.key, '['..table.concat(self.military_groupings, ',')..']', self.category, self.tier, self.weight, self.cost)
end

PttG_AgentInfo = {
}

function PttG_AgentInfo:new(key, agent_info)
    local self = {}
    
    if not agent_info.faction and agent_info.type and agent_info.subtype then
        script_error('Cannot create agent without a faction, type, or subtype')
        return false
    end
    self.key = key
    self.faction = agent_info.faction
    self.type = agent_info.type
    self.subtype = agent_info.subtype

    self.recruitable = agent_info.recruitable

    setmetatable(self, { __index = PttG_AgentInfo })
    return self
end

function PttG_AgentInfo:repr()
    return string.format("Agent(%s): subtype|%s, type|%s, faction|%s [%s]", self.key, self.subtype, self.type, self.faction)
end


local pttg_merc_pool = {
    merc_pool = {},
    merc_units = {},
    active_merc_pool = {},
    tiers = { ["core"] = 1, ["special"] = 2, ["rare"] = 3 },
    faction_to_military_grouping = {
        ["wh2_dlc09_rogue_black_creek_raiders"] = "wh2_dlc09_rogue_black_creek_raiders",
        ["wh2_dlc09_rogue_dwellers_of_zardok"] = "wh2_dlc09_rogue_dwellers_of_zardok",
        ["wh2_dlc09_rogue_eyes_of_the_jungle"] = "wh2_dlc09_rogue_eyes_of_the_jungle",
        ["wh2_dlc09_rogue_pilgrims_of_myrmidia"] = "wh2_dlc09_rogue_pilgrims_of_myrmidia",
        ["wh2_dlc09_skv_clan_rictus"] = "wh2_main_skv",
        ["wh2_dlc09_skv_clan_rictus_separatists"] = "wh2_main_skv",
        ["wh2_dlc09_tmb_dune_kingdoms"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_exiles_of_nehek"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_followers_of_nagash"] = "wh2_dlc09_tomb_kings_arkhan",
        ["wh2_dlc09_tmb_khemri"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_lybaras"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_numas"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_rakaph_dynasty"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_the_sentinels"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tomb_kings"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tomb_kings_rebels"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb1"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb2"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb3"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb4"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb_exiles_of_nehek"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb_followers_of_nagash"] = "wh2_dlc09_tomb_kings_arkhan",
        ["wh2_dlc09_tmb_tombking_qb_khemri"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc09_tmb_tombking_qb_lybaras"] = "wh2_dlc09_tomb_kings",
        ["wh2_dlc10_def_blood_voyage"] = "wh2_main_def",
        ["wh2_dlc11_brt_bretonnia_dil"] = "wh_main_group_bretonnia",
        ["wh2_dlc11_cst_harpoon_the_sunken_land_corsairs"] = "wh2_dlc11_cst_harpoon_the_sunken_land_corsairs",
        ["wh2_dlc11_cst_noctilus"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_noctilus_separatists"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_pirates_of_sartosa"] = "wh2_dlc11_group_vampire_coast_sartosa",
        ["wh2_dlc11_cst_pirates_of_sartosa_separatists"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_rogue_bleak_coast_buccaneers"] = "wh2_dlc11_cst_rogue_bleak_coast_buccaneers",
        ["wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast"] = "wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast",
        ["wh2_dlc11_cst_rogue_freebooters_of_port_royale"] = "wh2_dlc11_cst_rogue_freebooters_of_port_royale",
        ["wh2_dlc11_cst_rogue_grey_point_scuttlers"] = "wh2_dlc11_cst_rogue_grey_point_scuttlers",
        ["wh2_dlc11_cst_rogue_terrors_of_the_dark_straights"] = "wh2_dlc11_cst_rogue_terrors_of_the_dark_straights",
        ["wh2_dlc11_cst_rogue_the_churning_gulf_raiders"] = "wh2_dlc11_cst_rogue_the_churning_gulf_raiders",
        ["wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean"] = "wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean",
        ["wh2_dlc11_cst_shanty_dragon_spine_privateers"] = "wh2_dlc11_cst_shanty_dragon_spine_privateers",
        ["wh2_dlc11_cst_shanty_middle_sea_brigands"] = "wh2_dlc11_cst_shanty_middle_sea_brigands",
        ["wh2_dlc11_cst_shanty_shark_straight_seadogs"] = "wh2_dlc11_cst_shanty_shark_straight_seadogs",
        ["wh2_dlc11_cst_the_drowned"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_the_drowned_separatists"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_encounters"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_qb1"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_qb2"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_qb3"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_qb4"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_rebellion_rebels"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_rebels"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_cst_vampire_coast_separatists"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc11_def_dark_elves_dil"] = "wh2_main_def",
        ["wh2_dlc11_def_the_blessed_dread"] = "wh2_main_def",
        ["wh2_dlc11_def_the_blessed_dread_separatists"] = "wh2_main_def",
        ["wh2_dlc11_emp_empire_dil"] = "wh_main_group_empire",
        ["wh2_dlc11_emp_empire_qb5"] = "wh_main_group_empire",
        ["wh2_dlc11_nor_norsca_dil"] = "wh_main_group_norsca",
        ["wh2_dlc11_nor_norsca_qb4"] = "wh_main_group_norsca",
        ["wh2_dlc11_vmp_the_barrow_legion"] = "wh_main_group_vampire_counts",
        ["wh2_dlc12_grn_leaf_cutterz_tribe"] = "wh2_dlc12_grn_leaf_cutterz_tribe",
        ["wh2_dlc12_grn_leaf_cutterz_tribe_waaagh"] = "wh2_dlc12_grn_leaf_cutterz_tribe",
        ["wh2_dlc12_lzd_cult_of_sotek"] = "wh2_main_lzd",
        ["wh2_dlc12_skv_clan_fester"] = "wh2_main_skv",
        ["wh2_dlc12_skv_clan_mange"] = "wh2_main_skv",
        ["wh2_dlc13_bst_beastmen_invasion"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc13_emp_golden_order"] = "wh_main_group_empire_golden_order",
        ["wh2_dlc13_emp_the_huntmarshals_expedition"] = "wh_main_group_empire",
        ["wh2_dlc13_grn_greenskins_invasion"] = "wh_main_group_greenskins",
        ["wh2_dlc13_lzd_avengers"] = "wh2_main_lzd",
        ["wh2_dlc13_lzd_defenders_of_the_great_plan"] = "wh2_main_lzd",
        ["wh2_dlc13_lzd_spirits_of_the_jungle"] = "wh2_main_lzd",
        ["wh2_dlc13_nor_norsca_invasion"] = "wh_main_group_norsca",
        ["wh2_dlc13_skv_skaven_invasion"] = "wh2_main_skv",
        ["wh2_dlc13_wef_laurelorn_forest"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc14_brt_chevaliers_de_lyonesse"] = "wh_main_group_bretonnia",
        ["wh2_dlc14_grn_red_cloud"] = "wh_main_group_greenskins",
        ["wh2_dlc14_grn_red_cloud_waaagh"] = "wh_main_group_greenskins",
        ["wh2_dlc14_lzd_itz_itza_tribe"] = "wh2_main_lzd",
        ["wh2_dlc14_skv_rictus_clan_nest"] = "wh2_main_skv",
        ["wh2_dlc15_dwf_clan_helhein"] = "wh_main_group_dwarfs",
        ["wh2_dlc15_grn_bonerattlaz"] = "wh_main_group_greenskins",
        ["wh2_dlc15_grn_broken_axe"] = "wh_main_group_greenskins",
        ["wh2_dlc15_grn_broken_axe_waaagh"] = "wh_main_group_greenskins",
        ["wh2_dlc15_grn_skull_crag"] = "wh_main_group_greenskins",
        ["wh2_dlc15_hef_dragon_encounters"] = "wh2_main_hef",
        ["wh2_dlc15_hef_imrik"] = "wh2_main_hef_imrik",
        ["wh2_dlc15_skv_clan_ferrik"] = "wh2_main_skv",
        ["wh2_dlc15_skv_clan_kreepus"] = "wh2_main_skv",
        ["wh2_dlc15_skv_clan_volkn"] = "wh2_main_skv",
        ["wh2_dlc16_chs_acolytes_of_the_keeper"] = "wh_main_group_chaos",
        ["wh2_dlc16_emp_colonist_invasion"] = "wh_main_group_empire",
        ["wh2_dlc16_emp_empire_invasion"] = "wh_main_group_empire",
        ["wh2_dlc16_emp_empire_qb8"] = "wh_main_group_empire_reikland",
        ["wh2_dlc16_grn_creeping_death"] = "wh_main_group_greenskins",
        ["wh2_dlc16_grn_naggaroth_orcs"] = "wh_main_group_greenskins",
        ["wh2_dlc16_grn_savage_invasion"] = "wh_main_group_savage_orcs",
        ["wh2_dlc16_lzd_wardens_of_the_living_pools"] = "wh2_main_lzd",
        ["wh2_dlc16_skv_clan_gritus"] = "wh2_main_skv",
        ["wh2_dlc16_vmp_lahmian_sisterhood"] = "wh_main_group_vampire_counts",
        ["wh2_dlc16_wef_drycha"] = "wh2_dlc16_group_drycha",
        ["wh2_dlc16_wef_sisters_of_twilight"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_waystone_faction_1"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_waystone_faction_2"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_waystone_faction_3"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_wood_elves_qb4"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_wood_elves_qb5"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_wood_elves_qb6"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc16_wef_wood_elves_qb7"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc17_bst_beastmen_qb4"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_bst_beastmen_qb5"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_bst_beastmen_qb6"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_bst_beastmen_qb7"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_bst_malagor"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_bst_taurox"] = "wh_dlc03_group_beastmen",
        ["wh2_dlc17_dwf_thorek_ironbrow"] = "wh_main_group_dwarfs",
        ["wh2_dlc17_lzd_oxyotl"] = "wh2_main_lzd",
        ["wh2_dlc17_nor_deadwood_ravagers"] = "wh_main_group_norsca",
        ["wh2_main_brt_knights_of_origo"] = "wh_main_group_bretonnia",
        ["wh2_main_brt_knights_of_the_flame"] = "wh_main_group_bretonnia",
        ["wh2_main_brt_thegans_crusaders"] = "wh_main_group_bretonnia",
        ["wh2_main_bst_blooded_axe"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_blooded_axe_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_manblight"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_manblight_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_ripper_horn"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_ripper_horn_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_shadowgor"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_shadowgor_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_skrinderkin"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_skrinderkin_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_stone_horn"] = "wh_dlc03_group_beastmen",
        ["wh2_main_bst_stone_horn_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh2_main_chs_chaos_incursion_def"] = "wh_main_group_chaos",
        ["wh2_main_chs_chaos_incursion_hef"] = "wh_main_group_chaos",
        ["wh2_main_chs_chaos_incursion_lzd"] = "wh_main_group_chaos",
        ["wh2_main_chs_chaos_incursion_skv"] = "wh_main_group_chaos",
        ["wh2_main_def_bleak_holds"] = "wh2_main_def",
        ["wh2_main_def_blood_hall_coven"] = "wh2_main_def",
        ["wh2_main_def_clar_karond"] = "wh2_main_def",
        ["wh2_main_def_cult_of_excess"] = "wh2_main_def",
        ["wh2_main_def_cult_of_pleasure"] = "wh3_main_def_morathi",
        ["wh2_main_def_cult_of_pleasure_separatists"] = "wh3_main_def_morathi",
        ["wh2_main_def_dark_elves"] = "wh2_main_def",
        ["wh2_main_def_dark_elves_qb1"] = "wh2_main_def",
        ["wh2_main_def_dark_elves_qb2"] = "wh2_main_def",
        ["wh2_main_def_dark_elves_qb3"] = "wh2_main_def",
        ["wh2_main_def_dark_elves_qb4"] = "wh2_main_def",
        ["wh2_main_def_dark_elves_rebels"] = "wh2_main_def",
        ["wh2_main_def_deadwood_sentinels"] = "wh2_main_def",
        ["wh2_main_def_drackla_coven"] = "wh2_main_def",
        ["wh2_main_def_ghrond"] = "wh2_main_def",
        ["wh2_main_def_hag_graef"] = "wh2_main_def",
        ["wh2_main_def_hag_graef_separatists"] = "wh2_main_def",
        ["wh2_main_def_har_ganeth"] = "wh2_main_def",
        ["wh2_main_def_har_ganeth_separatists"] = "wh2_main_def",
        ["wh2_main_def_karond_kar"] = "wh2_main_def",
        ["wh2_main_def_naggarond"] = "wh2_main_def",
        ["wh2_main_def_naggarond_separatists"] = "wh2_main_def",
        ["wh2_main_def_scourge_of_khaine"] = "wh2_main_def",
        ["wh2_main_def_ssildra_tor"] = "wh2_main_def",
        ["wh2_main_def_the_forgebound"] = "wh2_main_def",
        ["wh2_main_dwf_greybeards_prospectors"] = "wh_main_group_dwarfs",
        ["wh2_main_dwf_karak_zorn"] = "wh_main_group_dwarfs",
        ["wh2_main_dwf_spine_of_sotek_dwarfs"] = "wh_main_group_dwarfs",
        ["wh2_main_emp_new_world_colonies"] = "wh_main_group_empire",
        ["wh2_main_emp_pirates_of_sartosa"] = "wh_main_group_empire",
        ["wh2_main_emp_sudenburg"] = "wh_main_group_empire",
        ["wh2_main_grn_arachnos"] = "wh_main_group_greenskins",
        ["wh2_main_grn_arachnos_waaagh"] = "wh_main_group_greenskins",
        ["wh2_main_grn_blue_vipers"] = "wh_main_group_savage_orcs",
        ["wh2_main_grn_blue_vipers_waaagh"] = "wh_main_group_savage_orcs",
        ["wh2_main_hef_avelorn"] = "wh2_main_hef",
        ["wh2_main_hef_caledor"] = "wh2_main_hef",
        ["wh2_main_hef_chrace"] = "wh2_main_hef",
        ["wh2_main_hef_citadel_of_dusk"] = "wh2_main_hef",
        ["wh2_main_hef_cothique"] = "wh2_main_hef",
        ["wh2_main_hef_eataine"] = "wh2_main_hef",
        ["wh2_main_hef_ellyrion"] = "wh2_main_hef",
        ["wh2_main_hef_fortress_of_dawn"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves_qb1"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves_qb2"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves_qb3"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves_qb4"] = "wh2_main_hef",
        ["wh2_main_hef_high_elves_rebels"] = "wh2_main_hef",
        ["wh2_main_hef_nagarythe"] = "wh2_main_hef",
        ["wh2_main_hef_order_of_loremasters"] = "wh2_main_hef",
        ["wh2_main_hef_saphery"] = "wh2_main_hef",
        ["wh2_main_hef_tiranoc"] = "wh2_main_hef",
        ["wh2_main_hef_tor_elasor"] = "wh2_main_hef",
        ["wh2_main_hef_yvresse"] = "wh2_main_hef",
        ["wh2_main_lzd_hexoatl"] = "wh2_main_lzd",
        ["wh2_main_lzd_itza"] = "wh2_main_lzd",
        ["wh2_main_lzd_last_defenders"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen_qb1"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen_qb2"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen_qb3"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen_qb4"] = "wh2_main_lzd",
        ["wh2_main_lzd_lizardmen_rebels"] = "wh2_main_lzd",
        ["wh2_main_lzd_sentinels_of_xeti"] = "wh2_main_lzd",
        ["wh2_main_lzd_southern_sentinels"] = "wh2_main_lzd",
        ["wh2_main_lzd_teotiqua"] = "wh2_main_lzd",
        ["wh2_main_lzd_tlaqua"] = "wh2_main_lzd",
        ["wh2_main_lzd_tlaxtlan"] = "wh2_main_lzd",
        ["wh2_main_lzd_xlanhuapec"] = "wh2_main_lzd",
        ["wh2_main_lzd_zlatan"] = "wh2_main_lzd",
        ["wh2_main_nor_aghol"] = "wh_main_group_norsca",
        ["wh2_main_nor_hung_incursion_def"] = "wh_main_group_norsca",
        ["wh2_main_nor_hung_incursion_hef"] = "wh_main_group_norsca",
        ["wh2_main_nor_hung_incursion_lzd"] = "wh_main_group_norsca",
        ["wh2_main_nor_hung_incursion_skv"] = "wh_main_group_norsca",
        ["wh2_main_nor_mung"] = "wh_main_group_norsca",
        ["wh2_main_nor_skeggi"] = "wh_main_group_norsca",
        ["wh2_main_rogue_abominations"] = "wh2_main_rogue_abominations",
        ["wh2_main_rogue_beastcatchas"] = "wh2_main_rogue_beastcatchas",
        ["wh2_main_rogue_bernhoffs_brigands"] = "wh2_main_rogue_bernhoffs_brigands",
        ["wh2_main_rogue_black_spider_tribe"] = "wh2_main_rogue_black_spider_tribe",
        ["wh2_main_rogue_boneclubbers_tribe"] = "wh2_main_rogue_boneclubbers_tribe",
        ["wh2_main_rogue_celestial_storm"] = "wh2_main_rogue_celestial_storm",
        ["wh2_main_rogue_college_of_pyrotechnics"] = "wh2_main_rogue_college_of_pyrotechnics",
        ["wh2_main_rogue_def_chs_vashnaar"] = "wh2_main_rogue_vashnaars_conquest",
        ["wh2_main_rogue_def_mengils_manflayers"] = "wh2_main_rogue_mengils_manflayers",
        ["wh2_main_rogue_doomseekers"] = "wh2_main_rogue_doomseekers",
        ["wh2_main_rogue_doomseekers_qb1"] = "wh2_main_rogue_doomseekers",
        ["wh2_main_rogue_gerhardts_mercenaries"] = "wh2_main_rogue_gerhardts_mercenaries",
        ["wh2_main_rogue_gerhardts_mercenaries_qb1"] = "wh2_main_rogue_gerhardts_mercenaries",
        ["wh2_main_rogue_hef_tor_elithis"] = "wh2_main_rogue_tor_elithis",
        ["wh2_main_rogue_hung_warband"] = "wh2_main_rogue_hung_warband",
        ["wh2_main_rogue_jerrods_errantry"] = "wh2_main_rogue_jerrods_errantry",
        ["wh2_main_rogue_mangy_houndz"] = "wh2_main_rogue_mangy_houndz",
        ["wh2_main_rogue_morrsliebs_howlers"] = "wh2_main_rogue_morrsliebs_howlers",
        ["wh2_main_rogue_pirates_of_the_far_sea"] = "wh2_main_rogue_pirates_of_the_far_sea",
        ["wh2_main_rogue_pirates_of_the_southern_ocean"] = "wh2_main_rogue_pirates_of_the_southern_ocean",
        ["wh2_main_rogue_pirates_of_trantio"] = "wh2_main_rogue_pirates_of_trantio",
        ["wh2_main_rogue_scions_of_tesseninck"] = "wh2_main_rogue_scions_of_tesseninck",
        ["wh2_main_rogue_scourge_of_aquitaine"] = "wh2_main_rogue_scourge_of_aquitaine",
        ["wh2_main_rogue_stuff_snatchers"] = "wh2_main_rogue_stuff_snatchers",
        ["wh2_main_rogue_teef_snatchaz"] = "wh2_main_rogue_teef_snatchaz",
        ["wh2_main_rogue_the_wandering_dead"] = "wh2_main_rogue_the_wandering_dead",
        ["wh2_main_rogue_troll_skullz"] = "wh2_main_rogue_troll_skullz",
        ["wh2_main_rogue_vauls_expedition"] = "wh2_main_rogue_vauls_expedition",
        ["wh2_main_rogue_vmp_heirs_of_mourkain"] = "wh2_main_rogue_heirs_of_mourkain",
        ["wh2_main_rogue_wef_hunters_of_kurnous"] = "wh2_main_rogue_hunters_of_kurnous",
        ["wh2_main_rogue_worldroot_rangers"] = "wh2_main_rogue_worldroot_rangers",
        ["wh2_main_rogue_wrath_of_nature"] = "wh2_main_rogue_wrath_of_nature",
        ["wh2_main_skv_clan_eshin"] = "wh2_main_skv",
        ["wh2_main_skv_clan_eshin_separatists"] = "wh2_main_skv",
        ["wh2_main_skv_clan_gnaw"] = "wh2_main_skv",
        ["wh2_main_skv_clan_mordkin"] = "wh2_main_skv",
        ["wh2_main_skv_clan_mors"] = "wh2_main_skv",
        ["wh2_main_skv_clan_mors_separatists"] = "wh2_main_skv",
        ["wh2_main_skv_clan_moulder"] = "wh2_main_skv",
        ["wh2_main_skv_clan_moulder_separatists"] = "wh2_main_skv",
        ["wh2_main_skv_clan_pestilens"] = "wh2_main_skv",
        ["wh2_main_skv_clan_pestilens_separatists"] = "wh2_main_skv",
        ["wh2_main_skv_clan_septik"] = "wh2_main_skv",
        ["wh2_main_skv_clan_skryre"] = "wh2_main_skv_ikit",
        ["wh2_main_skv_clan_skryre_separatists"] = "wh2_main_skv",
        ["wh2_main_skv_clan_spittel"] = "wh2_main_skv",
        ["wh2_main_skv_grey_seer_clan"] = "wh2_main_skv",
        ["wh2_main_skv_skaven"] = "wh2_main_skv",
        ["wh2_main_skv_skaven_qb1"] = "wh2_main_skv",
        ["wh2_main_skv_skaven_qb2"] = "wh2_main_skv",
        ["wh2_main_skv_skaven_qb3"] = "wh2_main_skv",
        ["wh2_main_skv_skaven_qb4"] = "wh2_main_skv",
        ["wh2_main_skv_skaven_rebels"] = "wh2_main_skv",
        ["wh2_main_skv_unknown_clan_def"] = "wh2_main_skv",
        ["wh2_main_skv_unknown_clan_hef"] = "wh2_main_skv",
        ["wh2_main_skv_unknown_clan_lzd"] = "wh2_main_skv",
        ["wh2_main_skv_unknown_clan_skv"] = "wh2_main_skv",
        ["wh2_main_vmp_necrarch_brotherhood"] = "wh_main_group_vampire_counts",
        ["wh2_main_vmp_strygos_empire"] = "wh_main_group_vampire_counts",
        ["wh2_main_vmp_the_silver_host"] = "wh_main_group_vampire_counts",
        ["wh2_main_wef_bowmen_of_oreon"] = "wh_dlc05_group_wood_elves",
        ["wh2_twa03_def_rakarth"] = "wh2_main_def",
        ["wh2_twa03_def_rakarth_separatists"] = "wh2_main_def",
        ["wh3_dlc20_brt_march_of_couronne"] = "wh_main_group_bretonnia",
        ["wh3_dlc20_chs_azazel"] = "wh3_dlc20_group_chs_azazel",
        ["wh3_dlc20_chs_chaos_qb4"] = "wh_main_group_chaos",
        ["wh3_dlc20_chs_festus"] = "wh3_dlc20_group_chs_festus",
        ["wh3_dlc20_chs_kholek"] = "wh_main_group_chaos",
        ["wh3_dlc20_chs_sigvald"] = "wh_main_group_chaos",
        ["wh3_dlc20_chs_valkia"] = "wh3_dlc20_group_chs_valkia",
        ["wh3_dlc20_chs_vilitch"] = "wh3_dlc20_group_chs_vilitch",
        ["wh3_dlc20_kho_blood_keepers"] = "wh3_main_kho",
        ["wh3_dlc20_nor_dolgan"] = "wh_main_group_norsca_steppe",
        ["wh3_dlc20_nor_kuj"] = "wh_main_group_norsca_steppe",
        ["wh3_dlc20_nor_kul"] = "wh_main_group_norsca_steppe",
        ["wh3_dlc20_nor_tong"] = "wh_main_group_norsca",
        ["wh3_dlc20_nor_yusak"] = "wh_main_group_norsca_steppe",
        ["wh3_dlc20_nur_pallid_nurslings"] = "wh3_main_nur",
        ["wh3_dlc20_sla_keepers_of_bliss"] = "wh3_main_sla",
        ["wh3_dlc20_tze_apostles_of_change"] = "wh3_main_tze",
        ["wh3_dlc20_tze_the_sightless"] = "wh3_main_tze",
        ["wh3_dlc21_cst_dead_flag_fleet"] = "wh2_dlc11_group_vampire_coast",
        ["wh3_dlc21_nor_wyrmkins"] = "wh_main_group_norsca",
        ["wh3_dlc21_vmp_jiangshi_rebels"] = "wh_main_group_vampire_counts",
        ["wh3_dlc21_wef_spirits_of_shanlin"] = "wh_dlc05_group_wood_elves",
        ["wh3_dlc23_chd_astragoth"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_chaos_dwarfs"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_chaos_dwarfs_qb1"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_chaos_dwarfs_qb2"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_chaos_dwarfs_qb3"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_chaos_dwarfs_rebels"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_conclave"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_legion_of_azgorh"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_minor_faction"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_chd_zhatan"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc23_rogue_karaz_a_karak_expedition"] = "wh3_dlc23_rogue_karaz_a_karak_expedition",
        ["wh3_dlc23_rogue_sacred_host_of_tepok"] = "wh3_dlc23_rogue_sacred_host_of_tepok",
        ["wh3_dlc23_rogue_the_cult_of_morgrim"] = "wh3_dlc23_rogue_the_cult_of_morgrim",
        ["wh3_dlc24_cst_vampire_coast_bloated_rebels"] = "wh2_dlc11_group_vampire_coast",
        ["wh3_dlc24_cth_the_celestial_court"] = "wh3_main_cth",
        ["wh3_dlc24_grn_chaos_dwarfs_labourer_rebels"] = "wh3_dlc24_group_labourer_rebels",
        ["wh3_dlc24_ksl_daughters_of_the_forest"] = "wh3_main_ksl",
        ["wh3_dlc24_lzd_lizardmen_invasion"] = "wh2_main_lzd",
        ["wh3_dlc24_tze_the_deceivers"] = "wh3_main_tze",
        ["wh3_dlc25_chd_chaos_dwarfs_invasion"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh3_dlc25_dwf_malakai"] = "wh_main_group_dwarfs",
        ["wh3_dlc25_kho_khorne_invasion"] = "wh3_main_kho",
        ["wh3_dlc25_nur_epidemius"] = "wh3_main_nur",
        ["wh3_dlc25_nur_nurgle_invasion"] = "wh3_main_nur",
        ["wh3_dlc25_nur_tamurkhan"] = "wh3_dlc25_nur_tamurkhan",
        ["wh3_dlc25_rogue_da_mad_howlerz"] = "wh3_dlc25_rogue_da_mad_howlerz",
        ["wh3_dlc25_sla_slaanesh_invasion"] = "wh3_main_sla",
        ["wh3_dlc25_vmp_the_court_of_night"] = "wh_main_group_vampire_counts",
        ["wh3_dlc25_vmp_vampire_counts_invasion"] = "wh_main_group_vampire_counts",
        ["wh3_dlc25_wef_wood_elves_invasion"] = "wh2_dlc16_group_drycha",
        ["wh3_main_brt_aquitaine"] = "wh_main_group_bretonnia",
        ["wh3_main_chs_dreaded_wo"] = "wh_main_group_chaos",
        ["wh3_main_chs_gharhar"] = "wh_main_group_chaos",
        ["wh3_main_chs_khazag"] = "wh_main_group_chaos",
        ["wh3_main_chs_kvellig"] = "wh_main_group_chaos",
        ["wh3_main_chs_shadow_legion"] = "wh3_main_group_belakor",
        ["wh3_main_chs_tong"] = "wh_main_group_chaos",
        ["wh3_main_cst_dread_rock_privateers"] = "wh2_dlc11_group_vampire_coast",
        ["wh3_main_cth_burning_wind_nomads"] = "wh3_main_cth",
        ["wh3_main_cth_cathay_mp"] = "wh3_main_cth",
        ["wh3_main_cth_cathay_qb1"] = "wh3_main_cth",
        ["wh3_main_cth_cathay_qb2"] = "wh3_main_cth",
        ["wh3_main_cth_cathay_qb3"] = "wh3_main_cth",
        ["wh3_main_cth_cathay_rebels"] = "wh3_main_cth",
        ["wh3_main_cth_celestial_loyalists"] = "wh3_main_cth",
        ["wh3_main_cth_dissenter_lords_of_jinshen"] = "wh3_main_cth",
        ["wh3_main_cth_eastern_river_lords"] = "wh3_main_cth",
        ["wh3_main_cth_imperial_wardens"] = "wh3_main_cth",
        ["wh3_main_cth_rebel_lords_of_nan_yang"] = "wh3_main_cth",
        ["wh3_main_cth_the_jade_custodians"] = "wh3_main_cth",
        ["wh3_main_cth_the_northern_provinces"] = "wh3_main_cth",
        ["wh3_main_cth_the_western_provinces"] = "wh3_main_cth",
        ["wh3_main_dae_daemon_prince"] = "wh3_main_dae",
        ["wh3_main_dae_daemons_qb1"] = "wh3_main_dae",
        ["wh3_main_dwf_karak_azorn"] = "wh_main_group_dwarfs",
        ["wh3_main_dwf_the_ancestral_throng"] = "wh_main_group_dwarfs",
        ["wh3_main_emp_cult_of_sigmar"] = "wh_main_group_empire",
        ["wh3_main_grn_da_cage_breakaz"] = "wh_main_group_greenskins",
        ["wh3_main_grn_dark_land_orcs"] = "wh_main_group_greenskins",
        ["wh3_main_grn_dark_land_orcs_waaagh"] = "wh_main_group_greenskins",
        ["wh3_main_grn_dimned_sun"] = "wh_main_group_savage_orcs",
        ["wh3_main_grn_dimned_sun_waaagh"] = "wh_main_group_savage_orcs",
        ["wh3_main_grn_drippin_fangs"] = "wh_main_group_greenskins",
        ["wh3_main_grn_drippin_fangs_waaagh"] = "wh_main_group_greenskins",
        ["wh3_main_grn_moon_howlerz"] = "wh_main_group_greenskins",
        ["wh3_main_grn_moon_howlerz_waaagh"] = "wh_main_group_greenskins",
        ["wh3_main_grn_slaves_of_zharr"] = "wh_main_group_greenskins",
        ["wh3_main_grn_tusked_sunz"] = "wh_main_group_greenskins",
        ["wh3_main_grn_tusked_sunz_waaagh"] = "wh_main_group_greenskins",
        ["wh3_main_ie_vmp_sires_of_mourkain"] = "wh_main_group_vampire_counts",
        ["wh3_main_kho_bloody_sword"] = "wh3_main_kho",
        ["wh3_main_kho_brazen_throne"] = "wh3_main_kho",
        ["wh3_main_kho_crimson_skull"] = "wh3_main_kho",
        ["wh3_main_kho_exiles_of_khorne"] = "wh3_main_kho",
        ["wh3_main_kho_karneths_sons"] = "wh3_main_kho",
        ["wh3_main_kho_khorne"] = "wh3_main_kho",
        ["wh3_main_kho_khorne_qb1"] = "wh3_main_kho",
        ["wh3_main_kho_khorne_qb2"] = "wh3_main_kho",
        ["wh3_main_kho_khorne_rebels"] = "wh3_main_kho",
        ["wh3_main_ksl_brotherhood_of_the_bear"] = "wh3_main_ksl",
        ["wh3_main_ksl_druzhina_enclave"] = "wh3_main_ksl",
        ["wh3_main_ksl_kislev"] = "wh3_main_ksl",
        ["wh3_main_ksl_kislev_qb1"] = "wh3_main_ksl",
        ["wh3_main_ksl_kislev_qb2"] = "wh3_main_ksl",
        ["wh3_main_ksl_kislev_rebels"] = "wh3_main_ksl",
        ["wh3_main_ksl_ropsmenn_clan"] = "wh3_main_ksl",
        ["wh3_main_ksl_the_great_orthodoxy"] = "wh3_main_ksl",
        ["wh3_main_ksl_the_ice_court"] = "wh3_main_ksl",
        ["wh3_main_ksl_ungol_kindred"] = "wh3_main_ksl",
        ["wh3_main_ksl_ursun_revivalists"] = "wh3_main_ksl",
        ["wh3_main_lzd_tepoks_spawn"] = "wh2_main_lzd",
        ["wh3_main_nur_bubonic_swarm"] = "wh3_main_nur",
        ["wh3_main_nur_maggoth_kin"] = "wh3_main_nur",
        ["wh3_main_nur_nurgle"] = "wh3_main_nur",
        ["wh3_main_nur_nurgle_qb1"] = "wh3_main_nur",
        ["wh3_main_nur_nurgle_qb2"] = "wh3_main_nur",
        ["wh3_main_nur_nurgle_rebels"] = "wh3_main_nur",
        ["wh3_main_nur_poxmakers_of_nurgle"] = "wh3_main_nur",
        ["wh3_main_nur_septic_claw"] = "wh3_main_nur",
        ["wh3_main_ogr_blood_guzzlers"] = "wh3_main_ogr",
        ["wh3_main_ogr_bloodmaw"] = "wh3_main_ogr",
        ["wh3_main_ogr_crossed_clubs"] = "wh3_main_ogr",
        ["wh3_main_ogr_disciples_of_the_maw"] = "wh3_main_ogr",
        ["wh3_main_ogr_eyebiter"] = "wh3_main_ogr",
        ["wh3_main_ogr_feastmaster"] = "wh3_main_ogr",
        ["wh3_main_ogr_fleshgreeders"] = "wh3_main_ogr",
        ["wh3_main_ogr_fulg"] = "wh3_main_ogr",
        ["wh3_main_ogr_goldtooth"] = "wh3_main_ogr",
        ["wh3_main_ogr_lazarghs"] = "wh3_main_ogr",
        ["wh3_main_ogr_loose_tooth"] = "wh3_main_ogr",
        ["wh3_main_ogr_mountaineaters"] = "wh3_main_ogr",
        ["wh3_main_ogr_ogre_kingdoms"] = "wh3_main_ogr",
        ["wh3_main_ogr_ogre_kingdoms_invasion"] = "wh3_main_ogr",
        ["wh3_main_ogr_ogre_kingdoms_qb1"] = "wh3_main_ogr",
        ["wh3_main_ogr_ogre_rebels"] = "wh3_main_ogr",
        ["wh3_main_ogr_rock_skulls"] = "wh3_main_ogr",
        ["wh3_main_ogr_sabreskin"] = "wh3_main_ogr",
        ["wh3_main_ogr_sons_of_the_mountain"] = "wh3_main_ogr",
        ["wh3_main_ogr_thunderguts"] = "wh3_main_ogr",
        ["wh3_main_ogr_treehammers"] = "wh3_main_ogr",
        ["wh3_main_ogre_flamegullets"] = "wh3_main_ogr",
        ["wh3_main_ogre_sharktooth"] = "wh3_main_ogr",
        ["wh3_main_ogre_the_famished"] = "wh3_main_ogr",
        ["wh3_main_rogue_alliance_of_order"] = "wh3_main_rogue_alliance_of_order",
        ["wh3_main_rogue_argfluxs_pyrocasters"] = "wh3_main_dae",
        ["wh3_main_rogue_doombreeds_followers"] = "wh3_main_dae",
        ["wh3_main_rogue_kurgan_warband"] = "wh_main_group_norsca",
        ["wh3_main_rogue_legion_of_gorehath"] = "wh3_main_dae",
        ["wh3_main_rogue_scaberaxs_gluttons"] = "wh3_main_dae",
        ["wh3_main_rogue_scriveners_of_fate"] = "wh3_main_dae",
        ["wh3_main_rogue_shadow_legion"] = "wh3_main_dae",
        ["wh3_main_rogue_the_baleful_princes_muses"] = "wh3_main_dae",
        ["wh3_main_rogue_the_bloody_harvest"] = "wh3_main_kho",
        ["wh3_main_rogue_the_challenge_stone_pact"] = "wh3_main_rogue_the_challenge_stone_pact",
        ["wh3_main_rogue_the_convent"] = "wh3_main_dae",
        ["wh3_main_rogue_the_fluxion_host"] = "wh3_main_tze",
        ["wh3_main_rogue_the_glothal_brood"] = "wh3_main_dae",
        ["wh3_main_rogue_the_pleasure_tide"] = "wh3_main_sla",
        ["wh3_main_rogue_the_putrid_swarm"] = "wh3_main_nur",
        ["wh3_main_rogue_the_treaty_of_ashshair"] = "wh3_main_rogue_the_treaty_of_ashshair",
        ["wh3_main_skv_clan_carrion"] = "wh2_main_skv",
        ["wh3_main_skv_clan_gritus"] = "wh2_main_skv",
        ["wh3_main_skv_clan_krizzor"] = "wh2_main_skv",
        ["wh3_main_skv_clan_morbidus"] = "wh2_main_skv",
        ["wh3_main_skv_clan_skrat"] = "wh2_main_skv",
        ["wh3_main_skv_clan_treecherik"] = "wh2_main_skv",
        ["wh3_main_skv_clan_verms"] = "wh2_main_skv",
        ["wh3_main_sla_exquisite_pain"] = "wh3_main_sla",
        ["wh3_main_sla_rapturous_excess"] = "wh3_main_sla",
        ["wh3_main_sla_seducers_of_slaanesh"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_qb1"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_qb2"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_qb3"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_qb4"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_qb5"] = "wh3_main_sla",
        ["wh3_main_sla_slaanesh_rebels"] = "wh3_main_sla",
        ["wh3_main_sla_subtle_torture"] = "wh3_main_sla",
        ["wh3_main_tmb_deserters_of_khatep"] = "wh2_dlc09_tomb_kings",
        ["wh3_main_tze_all_seeing_eye"] = "wh3_main_tze",
        ["wh3_main_tze_broken_wheel"] = "wh3_main_tze",
        ["wh3_main_tze_flaming_scribes"] = "wh3_main_tze",
        ["wh3_main_tze_oracles_of_tzeentch"] = "wh3_main_tze",
        ["wh3_main_tze_sarthoraels_watchers"] = "wh3_main_tze",
        ["wh3_main_tze_tzeentch"] = "wh3_main_tze",
        ["wh3_main_tze_tzeentch_invasion"] = "wh3_main_tze",
        ["wh3_main_tze_tzeentch_qb1"] = "wh3_main_tze",
        ["wh3_main_tze_tzeentch_qb2"] = "wh3_main_tze",
        ["wh3_main_tze_tzeentch_rebels"] = "wh3_main_tze",
        ["wh3_main_vmp_caravan_of_blue_roses"] = "wh_main_group_vampire_counts",
        ["wh3_main_vmp_lahmian_sisterhood"] = "wh_main_group_vampire_counts",
        ["wh3_main_vmp_nagashizzar"] = "wh_main_group_vampire_counts",
        ["wh3_main_wef_laurelorn"] = "wh_dlc05_group_wood_elves",
        ["wh3_prologue_apostles_of_change"] = "wh3_main_pro_tze",
        ["wh3_prologue_blood_keepers"] = "wh3_main_pro_kho",
        ["wh3_prologue_blood_sayters"] = "wh3_main_pro_kho",
        ["wh3_prologue_dervingard_garrison"] = "wh3_main_ksl",
        ["wh3_prologue_gharhars"] = "wh_main_group_norsca",
        ["wh3_prologue_great_eagle_tribe"] = "wh_main_group_norsca",
        ["wh3_prologue_horde_of_kurnz"] = "wh_main_group_norsca",
        ["wh3_prologue_karneths_sons"] = "wh_main_group_norsca",
        ["wh3_prologue_kislev_expedition"] = "wh3_main_pro_ksl",
        ["wh3_prologue_ksl_petrenkos_raiders"] = "wh3_main_ksl",
        ["wh3_prologue_oath_keepers"] = "wh3_main_pro_tze",
        ["wh3_prologue_sarthoraels_watchers"] = "wh3_main_pro_tze",
        ["wh3_prologue_the_kvelligs"] = "wh_main_group_norsca",
        ["wh3_prologue_the_narj"] = "wh_main_group_norsca",
        ["wh3_prologue_the_nestlings"] = "wh3_main_pro_tze",
        ["wh3_prologue_the_sightless"] = "wh3_main_pro_tze",
        ["wh3_prologue_the_tahmaks"] = "wh_main_group_norsca",
        ["wh3_prologue_tong"] = "wh_main_group_norsca",
        ["wh3_prologue_tribe_of_the_hound"] = "wh3_main_pro_kho",
        ["wh_dlc03_bst_beastmen"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_ally"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_chaos"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_chaos_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_qb1"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_qb2"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_qb3"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_rebels"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_beastmen_rebels_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_jagged_horn"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_jagged_horn_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_redhorn"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_bst_redhorn_brayherd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc03_grn_black_pit"] = "wh_main_group_greenskins",
        ["wh_dlc03_grn_black_pit_waaagh"] = "wh_main_group_greenskins",
        ["wh_dlc05_bst_morghur_herd"] = "wh_dlc03_group_beastmen",
        ["wh_dlc05_wef_argwylon"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_torgovann"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wood_elves"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wood_elves_qb1"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wood_elves_qb2"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wood_elves_qb3"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wood_elves_rebels"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc05_wef_wydrioth"] = "wh_dlc05_group_wood_elves",
        ["wh_dlc08_chs_chaos_challenger_khorne"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_khorne_qb"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_nurgle"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_nurgle_qb"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_slaanesh"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_slaanesh_qb"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_tzeentch"] = "wh_main_group_chaos",
        ["wh_dlc08_chs_chaos_challenger_tzeentch_qb"] = "wh_main_group_chaos",
        ["wh_dlc08_nor_goromadny_tribe"] = "wh_main_group_norsca",
        ["wh_dlc08_nor_helspire_tribe"] = "wh_main_group_norsca",
        ["wh_dlc08_nor_naglfarlings"] = "wh_main_group_norsca",
        ["wh_dlc08_nor_norsca"] = "wh_main_group_norsca",
        ["wh_dlc08_nor_vanaheimlings"] = "wh_main_group_norsca",
        ["wh_dlc08_nor_wintertooth"] = "wh_main_group_norsca",
        ["wh_main_brt_artois"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bastonne"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bordeleaux"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bretonnia"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bretonnia_qb1"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bretonnia_qb2"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bretonnia_qb3"] = "wh_main_group_bretonnia",
        ["wh_main_brt_bretonnia_rebels"] = "wh_main_group_bretonnia",
        ["wh_main_brt_carcassonne"] = "wh_main_group_bretonnia",
        ["wh_main_brt_lyonesse"] = "wh_main_group_bretonnia",
        ["wh_main_brt_parravon"] = "wh_main_group_bretonnia",
        ["wh_main_chs_chaos"] = "wh_main_group_chaos",
        ["wh_main_chs_chaos_qb1"] = "wh_main_group_chaos",
        ["wh_main_chs_chaos_qb2"] = "wh_main_group_chaos",
        ["wh_main_chs_chaos_qb3"] = "wh_main_group_chaos",
        ["wh_main_chs_chaos_rebels"] = "wh_main_group_chaos",
        ["wh_main_chs_chaos_separatists"] = "wh_main_group_chaos",
        ["wh_main_dwf_barak_varr"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarf_rebels"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_qb1"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_qb2"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_qb3"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_qb4"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_seperatists_qb1"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_seperatists_qb2"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_seperatists_qb3"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_dwarfs_seperatists_qb4"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_azul"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_hirn"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_izor"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_kadrin"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_norn"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_karak_ziflin"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_kraka_drak"] = "wh_main_group_dwarfs",
        ["wh_main_dwf_zhufbar"] = "wh_main_group_dwarfs",
        ["wh_main_emp_averland"] = "wh_main_group_empire",
        ["wh_main_emp_empire"] = "wh_main_group_empire_reikland",
        ["wh_main_emp_empire_qb1"] = "wh_main_group_empire",
        ["wh_main_emp_empire_qb2"] = "wh_main_group_empire",
        ["wh_main_emp_empire_qb3"] = "wh_main_group_empire",
        ["wh_main_emp_empire_qb4"] = "wh_main_group_empire_reikland",
        ["wh_main_emp_empire_qb5"] = "wh_main_group_empire",
        ["wh_main_emp_empire_qb_intro"] = "wh_main_group_empire",
        ["wh_main_emp_empire_rebels"] = "wh_main_group_empire",
        ["wh_main_emp_empire_rebels_qb1"] = "wh_main_group_empire",
        ["wh_main_emp_empire_separatists"] = "wh_main_group_empire",
        ["wh_main_emp_hochland"] = "wh_main_group_empire",
        ["wh_main_emp_marienburg"] = "wh_main_group_empire",
        ["wh_main_emp_marienburg_rebels"] = "wh_main_group_empire",
        ["wh_main_emp_middenland"] = "wh_main_group_empire",
        ["wh_main_emp_nordland"] = "wh_main_group_empire",
        ["wh_main_emp_ostermark"] = "wh_main_group_empire",
        ["wh_main_emp_ostland"] = "wh_main_group_empire",
        ["wh_main_emp_stirland"] = "wh_main_group_empire",
        ["wh_main_emp_talabecland"] = "wh_main_group_empire",
        ["wh_main_emp_wissenland"] = "wh3_dlc25_group_elspeth",
        ["wh_main_grn_black_venom"] = "wh_main_group_greenskins",
        ["wh_main_grn_black_venom_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_bloody_spearz"] = "wh_main_group_greenskins",
        ["wh_main_grn_bloody_spearz_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_broken_nose"] = "wh_main_group_greenskins",
        ["wh_main_grn_broken_nose_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_crooked_moon"] = "wh_main_group_greenskins",
        ["wh_main_grn_crooked_moon_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_qb1"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_qb2"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_qb3"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_qb4"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_rebels"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_rebels_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_greenskins_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_necksnappers"] = "wh_main_group_greenskins",
        ["wh_main_grn_necksnappers_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_orcs_of_the_bloody_hand"] = "wh_main_group_greenskins",
        ["wh_main_grn_orcs_of_the_bloody_hand_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_red_eye"] = "wh_main_group_greenskins",
        ["wh_main_grn_red_eye_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_red_fangs"] = "wh_main_group_greenskins",
        ["wh_main_grn_red_fangs_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_scabby_eye"] = "wh_main_group_greenskins",
        ["wh_main_grn_scabby_eye_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_skull-takerz"] = "wh_main_group_greenskins",
        ["wh_main_grn_skull-takerz_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_skullsmasherz"] = "wh_main_group_greenskins",
        ["wh_main_grn_skullsmasherz_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_teef_snatchaz"] = "wh_main_group_greenskins",
        ["wh_main_grn_teef_snatchaz_waaagh"] = "wh_main_group_greenskins",
        ["wh_main_grn_top_knotz"] = "wh_main_group_savage_orcs",
        ["wh_main_grn_top_knotz_waaagh"] = "wh_main_group_savage_orcs",
        ["wh_main_nor_aesling"] = "wh_main_group_norsca",
        ["wh_main_nor_baersonling"] = "wh_main_group_norsca",
        ["wh_main_nor_bjornling"] = "wh_main_group_norsca",
        ["wh_main_nor_graeling"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_qb1"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_qb2"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_qb3"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_rebels"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_separatists"] = "wh_main_group_norsca",
        ["wh_main_nor_norsca_separatists_sorcerer_lord"] = "wh_main_group_norsca",
        ["wh_main_nor_sarl"] = "wh_main_group_norsca",
        ["wh_main_nor_skaeling"] = "wh_main_group_norsca",
        ["wh_main_nor_varg"] = "wh_main_group_norsca",
        ["wh_main_teb_border_princes"] = "wh_main_group_teb",
        ["wh_main_teb_border_princes_rebels"] = "wh_main_group_teb",
        ["wh_main_teb_estalia"] = "wh_main_group_teb",
        ["wh_main_teb_estalia_rebels"] = "wh_main_group_teb",
        ["wh_main_teb_tilea"] = "wh_main_group_teb",
        ["wh_main_teb_tilea_rebels"] = "wh_main_group_teb",
        ["wh_main_vmp_mousillon"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_rival_sylvanian_vamps"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_schwartzhafen"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_counts"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_counts_qb1"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_counts_qb2"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_counts_qb3"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_counts_qb4"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_vampire_rebels"] = "wh_main_group_vampire_counts",
        ["wh_main_vmp_waldenhof"] = "wh_main_group_vampire_counts",
    },
    faction_to_agents = {},
    agent_types = {"champion", "dignitary", "engineer", "runesmith", "spy", "wizard"},
    agents = {}
        
}


function pttg_merc_pool:reset_merc_pool()
    for _, tiers in pairs(self.merc_pool) do
        for _, units in ipairs(tiers) do
            for _, unit_info in ipairs(units) do
                local unit = unit_info.key
                self:add_unit_to_pool(unit, 0)
            end
        end
    end
end

function pttg_merc_pool:get_tier(group)
    local tier = self.tiers[group]

    if not tier then
        return 4
    end

    return tier
end

local function get_weight(weight)
    local max = 3
    local min = 1
    local value = (max - weight) / (max - min)
    return ((value) * (max - min) + min)
end

function pttg_merc_pool:init_merc_pool()
    pttg:log(string.format("[pttg_MercPool] Initialising units merc pool."))

    for unit_key, merc_info in pairs(self.merc_units) do
        pttg:log(string.format("[pttg_MercPool] Adding unit %s", merc_info:repr()))

        for _, military_group in pairs(merc_info.military_groupings) do
            pttg:log(string.format("[pttg_MercPool] Inserting in %s at %s", military_group, merc_info.tier))
            if not self.merc_pool[military_group] then
                self.merc_pool[military_group] = { {}, {}, {}, {} }
            end
            table.insert(self.merc_pool[military_group][merc_info.tier], merc_info)
        end
    end
end

function pttg_merc_pool:add_unit(unit_info)
    local weight = unit_info[3]
    local extra_info = unit_info[4]

    extra_info.weight = get_weight(weight)
    extra_info.tier = extra_info.tier or self:get_tier(unit_info[2])
    extra_info.cost = extra_info.cost or 2

    self.merc_units[unit_info[1]] = PttG_MercInfo:new(unit_info[1], extra_info)
end

function pttg_merc_pool:add_unit_list(units)
    for _, unit in pairs(units) do
        self:add_unit(unit)
    end
end

function pttg_merc_pool:add_agent(agent_info)
    pttg:log(string.format("Adding agent of type %s, subtype %s to faction %s", tostring(agent_info.type), tostring(agent_info.subtype), tostring(agent_info.faction) ))
    
    local agent = PttG_AgentInfo:new(agent_info.subtype, agent_info)

    if not agent then
        script_error('Cannot create agent. Skipping.')
        return false
    end

    if not self.faction_to_agents[agent.faction] then
        self.faction_to_agents[agent.faction] = {}
    end

    if not self.faction_to_agents[agent.faction][agent.type] then
        self.faction_to_agents[agent.faction][agent.type] = {}
    end
    if agent.recruitable then
        table.insert(self.faction_to_agents[agent.faction][agent.type], agent)
    end
    self.agents[agent.subtype] = agent
    
end

function pttg_merc_pool:add_agent_list(agents)
    for _, agent in pairs(agents) do
        self:add_agent(agent)
    end
end

function pttg_merc_pool:init_active_merc_pool()
    self.active_merc_pool = pttg:get_state('recruitable_mercs')

    for unit, count in pairs(self.active_merc_pool) do
        self:add_unit_to_pool(unit, count)
    end
end

function pttg_merc_pool:reset_active_merc_pool()
    for unit, count in pairs(self.active_merc_pool) do
        self:add_unit_to_pool(unit, 0)
    end
    self.active_merc_pool = {}
    pttg:set_state("recruitable_mercs", self.active_merc_pool)
end

function pttg_merc_pool:add_unit_to_pool(unit, count)
    pttg:log(string.format("[pttg_RewardChosenRecruit] Recruiting %s(%s)", unit, tostring(count)))

    local faction = cm:get_local_faction()

    cm:add_unit_to_faction_mercenary_pool(
        faction,
        unit,
        "pttg_raise_dead",
        count, 0, 20, count,
        "", "", "",
        false, "pttg_" .. unit
    )
end

function pttg_merc_pool:add_active_unit(unit, count)
    pttg:log("[pttg_merc_pool]Adding active recruitable unit [" .. unit .. "]");
    if self.active_merc_pool[unit] then
        self.active_merc_pool[unit] = self.active_merc_pool[unit] + count
    else
        self.active_merc_pool[unit] = count
    end
    pttg_merc_pool:add_unit_to_pool(unit, count)
    
    pttg:set_state('recruitable_mercs', self.active_merc_pool)
end

function pttg_merc_pool:add_active_units(units)
    for _, unit in pairs(units) do
        pttg:log("[pttg_merc_pool]Adding active recruitable unit [" .. unit .. "]");
        if self.active_merc_pool[unit] then
            self.active_merc_pool[unit] = self.active_merc_pool[unit] + 1
        else
            self.active_merc_pool[unit] = 1
        end
    end

    for unit, count in pairs(self:get_active_units_with_counts()) do
        pttg_merc_pool:add_unit_to_pool(unit, count)
    end

    pttg:set_state('recruitable_mercs', self.active_merc_pool)
end

function pttg_merc_pool:get_active_units()
    local units = {}
    for unit, count in pairs(self.active_merc_pool) do
        for i = 1, count do
            table.insert(units, unit)
        end
    end
end

function pttg_merc_pool:get_active_units_with_counts()
    return self.active_merc_pool
end

function pttg_merc_pool:get_pool(key)
    pttg:log("Getting mercenary pool")
    local military_grouping = self.faction_to_military_grouping[key] or key
    pttg:log("Getting pool ["..military_grouping.."] for key: "..key)
    if not self.merc_pool[military_grouping] then
        script_error("Could not find a mercenary pool for given military grouping.")
        return false
    end
    return self.merc_pool[military_grouping]
end

function pttg_merc_pool:get_random_general(faction_key)
    local subgroups = {}
    local subkeys = {}

    for _, agent in pairs(self.faction_to_agents[faction_key]['general']) do
        if self:is_eligible_agent(agent, faction_key) then
            local parts = string.pttg_split(agent.subtype, '_')

            local joined = ""
            for i = 4, math.max(#parts - 2, 4) do
                joined = joined..'_'..(parts[i] or "")
            end

            if subgroups[joined] then
                table.insert(subgroups[joined], agent)
            else
                subgroups[joined] = { agent }
                table.insert(subkeys, joined)
            end
        end
    end

    local random_characters = subgroups[subkeys[math.random(#subkeys)]]
    return random_characters[math.random(#random_characters)]
end

function pttg_merc_pool:get_random_agent(faction_key, agent_type)
    pttg:log("Getting random agent for "..faction_key.." of type: "..tostring(agent_type))
    local subgroups = {}
    local subkeys = {}
    
    local agents = {}

    if type(agent_type) == "string" then
        for _, agent in pairs(self.faction_to_agents[faction_key][agent_type] or {}) do
            if self:is_eligible_agent(agent, faction_key) then
                table.insert(agents, agent)
            end
        end
    elseif type(agent_type) == "table" then
        for _, subtype in pairs(agent_type) do
            for _, agent in pairs(self.faction_to_agents[faction_key][subtype] or {}) do
                if self:is_eligible_agent(agent, faction_key) then
                    table.insert(agents, agent)
                end
            end
        end
    else
        for _, subtype in pairs(self.agent_types) do
            for _, agent in pairs(self.faction_to_agents[faction_key][subtype] or {}) do
                if self:is_eligible_agent(agent, faction_key) then
                    table.insert(agents, agent)
                end
            end
        end
    end

    for _, agent in pairs(agents) do
        local parts = string.pttg_split(agent.subtype, '_')

        local joined = ""
        for i = 4, math.max(#parts - 2, 4) do
            joined = joined..'_'..(parts[i] or "")
        end

        if subgroups[joined] then
            table.insert(subgroups[joined], agent)
        else
            subgroups[joined] = { agent }
            table.insert(subkeys, joined)
        end
    end
    
    local random_agents = subgroups[subkeys[math.random(#subkeys)]]
    local random_agent = random_agents[math.random(#random_agents)]
    return random_agent
end

function pttg_merc_pool:trigger_recruitment(amount, recruit_chances, unique_only)
    local faction = cm:get_local_faction()
    pttg:log(string.format("[pttg_RecruitReward] Recruiting units for %s", faction:culture()))

    local rando_tiers = { 0, 0, 0 }

    for i = 1, amount do
        local offset = pttg:get_state('recruit_rarity_offset')
        local rando_tier = cm:random_number(100) + offset
        pttg:log(string.format("[pttg_RecruitReward] Adding tier for roll %s(%s)", rando_tier, offset))

        if rando_tier < recruit_chances[1] or recruit_chances[1] >= recruit_chances[2] then
            rando_tiers[1] = rando_tiers[1] + 1
            pttg:set_state('recruit_rarity_offset', math.min(40, offset + 1))
        elseif rando_tier < recruit_chances[2] or recruit_chances[2] >= recruit_chances[3] then
            rando_tiers[2] = rando_tiers[2] + 1
            if recruit_chances[2] >= recruit_chances[3] then 
                -- reset rarity offset if this is the max attainable rarity
                pttg:set_state('recruit_rarity_offset', -5)
            end
        else
            rando_tiers[3] = rando_tiers[3] + 1
            pttg:set_state('recruit_rarity_offset', -5)
        end
    end

    local merc_pool = self:get_pool(faction:name())
    if not merc_pool then
        script_error("No available merc pool for faction: "..faction:name())
        return false
    end

    for tier, count in pairs(rando_tiers) do
        if count > 0 then
            pttg:log(string.format("[pttg_RecruitReward] Adding %s units of tier %s", count, tier))
            local available_merc_pool = merc_pool[tier]

            local recruit_pool_key = "pttg_recruit_reward"
            pttg_pool_manager:new_pool(recruit_pool_key)

            for _, merc in pairs(available_merc_pool) do
                if self:is_eligible_unit(merc, cm:get_local_faction_name()) then
                    pttg_pool_manager:add_item(recruit_pool_key, merc.key, merc.weight)
                end
            end

            pttg_merc_pool:add_active_units(pttg_pool_manager:generate_pool(recruit_pool_key, count, true, unique_only))
        end
    end
end

function pttg_merc_pool:is_eligible_unit(object, faction_key)
    if faction_key ~= cm:get_local_faction_name() then
        return true
    end
    local record = cco("CcoMainUnitRecord", object.key)
    if not record:Call('IsOwned') then
        pttg:log("Player does not have required ownership of dlc for: "..object:repr())
        return false
    end
    return true
end

function pttg_merc_pool:is_eligible_agent(object, faction_key)
    if faction_key ~= cm:get_local_faction_name() then
        return true
    end
   local record = cco("CcoAgentSubtypeRecord", object.key)
   if not record:Call('AssociatedUnitOverride.IsOwned') then
       pttg:log("Player does not have required ownership of dlc for: "..object:repr())
       return false
   end

   return true
end

function pttg_merc_pool:recruitable_agents(faction_name)
    local result = {}
    local agent_pairs = self.faction_to_agents[faction_name]

    for agent_type, agents in pairs(agent_pairs) do
        for _, agent in pairs(agents) do
            if agent.recruitable and self:is_eligible_agent(agent, faction_name) then
                if result[agent_type] then
                    table.insert(result[agent_type], agent)
                else
                    result[agent_type] = { agent }
                end
            end
        end
    end
    return result
end



function pttg_merc_pool:update_merc(merc)
    pttg:log("Updating merc ", merc.key)
    merc_info = self.merc_units[merc.key]
    for key, val in pairs(merc.info) do
        if val ~= nil then
            if type(val) == 'table' then
                for _, item in pairs(val) do
                    table.insert(merc_info[key], item)
                end
            else
                merc_info[key] = val
            end
        end
    end
end

function pttg_merc_pool:fix_factions()
    local mercenaries = {
        -- Fix orges being a little too monstrous
        { key = "wh3_main_ogr_inf_ogres_0", info = { military_groupings = nil, category = "melee_infantry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_inf_ogres_1", info = { military_groupings = nil, category = "melee_infantry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_inf_ogres_2", info = { military_groupings = nil, category = "melee_infantry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_cav_mournfang_cavalry_0", info = { military_groupings = nil, category = "melee_cavalry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_cav_mournfang_cavalry_1", info = { military_groupings = nil, category = "melee_cavalry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_cav_mournfang_cavalry_2", info = { military_groupings = nil, category = "melee_cavalry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_inf_ironguts_0", info = { military_groupings = nil, category = "melee_infantry", tier = nil, cost = nil }},
        { key = "wh3_main_ogr_inf_leadbelchers_0", info = { military_groupings = nil, category = "missile_infantry", tier = nil, cost = nil }},

        { key = "wh2_dlc16_wef_mon_cave_bats", info = { military_groupings = {"wh2_dlc16_group_drycha"}, category = nil, tier = nil, cost = 1 }},

    }
    for _, merc in pairs(mercenaries) do
        merc_info = self.merc_units[merc.key]
        for key, val in pairs(merc.info) do
            if val ~= nil then
                if type(val) == 'table' then
                    for _, item in pairs(val) do
                        table.insert(merc_info[key], item)
                    end
                else
                    merc_info[key] = val
                end
            end
        end
    end
end




core:add_listener(
    "pttg_MercPool",
    "pttg_init_complete",
    true,
    function(context)
        pttg_merc_pool:reset_merc_pool()
        pttg_merc_pool:init_merc_pool()
    end,
    false
)

core:add_static_object("pttg_merc_pool", pttg_merc_pool);
