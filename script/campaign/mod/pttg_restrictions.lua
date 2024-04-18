local pttg = core:get_static_object("pttg");
local mct = get_mct();


local function restrict_player()
    core:add_listener(
        "award_random_magical_item",
        "TriggerPostBattleAncillaries",
        true,
        function(context)
            return false;
        end,
        true
    );
end

cm:add_first_tick_callback(function() restrict_player() end);
