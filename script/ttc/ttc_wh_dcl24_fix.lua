local dlc24_extra_patch = {
    {"wh3_dlc24_tze_mon_flamers_changebringers", "special", 2},
    {"wh3_dlc24_ksl_mon_frost_wyrm", "rare", 2},
    {"wh3_dlc24_cth_mon_great_moon_bird", "special", 3},
    {"wh3_dlc24_ksl_inf_kislevite_warriors", "core", 1},
    {"wh3_dlc24_tze_inf_centigors_great_weapons", "special", 1},
    {"wh3_dlc24_cth_mon_celestial_lion", "rare", 2}
}

local ttc = core:get_static_object("tabletopcaps")

if ttc then
    ttc.add_setup_callback(function()
        ttc.add_unit_list(dlc24_extra_patch)
    end)
end