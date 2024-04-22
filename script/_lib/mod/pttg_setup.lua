local pttg = core:get_static_object("pttg");
local mct = get_mct();
local pttg_upkeep = core:get_static_object("pttg_upkeep")


local function init() 
end

cm:add_first_tick_callback(function() init() end);
