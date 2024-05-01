local dlc24_extra_patch = {
    {"wh3_dlc24_tze_mon_flamers_changebringers", "special", 2},
    {"wh3_dlc24_ksl_mon_frost_wyrm", "rare", 2},
    {"wh3_dlc24_cth_mon_great_moon_bird", "special", 3},
    {"wh3_dlc24_ksl_inf_kislevite_warriors", "core", 1},
    {"wh3_dlc24_tze_inf_centigors_great_weapons", "special", 1},
    {"wh3_dlc24_cth_mon_celestial_lion", "rare", 2}
}

local dlc25_thrones_of_decay = {
    {"wh3_dlc25_bst_inf_pestigors", "core", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "melee_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_dwf_art_goblin_hewer", "rare", 2, { military_groupings = {"wh_main_group_dwarfs"}, category = "warmachine", tier = nil, cost = 2 }},
    {"wh3_dlc25_dwf_inf_doomseekers", "special", 3, { military_groupings = {"wh_main_group_dwarfs"}, category = "melee_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_dwf_inf_slayer_pirates", "special", 2, { military_groupings = {"wh_main_group_dwarfs"}, category = "missile_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_dwf_inf_thunderers_grudge_rakers", "special", 3, { military_groupings = {"wh_main_group_dwarfs"}, category = "missile_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_dwf_veh_thunderbarge", "rare", 3, { military_groupings = {"wh_main_group_dwarfs"}, category = "warmachine", tier = nil, cost = 2 }},
    {"wh3_dlc25_emp_cav_knights_of_the_black_rose", "special", 2, { military_groupings = {"wh3_dlc25_group_elspeth","wh_main_group_empire","wh_main_group_empire_golden_order","wh_main_group_empire_reikland","wh_main_group_teb"}, category = "melee_cavalry", tier = nil, cost = 2 }},
    {"wh3_dlc25_emp_inf_hochland_long_rifles", "special", 2, { military_groupings = {"wh3_dlc25_group_elspeth","wh_main_group_empire","wh_main_group_empire_golden_order","wh_main_group_empire_reikland","wh_main_group_teb"}, category = "missile_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_emp_inf_nuln_ironsides", "special", 3, { military_groupings = {"wh3_dlc25_group_elspeth","wh_main_group_empire","wh_main_group_empire_golden_order","wh_main_group_empire_reikland","wh_main_group_teb"}, category = "missile_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_emp_veh_marienburg_land_ship", "rare", 3, { military_groupings = {"wh3_dlc25_group_elspeth","wh_main_group_empire","wh_main_group_empire_golden_order","wh_main_group_empire_reikland"}, category = "chariot", tier = nil, cost = 2 }},
    {"wh3_dlc25_emp_veh_steam_tank_volley_gun", "rare", 3, { military_groupings = {"wh3_dlc25_group_elspeth","wh_main_group_empire","wh_main_group_empire_golden_order","wh_main_group_empire_reikland"}, category = "chariot", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_cav_rot_knights", "special", 3, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "melee_cavalry", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_inf_pestigors", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "melee_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_inf_plague_ogres_great_weapons", "special", 3, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "monstrous_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_inf_plague_ogres", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "monstrous_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_mon_bile_trolls", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "monstrous_infantry", tier = nil, cost = 2 }},
    {"wh3_dlc25_nur_mon_toad_dragon", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_dlc25_nur_tamurkhan","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "monster", tier = nil, cost = 2 }},
}

local ttc = core:get_static_object("tabletopcaps")

if ttc then
    ttc.add_setup_callback(function()
        ttc.add_unit_list(dlc24_extra_patch)
        ttc.add_unit_list(dlc25_thrones_of_decay)
    end)
end