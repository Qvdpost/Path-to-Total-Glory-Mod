local patch = {
    {"wh2_dlc17_kho_mon_ghorgon_ror_0", "rare", 3},
    {"wh_dlc06_dwf_inf_old_grumblers_0", "special", 3},
}


local ttc = core:get_static_object("tabletopcaps")

if ttc then
    ttc.add_setup_callback(function()
        ttc.add_unit_list(patch)
    end)
end