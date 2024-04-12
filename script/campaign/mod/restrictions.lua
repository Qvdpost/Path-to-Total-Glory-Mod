local pttg = core:get_static_object("pttg");

local function restrict_player ()
    
end

cm:add_first_tick_callback(function() restrict_player() end);
