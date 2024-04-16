local pttg = core:get_static_object("pttg");
local ttc = core:get_static_object("tabletopcaps");

local pttg_merc_pool = {
    merc_pool = {},
    merc_units = {
        ["wh3_main_cth_inf_jade_warrior_crossbowmen_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_jade_warrior_crossbowmen_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_jade_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_jade_warriors_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_peasant_archers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_peasant_spearmen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_cav_peasant_horsemen_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_iron_hail_gunners_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_cav_jade_lancers_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_art_grand_cannon_0"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_crane_gunners_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_veh_sky_junk_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_veh_sky_lantern_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_dragon_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_inf_dragon_guard_crossbowmen_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_cav_jade_longma_riders_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_art_fire_rain_rocket_battery_0"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_mon_terracotta_sentinel_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_cth_veh_war_compass_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_bloodletters_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_chaos_warhounds_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_chaos_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_chaos_warriors_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_chaos_warriors_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_bloodletters_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_cav_bloodcrushers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_cav_gorebeast_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_mon_khornataurs_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_mon_khornataurs_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_flesh_hounds_of_khorne_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_inf_chaos_furies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_cav_skullcrushers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_mon_bloodthirster_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_mon_soul_grinder_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_mon_spawn_of_khorne_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_veh_blood_shrine_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_kho_veh_skullcannon_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_cav_winged_lancers_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_armoured_kossars_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_armoured_kossars_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_cav_horse_archers_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_cav_horse_raiders_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_kossars_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_kossars_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_streltsi_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_cav_war_bear_riders_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_cav_gryphon_legion_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_tzar_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_tzar_guard_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_veh_heavy_war_sled_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_veh_light_war_sled_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_mon_elemental_bear_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_mon_snow_leopard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_veh_little_grom_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_ice_guard_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ksl_inf_ice_guard_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_inf_forsaken_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_inf_nurglings_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_inf_plaguebearers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_plague_toads_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_cav_pox_riders_of_nurgle_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_inf_chaos_furies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_beast_of_nurgle_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_inf_plaguebearers_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_rot_flies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_cav_plague_drones_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_cav_plague_drones_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_great_unclean_one_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_soul_grinder_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_spawn_of_nurgle_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_gnoblars_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_gnoblars_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_ogres_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_ogres_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_ogres_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_cav_mournfang_cavalry_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_cav_mournfang_cavalry_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_cav_mournfang_cavalry_2"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_ironguts_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_leadbelchers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_maneaters_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_maneaters_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_maneaters_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_inf_maneaters_3"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_mon_gorgers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_mon_sabretusk_pack_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_mon_giant_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_mon_stonehorn_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_mon_stonehorn_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_veh_gnoblar_scraplauncher_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_veh_ironblaster_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_cav_crushers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_ogr_cav_crushers_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_marauders_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_marauders_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_marauders_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_daemonette_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_cav_hellstriders_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_cav_hellstriders_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_cav_seekers_of_slaanesh_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_chaos_furies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_inf_daemonette_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_mon_fiends_of_slaanesh_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_veh_seeker_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_mon_keeper_of_secrets_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_cav_heartseekers_of_slaanesh_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_mon_soul_grinder_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_mon_spawn_of_slaanesh_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_veh_exalted_seeker_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_sla_veh_hellflayer_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_inf_forsaken_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_inf_pink_horrors_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_inf_blue_horrors_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_inf_pink_horrors_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_cav_chaos_knights_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_screamers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_flamers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_inf_chaos_furies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_cav_doom_knights_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_exalted_flamers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_lord_of_change_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_soul_grinder_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_mon_spawn_of_tzeentch_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_tze_veh_burning_chariot_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_dae_inf_chaos_furies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_chariot_mkho"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_chariot_mnur"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_chariot_msla"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_chariot_mtze"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mkho"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mkho_dualweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mnur"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mnur_greatweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_msla"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_msla_hellscourges"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mtze"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_marauders_mtze_spears"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_mnur"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_msla"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_msla_hellscourges"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_mtze"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chaos_warriors_mtze_halberds"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_marauder_horsemen_mkho_throwing_axes"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_marauder_horsemen_mnur_throwing_axes"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_marauder_horsemen_msla_javelins"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_marauder_horsemen_mtze_javelins"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_forsaken_mkho"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_forsaken_msla"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_mkho"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_mkho_lances"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_mnur"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_mnur_lances"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_msla"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_msla_lances"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_cav_chaos_knights_mtze_lances"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mkho"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mkho_dualweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mnur"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mnur_greatweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_msla"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_msla_hellscourges"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mtze"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_inf_chosen_mtze_halberds"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_mon_warshrine"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_mon_warshrine_mkho"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_mon_warshrine_mnur"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_mon_warshrine_msla"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_dlc20_chs_mon_warshrine_mtze"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh3_main_nur_mon_spawn_of_nurgle_0_warriors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_empire_knights"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_halberdiers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_handgunners"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_spearmen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_swordsmen"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_crossbowmen"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc04_emp_inf_free_company_militia_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_emp_inf_archers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_demigryph_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_demigryph_knights_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_outriders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_outriders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_pistoliers_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_cav_reiksguard"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_emp_art_great_cannon"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_emp_art_mortar"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_emp_inf_greatswords"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc04_emp_cav_knights_blazing_sun_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc04_emp_inf_flagellants_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_emp_inf_huntsmen_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_emp_art_helblaster_volley_gun"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_emp_art_helstorm_rocket_battery"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_emp_veh_luminark_of_hysh_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_main_emp_veh_steam_tank"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_emp_veh_war_wagon_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_emp_veh_war_wagon_1"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_dwarf_warrior_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_dwarf_warrior_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_longbeards"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_longbeards_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_miners_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_miners_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_quarrellers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_quarrellers_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_thunderers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_art_cannon"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_art_grudge_thrower"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_hammerers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_ironbreakers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_veh_gyrobomber"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_veh_gyrocopter_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_veh_gyrocopter_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_slayers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_dwf_art_bolt_thrower_0"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_dlc06_dwf_inf_bugmans_rangers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc06_dwf_inf_rangers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc06_dwf_inf_rangers_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_dwf_inf_giant_slayers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_art_flame_cannon"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_art_organ_gun"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_irondrakes_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_dwf_inf_irondrakes_2"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_crypt_ghouls"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_skeleton_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_skeleton_warriors_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_zombie"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_fell_bats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_dire_wolves"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_cav_hexwraiths"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_grave_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_grave_guard_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_crypt_horrors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_cav_black_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_cav_black_knights_3"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_vargheists"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc04_vmp_veh_corpse_cart_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc04_vmp_veh_corpse_cart_1"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc04_vmp_veh_corpse_cart_2"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_inf_cairn_wraiths"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_terrorgheist"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_mon_varghulf"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_vmp_veh_black_coach"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc02_vmp_cav_blood_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc04_vmp_veh_mortis_engine_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_vmp_inf_crossbowmen"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_vmp_inf_handgunners"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_brt_cav_knights_of_the_realm"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_brt_cav_mounted_yeomen_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_brt_cav_mounted_yeomen_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_brt_inf_men_at_arms"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_brt_inf_peasant_bowmen"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_brt_inf_spearmen_at_arms"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_cav_knights_errant_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_men_at_arms_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_men_at_arms_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_peasant_bowmen_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_peasant_bowmen_2"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_spearmen_at_arms_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_peasant_mob_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_brt_cav_pegasus_knights"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_cav_questing_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_battle_pilgrims_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_foot_squires_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_inf_grail_reliquae_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_brt_art_field_trebuchet"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_brt_cav_grail_knights"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_cav_grail_guardians_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_cav_royal_hippogryph_knights_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_dlc07_brt_cav_royal_pegasus_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_forest_goblin_spider_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_forest_goblin_spider_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_goblin_wolf_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_goblin_wolf_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_goblin_archers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_goblin_spearmen"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_night_goblin_archers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_night_goblin_fanatics"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_night_goblin_fanatics_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_night_goblins"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_orc_arrer_boyz"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_orc_big_uns"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_orc_boyz"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_savage_orc_arrer_boyz"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_savage_orc_big_uns"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_savage_orcs"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_grn_inf_nasty_skulkers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_goblin_wolf_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_orc_boar_boy_big_uns"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_orc_boar_boyz"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_orc_boar_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_savage_orc_boar_boy_big_uns"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_cav_savage_orc_boar_boyz"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_main_grn_inf_black_orcs"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_mon_trolls"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_grn_cav_squig_hoppers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc06_grn_inf_squig_herd_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_mon_river_trolls_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_mon_stone_trolls_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_grn_art_doom_diver_catapult"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_grn_art_goblin_rock_lobber"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_grn_mon_arachnarok_spider_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_grn_mon_giant"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_mon_rogue_idol_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_veh_snotling_pump_wagon_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_veh_snotling_pump_wagon_flappas_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_grn_veh_snotling_pump_wagon_roller_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc06_grn_inf_squig_explosive_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_mon_chaos_warhounds_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_mon_chaos_warhounds_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_cav_marauder_horsemen_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_chs_cav_marauder_horsemen_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chaos_marauders_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chaos_marauders_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chaos_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chaos_warriors_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_cav_chaos_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_inf_chaos_warriors_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_inf_forsaken_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_chs_cav_marauder_horsemasters_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_chs_mon_trolls"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chosen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_inf_chosen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_cav_chaos_knights_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_chs_cav_chaos_knights_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_cav_gorebeast_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_mon_dragon_ogre"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_mon_trolls_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_inf_chosen_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_chs_feral_manticore"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc06_chs_inf_aspiring_champions_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_art_hellcannon"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh_main_chs_mon_chaos_spawn"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_chs_mon_giant"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc01_chs_mon_dragon_ogre_shaggoth"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_chaos_warhounds_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_chaos_warhounds_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_ungor_raiders_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_gor_herd_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_gor_herd_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_ungor_herd_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_ungor_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_ungor_spearmen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_bst_cav_tuskgor_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_minotaurs_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_minotaurs_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_minotaurs_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_bst_mon_harpies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_razorgor_herd_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_feral_manticore"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_bestigor_herd_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_centigors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_centigors_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_centigors_2"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_cav_razorgor_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_mon_chaos_spawn_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_mon_giant_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc03_bst_inf_cygor_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_bst_mon_ghorgon_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_bst_mon_jabberslythe_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_glade_guard_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_glade_guard_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_glade_guard_2"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_glade_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_glade_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_dryads_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_eternal_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_eternal_guard_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_cav_glade_riders_2"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_inf_malicious_dryads_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_cave_bats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_deepwood_scouts_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_deepwood_scouts_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_mon_treekin_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_mon_great_eagle_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_hawk_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_wardancers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_wardancers_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_wildwood_rangers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_wild_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_wild_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_inf_bladesingers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_giant_spiders_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_feral_manticore"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_harpies_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_hawks_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_malicious_treekin_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_wolves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_forest_dragon_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_mon_treeman_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_inf_waywatchers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc05_wef_cav_sisters_thorn_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_cav_great_stag_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_malicious_treeman_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_wef_mon_zoats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_nor_mon_chaos_warhounds_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_nor_mon_chaos_warhounds_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_nor_cav_marauder_horsemen_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_nor_inf_chaos_marauders_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_nor_inf_chaos_marauders_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_main_nor_cav_marauder_horsemen_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_nor_cav_chaos_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_spearman_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_hunters_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_hunters_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_cav_marauder_horsemasters_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_main_nor_mon_chaos_trolls"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_warwolves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_norscan_ice_trolls_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_feral_manticore"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_berserkers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_champions_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_inf_marauder_champions_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_skinwolves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_skinwolves_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_veh_marauder_warwolves_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_fimir_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_fimir_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_frost_wyrm_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_norscan_giant_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_war_mammoth_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_war_mammoth_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh_dlc08_nor_mon_war_mammoth_2"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_skink_cohort_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_skink_skirmishers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_saurus_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_saurus_spearmen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_saurus_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_saurus_warriors_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_skink_cohort_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_cold_ones_feral_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_inf_skink_red_crested_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_kroxigors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_terradon_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_terradon_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_bastiladon_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_bastiladon_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_bastiladon_2"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_stegadon_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_stegadon_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_chameleon_skinks_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_inf_temple_guards"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_cold_one_spearmen_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_cold_ones_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_cav_horned_ones_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_mon_salamander_pack_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_mon_bastiladon_3"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_cav_ripperdactyl_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_lzd_mon_razordon_pack_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_lzd_mon_sacred_kroxigors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_ancient_stegadon"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_lzd_mon_carnosaur_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_mon_ancient_salamander_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_lzd_mon_ancient_stegadon_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_lzd_mon_dread_saurian_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc13_lzd_mon_dread_saurian_1"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_lzd_inf_chameleon_stalkers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_lzd_mon_coatl_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc17_lzd_mon_troglodon_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_clanrat_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_clanrat_spearmen_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_clanrats_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_clanrats_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_skavenslave_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_skavenslaves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_night_runners_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_night_runners_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_skavenslave_slingers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_mon_rat_ogres"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_death_runners_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_gutter_runner_slingers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_gutter_runner_slingers_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_gutter_runners_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_gutter_runners_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_poison_wind_globadiers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_warpfire_thrower"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_plague_monk_censer_bearer"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_plague_monks"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_stormvermin_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_stormvermin_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_skv_inf_ratling_gun_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_skv_inf_warplock_jezzails_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc12_skv_veh_doom_flayer_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_skv_inf_eshin_triads_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_skv_inf_poison_wind_mortar_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_skv_inf_warp_grinder_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_skv_mon_rat_ogre_mutant"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_skv_mon_wolf_rats_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_skv_mon_wolf_rats_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_art_plagueclaw_catapult"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_art_warp_lightning_cannon"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_veh_doomwheel"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_mon_hell_pit_abomination"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_skv_inf_death_globe_bombardiers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc16_skv_mon_brood_horror_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_archers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_archers_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_lothern_sea_guard_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_lothern_sea_guard_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_gate_guard"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_ellyrian_reavers_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_ellyrian_reavers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_silver_helms_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_silver_helms_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_rangers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_phoenix_guard"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_swordmasters_of_hoeth_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_inf_white_lions_of_chrace_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_dragon_princes"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_ithilmar_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_cav_tiranoc_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_great_eagle"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_inf_shadow_warriors_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_silverin_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_mon_war_lions_of_chrace_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_veh_lion_chariot_of_chrace_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_art_eagle_claw_bolt_thrower"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_moon_dragon"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_phoenix_flamespyre"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_phoenix_frostheart"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_star_dragon"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_hef_mon_sun_dragon"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_inf_sisters_of_avelorn_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_mon_arcane_phoenix_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_inf_dryads_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_mon_treekin_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_inf_shadow_walkers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_mistwalkers_faithbearers_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_mistwalkers_sentinels_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_mistwalkers_skyhawks_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_mistwalkers_spireguard_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_hef_mon_treeman_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc15_hef_inf_mistwalkers_griffon_knights_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_black_ark_corsairs_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_black_ark_corsairs_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_darkshards_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_darkshards_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_dark_riders_2"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_bleakswords_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_dreadspears_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_witch_elves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_dark_riders_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_dark_riders_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_harpies"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_def_mon_feral_manticore_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_shades_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_shades_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_shades_2"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_black_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_cold_one_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_cold_one_knights_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_main_def_inf_har_ganeth_executioners_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_cav_cold_one_chariot"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_def_cav_doomfire_warlocks_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_def_cav_scourgerunner_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_main_def_art_reaper_bolt_thrower"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_main_def_mon_black_dragon"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_main_def_mon_war_hydra"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_def_mon_kharibdyss_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_def_mon_bloodwrack_medusa_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc14_def_veh_bloodwrack_shrine_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_twa03_def_mon_wolves_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_twa03_def_mon_war_mammoth_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_twa03_grn_mon_wyvern_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_monster_feral_bears"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_main_monster_feral_ice_bears"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc10_def_inf_sisters_of_slaughter"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_nehekhara_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_skeleton_archers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_skeleton_spearmen_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_skeleton_warriors_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_veh_skeleton_archer_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_veh_skeleton_chariot_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_skeleton_horsemen_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_skeleton_horsemen_archers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_tomb_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_tomb_guard_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_carrion_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_sepulchral_stalkers_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_ushabti_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_ushabti_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_necropolis_knights_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_necropolis_knights_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_nehekhara_horsemen_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_tomb_scorpion_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_heirotitan_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_necrosphinx_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_art_casket_of_souls_0"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_art_screaming_skull_catapult_0"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_veh_khemrian_warsphinx_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_pro06_tmb_mon_bone_giant_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_dire_wolves"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_mon_fell_bats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_inf_crypt_ghouls"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc09_tmb_cav_hexwraiths"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_sartosa_free_company_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_sartosa_militia_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_deckhands_mob_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_deckhands_mob_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_gunnery_mob_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_gunnery_mob_1"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_gunnery_mob_2"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_zombie_gunnery_mob_3"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_bloated_corpse_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_fell_bats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_scurvy_dogs"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_art_carronade"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_art_mortar"] = { category = "artillery", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_cav_deck_droppers_0"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_cav_deck_droppers_1"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_cav_deck_droppers_2"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_deck_gunners_0"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_depth_guard_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_depth_guard_1"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_inf_syreens"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_animated_hulks_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_rotting_prometheans_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_rotting_prometheans_gunnery_mob_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_mournguls_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_necrofex_colossus_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_rotting_leviathan_0"] = { category = "war_beast", weight = false, cost = 1, tier = false},
        ["wh2_dlc11_cst_mon_terrorgheist"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_chaos_dwarf_blunderbusses"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_chaos_dwarf_warriors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_chaos_dwarf_warriors_great_weapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_goblin_labourers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_hobgoblin_archers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_hobgoblin_cutthroats"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_orc_labourers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_hobgoblin_sneaky_gits"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_infernal_guard"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_infernal_guard_fireglaives"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_infernal_guard_great_weapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_deathshrieker_rocket_launcher"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_iron_daemon"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_magma_cannon"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_skullcracker"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_cav_bull_centaurs_axe"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_cav_bull_centaurs_dual_axe"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_cav_bull_centaurs_greatweapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_inf_infernal_ironsworn"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_mon_kdaai_fireborn"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_bows"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_spears"] = { category = "cavalry", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_mon_great_taurus"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_mon_lammasu"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_mon_bale_taurus"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_mon_kdaai_destroyer"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_dreadquake_mortar"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_skullcracker_1dreadquake"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc23_chd_veh_iron_daemon_1dreadquake"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_bst_inf_tzaangors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_bst_mon_incarnate_elemental_of_beasts"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_inf_onyx_crowmen"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_mon_jade_lion"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_mon_jet_lion"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_veh_zhangu_war_drum"] = { category = "war_machine", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_ksl_inf_akshina_ambushers"] = { category = "inf_ranged", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_ksl_mon_incarnate_elemental_of_beasts"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_ksl_mon_the_things_in_the_woods"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_lzd_mon_carnosaur_0"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_tze_inf_tzaangors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_tze_mon_cockatrice"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_tze_mon_mutalith_vortex_beast"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_tze_mon_flamers_changebringers"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_ksl_mon_frost_wyrm"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_mon_great_moon_bird"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_ksl_inf_kislevite_warriors"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_tze_inf_centigors_great_weapons"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
        ["wh3_dlc24_cth_mon_celestial_lion"] = { category = "inf_melee", weight = false, cost = 1, tier = false},
    },
    active_merc_pool = {}
}


--TODO: support these features:
local subculture_defaults = {
    ["wh_main_sc_emp_empire"] = {"wh_dlc04_emp_inf_free_company_militia_0", "wh_main_emp_cav_empire_knights", "wh_main_emp_inf_halberdiers", "wh_main_emp_inf_handgunners", "wh_main_emp_inf_spearmen_1", "wh_main_emp_inf_swordsmen", "wh2_dlc13_emp_inf_archers_0", "wh_main_emp_inf_crossbowmen"},
    ["wh_main_sc_dwf_dwarfs"] = {"wh_main_dwf_inf_longbeards", "wh_main_dwf_inf_thunderers_0", "wh_main_dwf_inf_dwarf_warrior_0", "wh_main_dwf_inf_dwarf_warrior_1", "wh_main_dwf_inf_quarrellers_0", "wh_main_dwf_inf_miners_1"},
    ["wh_dlc03_sc_bst_beastmen"] = {"wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_ungor_raiders_0",  "wh_dlc03_bst_inf_ungor_spearmen_1", "wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_gor_herd_0"},
    ["wh_dlc05_sc_wef_wood_elves"] = {"wh_dlc05_wef_inf_eternal_guard_1", "wh_dlc05_wef_inf_glade_guard_0", "wh_dlc05_wef_inf_dryads_0"},
    ["wh_main_sc_brt_bretonnia"] = {"wh_main_brt_cav_knights_of_the_realm", "wh_dlc07_brt_inf_men_at_arms_2", "wh_main_brt_inf_peasant_bowmen", "wh_main_brt_cav_knights_of_the_realm"},
    ["wh_main_sc_chs_chaos"] = {"wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_cav_chaos_chariot", "wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_inf_chaos_warriors_0", "wh_dlc01_chs_inf_forsaken_0"},
    ["wh_main_sc_grn_greenskins"] = {"wh_main_grn_inf_orc_big_uns", "wh_dlc06_grn_inf_nasty_skulkers_0", "wh_main_grn_inf_orc_arrer_boyz", "wh_main_grn_inf_orc_boyz"},
    ["wh_main_sc_grn_savage_orcs"] = {"wh_main_grn_inf_savage_orc_big_uns","wh_main_grn_inf_savage_orc_arrer_boyz", "wh_main_grn_inf_savage_orcs"},
    ["wh_main_sc_nor_norsca"] = {"wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_hunters_1", "wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_spearman_0", "wh_main_nor_cav_marauder_horsemen_0"},
    ["wh_main_sc_vmp_vampire_counts"] = {"wh_main_vmp_inf_crypt_ghouls", "wh_main_vmp_inf_skeleton_warriors_0", "wh_main_vmp_inf_skeleton_warriors_1", "wh_main_vmp_inf_zombie", "wh_main_vmp_mon_fell_bats", "wh_main_vmp_mon_dire_wolves"},
    ["wh2_dlc09_sc_tmb_tomb_kings"] = {"wh2_dlc09_tmb_inf_nehekhara_warriors_0", "wh2_dlc09_tmb_inf_skeleton_archers_0", "wh2_dlc09_tmb_veh_skeleton_archer_chariot_0", "wh2_dlc09_tmb_inf_nehekhara_warriors_0"},
    ["wh2_main_sc_def_dark_elves"] = {"wh2_main_def_inf_black_ark_corsairs_0","wh2_main_def_inf_darkshards_0", "wh2_main_def_inf_dreadspears_0"},
    ["wh2_main_sc_hef_high_elves"] = {"wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_archers_1", "wh2_main_hef_cav_silver_helms_0", "wh2_main_hef_inf_lothern_sea_guard_1"},
    ["wh2_main_sc_lzd_lizardmen"] = {"wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_saurus_spearmen_0", "wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_skink_cohort_1"},
    ["wh2_main_sc_skv_skaven"]  = {"wh2_main_skv_inf_clanrats_1", "wh2_main_skv_inf_clanrat_spearmen_1", "wh2_main_skv_inf_night_runners_1", "wh2_main_skv_inf_skavenslave_slingers_0"},
    ["wh2_dlc11_sc_cst_vampire_coast"] = {"wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "wh2_dlc11_cst_inf_zombie_gunnery_mob_1", "wh2_dlc11_cst_mon_bloated_corpse_0", "wh2_dlc11_cst_inf_zombie_deckhands_mob_1"},
    --wh3
    ["wh3_main_sc_cth_cathay"] = {"wh3_main_cth_inf_jade_warrior_crossbowmen_0", "wh3_main_cth_inf_jade_warrior_crossbowmen_1", "wh3_main_cth_inf_jade_warriors_0", "wh3_main_cth_inf_jade_warriors_1", "wh3_main_cth_inf_iron_hail_gunners_0"},
    ["wh3_main_sc_kho_khorne"] = {"wh3_main_kho_inf_bloodletters_0"},
    ["wh3_main_sc_ksl_kislev"] = {"wh3_main_ksl_inf_streltsi_0", "wh3_main_ksl_cav_horse_archers_0",  "wh3_main_ksl_inf_armoured_kossars_1", "wh3_main_ksl_inf_armoured_kossars_0", "wh3_main_ksl_cav_winged_lancers_0"},
    ["wh3_main_sc_nur_nurgle"] = {"wh3_main_nur_inf_plaguebearers_0", "wh3_main_nur_mon_plague_toads_0", "wh3_main_nur_inf_nurglings_0"},
    ["wh3_main_sc_ogr_ogre_kingdoms"] = {"wh3_main_ogr_inf_ogres_0", "wh3_main_ogr_inf_ogres_1", "wh3_main_ogr_inf_ogres_2"},
    ["wh3_main_sc_sla_slaanesh"] = {"wh3_main_sla_inf_daemonette_0", "wh3_main_sla_inf_marauders_2"},
    ["wh3_main_sc_tze_tzeentch"] = {"wh3_main_tze_inf_pink_horrors_0", "wh3_main_tze_inf_blue_horrors_0"},
    ["wh3_main_sc_dae_daemons"] = {"wh3_main_kho_inf_bloodletters_0","wh3_main_nur_inf_nurglings_0", "wh3_main_sla_inf_daemonette_0", "wh3_main_tze_inf_pink_horrors_0", "wh3_main_tze_inf_blue_horrors_0"},
    --wh3 DLC
    ["wh3_dlc23_sc_chd_chaos_dwarfs"] = {"wh3_dlc23_chd_inf_chaos_dwarf_warriors", "wh3_dlc23_chd_inf_chaos_dwarf_warriors_great_weapons", "wh3_dlc23_chd_inf_chaos_dwarf_blunderbusses", "wh3_dlc23_chd_inf_hobgoblin_cutthroats"}
} --:map<string, vector<string>>


local function fix_daemons() 
    local daemons_of_chaos = {
        "wh3_dlc20_chs_cav_marauder_horsemen_msla_javelins",
        "wh3_dlc20_chs_inf_chaos_marauders_mkho_dualweapons",
        "wh3_dlc20_chs_inf_chaos_marauders_mnur",
        "wh3_dlc20_chs_inf_chaos_marauders_mtze_spears",
        "wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons",
        "wh3_dlc20_chs_inf_chaos_warriors_msla_hellscourges",
        "wh3_dlc20_chs_inf_chaos_warriors_mtze_halberds",
        "wh3_dlc20_chs_inf_forsaken_mkho",
        "wh3_dlc20_chs_inf_forsaken_msla",
        "wh3_dlc20_chs_mon_warshrine_mkho",
        "wh3_dlc20_chs_mon_warshrine_mnur",
        "wh3_dlc20_chs_mon_warshrine_msla",
        "wh3_dlc20_chs_mon_warshrine_mtze",
        "wh3_dlc20_chs_mon_warshrine",
        "wh3_dlc24_tze_inf_centigors_great_weapons",
        "wh3_dlc24_tze_inf_tzaangors",
        "wh3_dlc24_tze_mon_cockatrice",
        "wh3_dlc24_tze_mon_flamers_changebringers",
        "wh3_dlc24_tze_mon_mutalith_vortex_beast",
        "wh3_main_dae_inf_chaos_furies_0",
        "wh3_main_kho_cav_bloodcrushers_0",
        "wh3_main_kho_cav_gorebeast_chariot",
        "wh3_main_kho_cav_skullcrushers_0",
        "wh3_main_kho_inf_bloodletters_0",
        "wh3_main_kho_inf_bloodletters_1",
        "wh3_main_kho_inf_chaos_furies_0",
        "wh3_main_kho_inf_chaos_warhounds_0",
        "wh3_main_kho_inf_chaos_warriors_0",
        "wh3_main_kho_inf_chaos_warriors_1",
        "wh3_main_kho_inf_chaos_warriors_2",
        "wh3_main_kho_inf_flesh_hounds_of_khorne_0",
        "wh3_main_kho_mon_bloodthirster_0",
        "wh3_main_kho_mon_khornataurs_0",
        "wh3_main_kho_mon_khornataurs_1",
        "wh3_main_kho_mon_soul_grinder_0",
        "wh3_main_kho_mon_spawn_of_khorne_0",
        "wh3_main_kho_veh_blood_shrine_0",
        "wh3_main_kho_veh_skullcannon_0",
        "wh3_main_nur_cav_plague_drones_0",
        "wh3_main_nur_cav_plague_drones_1",
        "wh3_main_nur_cav_pox_riders_of_nurgle_0",
        "wh3_main_nur_inf_chaos_furies_0",
        "wh3_main_nur_inf_forsaken_0",
        "wh3_main_nur_inf_nurglings_0",
        "wh3_main_nur_inf_plaguebearers_0",
        "wh3_main_nur_inf_plaguebearers_1",
        "wh3_main_nur_mon_beast_of_nurgle_0",
        "wh3_main_nur_mon_great_unclean_one_0",
        "wh3_main_nur_mon_plague_toads_0",
        "wh3_main_nur_mon_rot_flies_0",
        "wh3_main_nur_mon_soul_grinder_0",
        "wh3_main_nur_mon_spawn_of_nurgle_0",
        "wh3_main_sla_cav_heartseekers_of_slaanesh_0",
        "wh3_main_sla_cav_hellstriders_0",
        "wh3_main_sla_cav_hellstriders_1",
        "wh3_main_sla_cav_seekers_of_slaanesh_0",
        "wh3_main_sla_inf_chaos_furies_0",
        "wh3_main_sla_inf_daemonette_0",
        "wh3_main_sla_inf_daemonette_1",
        "wh3_main_sla_inf_marauders_0",
        "wh3_main_sla_inf_marauders_1",
        "wh3_main_sla_inf_marauders_2",
        "wh3_main_sla_mon_fiends_of_slaanesh_0",
        "wh3_main_sla_mon_keeper_of_secrets_0",
        "wh3_main_sla_mon_soul_grinder_0",
        "wh3_main_sla_mon_spawn_of_slaanesh_0",
        "wh3_main_sla_veh_exalted_seeker_chariot_0",
        "wh3_main_sla_veh_hellflayer_0",
        "wh3_main_sla_veh_seeker_chariot_0",
        "wh3_main_tze_cav_chaos_knights_0",
        "wh3_main_tze_cav_doom_knights_0",
        "wh3_main_tze_inf_blue_horrors_0",
        "wh3_main_tze_inf_chaos_furies_0",
        "wh3_main_tze_inf_forsaken_0",
        "wh3_main_tze_inf_pink_horrors_0",
        "wh3_main_tze_inf_pink_horrors_1",
        "wh3_main_tze_mon_exalted_flamers_0",
        "wh3_main_tze_mon_flamers_0",
        "wh3_main_tze_mon_lord_of_change_0",
        "wh3_main_tze_mon_screamers_0",
        "wh3_main_tze_mon_soul_grinder_0",
        "wh3_main_tze_mon_spawn_of_tzeentch_0",
        "wh3_main_tze_veh_burning_chariot_0"
    }
    for _, unit in pairs(daemons_of_chaos) do
        local unit_info = pttg_merc_pool.merc_units[unit]
        if unit_info then
            table.insert(pttg_merc_pool.merc_pool["wh3_main_dae_daemons"][unit_info.tier], unit_info)
        end
    end
end
---special rules are set up in the database using effects, however, flagging them here is necessary because it is too expensive for the script to check all 1600 possible units for a special rule.
---Valid flags are "subtype", "faction" and "subculture"
---multiple flags are OR, not AND. For example: {subculture = wh3_main_sc_ksl_kislev, subtype = wh3_main_ksl_katarin} would apply to anyone who is from the kislev subculture because it means "Is from kislev OR is katarin"
---Special rules *do* affect the AI.
local units_with_special_rules = {
    {"wh2_main_skv_inf_plague_monks", {subtype = "wh2_main_skv_lord_skrolk"}},
    {"wh3_dlc23_chd_inf_infernal_guard", {subtype = "wh3_dlc23_chd_drazhoath"}},
    {"wh3_dlc23_chd_inf_infernal_guard_fireglaives", {subtype = "wh3_dlc23_chd_drazhoath"}},
    {"wh3_dlc23_chd_inf_infernal_guard_great_weapons", {subtype = "wh3_dlc23_chd_drazhoath"}}
}


function pttg_merc_pool:reset_merc_pool()
    local faction = cm:get_local_faction()
    for culture, tiers in pairs(self.merc_pool) do
        for tier, units in ipairs(tiers) do
            for i, unit_info in ipairs(units) do
                unit = unit_info.key
                self:add_unit_to_pool(unit, 0)
            end
        end
    end
end

function pttg_merc_pool:init_merc_pool() 
    local cultures = {
        "wh2_dlc09_tmb_tomb_kings",
        "wh2_dlc11_cst_vampire_coast",
        "wh2_main_def_dark_elves",
        "wh2_main_hef_high_elves",
        "wh2_main_lzd_lizardmen",
        "wh2_main_skv_skaven",
        "wh3_dlc23_chd_chaos_dwarfs",
        "wh3_main_cth_cathay",
        "wh3_main_dae_daemons",
        "wh3_main_kho_khorne",
        "wh3_main_ksl_kislev",
        "wh3_main_nur_nurgle",
        "wh3_main_ogr_ogre_kingdoms",
        "wh3_main_sla_slaanesh",
        "wh3_main_tze_tzeentch",
        "wh_dlc03_bst_beastmen",
        "wh_dlc05_wef_wood_elves",
        "wh_dlc08_nor_norsca",
        "wh_main_brt_bretonnia",
        "wh_main_chs_chaos",
        "wh_main_dwf_dwarfs",
        "wh_main_emp_empire",
        "wh_main_grn_greenskins",
        "wh_main_vmp_vampire_counts"
    }

    local culture_keys = {
        "_tmb_",
        "_cst_",
        "_def_",
        "_hef_",
        "_lzd_",
        "_skv_",
        "_chd_",
        "_cth_",
        "_dae_",
        "_kho_",
        "_ksl_",
        "_nur_",
        "_ogr_",
        "_sla_",
        "_tze_",
        "_bst_",
        "_wef_",
        "_nor_",
        "_brt_",
        "_chs_",
        "_dwf_",
        "_emp_",
        "_grn_",
        "_vmp_"
    }
    pttg:log(string.format("[pttg_MercPool] Initialising units merc pool."))

    local recruit_weights = pttg:get_state('recruit_weights')
    for k, culture_key in pairs(culture_keys) do
        self.merc_pool[cultures[k]] = { {}, {}, {} }
        for unit_key, info in pairs(ttc.units) do
            if string.find(unit_key, culture_key) and self.merc_units[unit_key] then
                pttg:log(string.format("[pttg_MercPool] Initialising unit %s to the merc pool.", unit_key))
                local tier = 1
                if info.group == "core" then
                    tier = 1
                elseif info.group == "special" then
                    tier = 2
                elseif info.group == "rare" then
                    tier = 3
                end
                
                unit_info = self.merc_units[unit_key]
                
                unit_info.tier = tier
                unit_info.cost = self.merc_units[unit_key].cost or tier
                
                unit_info.weight = self.merc_units[unit_key].weight or math.ceil(recruit_weights[info.group] / info.weight)
                
                pttg:log(string.format("[pttg_MercPool] Adding unit %s with weight %s at cost %s.", unit_key, unit_info.weight, unit_info.cost))
                table.insert(self.merc_pool[cultures[k]][tier], {key=unit_key, weight=unit_info.weight, cost=unit_info.cost, category=unit_info.category})
            end
        end   
    end
    fix_daemons()
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
        false, "pttg_"..unit
    )
end

ttc.add_post_setup_callback(
    function()
        pttg_merc_pool:reset_merc_pool()
        pttg_merc_pool:init_merc_pool()
    end
);

core:add_listener(
    "init_TreasureRoom",
    "pttg_init_complete",
    true,
    function(context)
        pttg_merc_pool:init_active_merc_pool()
    end,
    false
)

function pttg_merc_pool:add_unit(unit_info)
    local weight = 0
    if unit_info[2] == "core" then
        weight = 20
    elseif unit_info[2] == "special" then
        weight = 10
    elseif unit_info[2] == "rare" then
        weight = 5
    end
    self.merc_units[unit_info[1]] = { weight = weight}
end

function pttg_merc_pool:add_unit_list(units)
    for _, unit in pairs(units) do
        self.merc_units[unit[1]] = { weight = unit.weight}
    end
end

function pttg_merc_pool:add_active_unit(unit, count)
    if self.active_merc_pool[unit] then
        self.active_merc_pool[unit] = self.active_merc_pool[unit] + count
    else
        self.active_merc_pool[unit] = count
    end
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

local pttg_merc_pool_manager = {
    pool_list = {}
}

function pttg_merc_pool_manager:new_pool(key)
	pttg:log("[pttg_merc_pool]Random Merc Pool Manager: Creating New Merc Pool with key [" .. key .. "]");

	local existing_pool = self:get_pool_by_key(key)

	if existing_pool then
		existing_pool.key = key;
		existing_pool.units = {};
		existing_pool.mandatory_units = {};
		existing_pool.faction = "";
		pttg:log("\tPool with key [" .. key .. "] already exists - resetting pool!");
		return true;
	end
	
    local pool = {};
	pool.key = key;
	pool.units = {};
	pool.mandatory_units = {};
	pool.faction = "";
	table.insert(self.pool_list, pool);
	pttg:log("\tPool with key [" .. key .. "] created!");
	return true;
end

function pttg_merc_pool_manager:get_pool_by_key(pool_key)
	for i = 1, #self.pool_list do
		if pool_key == self.pool_list[i].key then
			return self.pool_list[i];
		end;
	end;
	
	return false;
end;

function pttg_merc_pool_manager:add_unit(pool_key, key, weight)
	local pool_data = self:get_pool_by_key(pool_key);
	
	if pool_data then
		for i = 1, weight do
			table.insert(pool_data.units, key);
		end;
		return;
	end;
	
	self:new_pool(pool_key);
	self:add_unit(pool_key, key, weight);
end;

function pttg_merc_pool_manager:generate_pool(pool_key, unit_count, return_as_table)
	local pool = {};
	local pool_data = self:get_pool_by_key(pool_key);

    if not pool_data then
        pttg:log(string.format("Random Merc Pool Manager: no pool data found for %s; Aborting.", pool_key));
        return {}
    end

	if not unit_count then
		unit_count = #pool_data.mandatory_units
-- 	elseif is_table(unit_count) then
-- 		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
	end
	
	unit_count = math.min(19, unit_count);
	
	pttg:log("Random Merc Pool Manager: Getting Random Pool for pool [" .. pool_key .. "] with size [" .. unit_count .. "]");
	
	local mandatory_units_added = 0;
	
	for i = 1, #pool_data.mandatory_units do
		table.insert(pool, pool_data.mandatory_units[i]);
		mandatory_units_added = mandatory_units_added + 1;
	end;
	
	if (unit_count - mandatory_units_added) > 0 and #pool_data.units == 0 then
		script_error("Random Merc Pool Manager: Tried to add units to pool_key [" .. pool_key .. "] but the pool has not been set up with any non-mandatory units - add them first!");
		return false;
	end;
	
	
	for i = 1, unit_count - mandatory_units_added do
		local unit_index = cm:random_number(#pool_data.units);
		table.insert(pool, pool_data.units[unit_index]);
	end;
	
	if #pool == 0 then
		script_error("Random Merc Pool Manager: Did not add any units to pool with pool_key [" .. pool_key .. "] - was the pool created?");
		return false;
	elseif return_as_table then
		return pool;
	else
		return table.concat(pool, ",");
	end;
end;

core:add_listener(
    "pttg_RewardChosenRecruit",
    "pttg_recruit_reward",
    true,
    function(context)  
        local faction = cm:get_local_faction()
        pttg:log(string.format("[pttg_RewardChosenRecruit] Recruiting units for %s", faction:culture()))
        
        local function concatArray(a, b)
            if not b then
                return a
            end
            
            for _, item in pairs(b) do
                table.insert(a, item)
            end
            return a
        end

        local available_merc_pool = pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][1]
        
        available_merc_pool = concatArray(available_merc_pool, pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][2])
        available_merc_pool = concatArray(available_merc_pool, pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][3])
        
        local recruit_pool_key = "pttg_recruit_reward"
        pttg_merc_pool_manager:new_pool(recruit_pool_key)
        
        for _, merc in pairs(available_merc_pool) do
            pttg_merc_pool_manager:add_unit(recruit_pool_key, merc.key, merc.weight)
        end
        
        pttg_merc_pool:add_active_units(pttg_merc_pool_manager:generate_pool(recruit_pool_key, 3, true))
    end,
    true
)

core:add_listener(
    "pttg_ResetMercPool",
    "pttg_phase1",
    true,
    function(context) 
        pttg_merc_pool:reset_active_merc_pool()
        local faction = cm:get_local_faction()
        local glory_recruit_points = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()
        cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory", "pttg_glory_unit_recruitment", -glory_recruit_points)
    end,
    true
)

core:add_static_object("pttg_merc_pool", pttg_merc_pool);
