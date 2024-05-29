local pttg_battle = core:get_static_object("pttg_battle")

bm = battle_manager:new();

bm:register_phase_change_callback(
    "Deployed",
    function()
        pttg_battle:battle_started();
    end
);

bm:register_phase_change_callback(
    "Complete",
    function()
        pttg_battle:battle_ended()
    end
);