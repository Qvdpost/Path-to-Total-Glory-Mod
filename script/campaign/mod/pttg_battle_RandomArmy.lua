local pttg_merc_pool = core:get_static_object("pttg_merc_pool");
local pttg = core:get_static_object("pttg");
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");


local function get_random_category(distribution)
	local rando = cm:random_number(100)
	local sum_chance = 0
	local rand_cat = nil
	for category, chance in pairs(distribution) do
		sum_chance = sum_chance + chance
		if rando <= sum_chance then
			rand_cat = category
			break
		end
	end
	return rand_cat
end
-- a one-stop-shop for generating random but relatively sensible armies. Use pre-existing tempaltes or add your own so that everyone can use it!

WH_Random_Army_Generator = {
	force_list = {}
}

--generates a random army based for the relevant faction template_key.
--currently has armies stored for each template_key, but technically we can use any key here. So feel free to add custom armies with unique rosters using the existing format.
--Use the 'power' modifier to increase the likeliness of high-tier units appearing. this is clamped between 1 and 10.
--if 'use thresholds' is true, high tier units will *never* appear at low power levels, and vice versa. These thresholds are defined within the function
function WH_Random_Army_Generator:generate_random_army(key, template_key, num_units, power, use_thresholds,
													   generate_as_table)
	if not pttg_battle_templates.templates[template_key] then
		script_error("[generate_random_army] ERROR: generate_random_army() called but supplied template_key [" ..
			template_key .. "] is not supported");
		return false;
	end
	--clamp the range
	if power < 1 then
		power = 1
	elseif power > 10 then
		power = 10
	end

	--the formulae we use for each tier
	local low_tier_modifier  = 10
	local mid_tier_modifier  = power
	local high_tier_modifier = power * 2


	-- thresholds at which certain tiers of units will start/stop appearing if use_thresholds is enabled
	-- these can be adjusted, but there should always be some overlap

	local mid_tier_lower_threshold = 2
	local mid_tier_upper_threshold = 10

	local high_tier_lower_threshold = 6

	local low_tier_upper_threshold = 7


	--formulae for the weighting
	if use_thresholds then
		if power <= mid_tier_lower_threshold then
			mid_tier_modifier = 0
		end

		if power <= high_tier_lower_threshold then
			high_tier_modifier = 0
		end

		if power >= low_tier_upper_threshold then
			low_tier_modifier = 0
		end

		if power >= mid_tier_upper_threshold then
			mid_tier_modifier = 0
		end
	end

	local modifiers = { low_tier_modifier, mid_tier_modifier, high_tier_modifier }


	self:new_force(key);

	local template = pttg_battle_templates.templates[template_key]

	pttg:log(string.format("[generate_random_army] Generating army with template %s for %s", template_key,
		template.culture))
	pttg:log(string.format("[generate_random_army] %s, %s, %s, %s", template.faction, template.culture,
		template.subculture, template.alignment))
	pttg:log(string.format("[generate_random_army] %s, %s", #template.mandatory_units, #template.units))

	if #template.mandatory_units > 0 then
		for _, unit in pairs(template.mandatory_units) do
			unit_info = pttg_merc_pool.merc_units[unit.key]

			self:add_mandatory_unit(key, unit_info, 1)
		end
	end

	if #template.units > 0 then
		for _, unit in pairs(template.units) do
			unit_info = pttg_merc_pool.merc_units[unit.key]
			local weighting_modifier = modifiers[unit_info.tier]
			self:add_unit(key, unit_info, unit.weight * weighting_modifier)
		end
	else
		for tier, units in pairs(pttg_merc_pool:get_pool(template.faction)) do
			local weighting_modifier = modifiers[tier]
			for i, unit_info in ipairs(units) do
				self:add_unit(key, unit_info, unit_info.weight * weighting_modifier);
			end
		end
	end

	return self:generate_force(key, num_units, generate_as_table);
end

function WH_Random_Army_Generator:generate_force(force_key, unit_count, return_as_table)
	local force = {};
	local force_data = self:get_force_by_key(force_key);

	if not force_data then
		script_error("[generate_random_army] No force data found for key: " .. force_key)
		return nil
	end

	if not unit_count then
		unit_count = #force_data.mandatory_units
	elseif is_table(unit_count) then
		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
	end

	unit_count = math.min(19, unit_count);

	pttg:log("[generate_random_army] Random Army Manager: Getting Random Force for army [" ..
		force_key .. "] with size [" .. unit_count .. "]");

	local mandatory_units_added = 0;

	for i = 1, #force_data.mandatory_units do
		table.insert(force, force_data.mandatory_units[i]);
		mandatory_units_added = mandatory_units_added + 1;
	end;

	if (unit_count - mandatory_units_added) > 0 and #force_data.units == 0 then
		script_error("[generate_random_army] Random Army Manager: Tried to add units to force_key [" ..
			force_key .. "] but the force has not been set up with any non-mandatory units - add them first!");
		return false;
	end;



	local troop_distribution = pttg_battle_templates:get_distribution('default')

	local categorized_units = {}
	for category, _ in pairs(troop_distribution) do
		categorized_units[category] = {}
	end

	for _, unit_info in pairs(force_data.units) do
		table.insert(categorized_units[unit_info.category], unit_info.key)
	end

	for i = 1, unit_count - mandatory_units_added do
		local category = get_random_category(troop_distribution)
		
		while #categorized_units[category] == 0 do
			category = get_random_category(troop_distribution)
		end

		pttg:log("Adding from random category: "..category)

		local unit_index = cm:random_number(#categorized_units[category]);

		table.insert(force, categorized_units[category][unit_index]);
	end;

	if #force == 0 then
		script_error("[generate_random_army] Random Army Manager: Did not add any units to force with force_key [" ..
			force_key .. "] - was the force created?");
		return false;
	elseif return_as_table then
		return force;
	else
		return table.concat(force, ",");
	end;
end;

function WH_Random_Army_Generator:add_unit(force_key, unit, weight)
	local force_data = self:get_force_by_key(force_key);

	if force_data then
		pttg:log("[generate_random_army] Random Army Manager: Adding Unit- [" ..
				unit.key .. "] with weight: [" .. weight .. "] in cat: [".. unit.category .. "] to force: [" .. force_key .. "]");
		for i = 1, weight do
			table.insert(force_data.units, unit);
		end;
		return;
	end;

	-- the force key doesn't exist, create it now
	self:new_force(force_key);
	self:add_unit(force_key, unit, weight);
end;

--- @function remove_force
--- @desc Remove an existing force from the force list
--- @p string key of the force
function WH_Random_Army_Generator:remove_force(force_key)
	pttg:log("[generate_random_army] Random Army Manager: Removing Force with key [" .. force_key .. "]");

	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			table.remove(self.force_list, i);
			break;
		end;
	end;
end;

--- @function mandatory_unit_count
--- @desc Returns the amount of mandatory units specified in this force
--- @p string key of the force
function WH_Random_Army_Generator:mandatory_unit_count(force_key)
	local force_data = self:get_force_by_key(force_key);
	if force_data then
		return #force_data.mandatory_units;
	else
		return -1
	end
end;

--- @function get_force_by_key
--- @desc Returns the force of the specified key, false if it's not found
--- @p string key of the force
--- @r table Returns the force
function WH_Random_Army_Generator:get_force_by_key(force_key)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			return self.force_list[i];
		end;
	end;

	return false;
end;

function WH_Random_Army_Generator:add_mandatory_unit(force_key, unit_info, amount)
	local force_data = self:get_force_by_key(force_key);

	if force_data then
		for i = 1, amount do
			table.insert(force_data.mandatory_units, unit_info.key);
			pttg:log("[generate_random_army] Random Army Manager: Adding Mandatory Unit- [" ..
				unit_info.key .. "] with amount: [" .. amount .. "] to force: [" .. force_key .. "]");
		end;
		return;
	end;

	-- the force key doesn't exist, create it now
	self:new_force(force_key);
	self:add_mandatory_unit(force_key, unit_info.key, amount);
end;

--- @function set_faction
--- @desc Sets the faction key associated with this force - Allows you to store the faction key used to spawn the army from the force
--- @p string key of the force
--- @p string key of the faction
function WH_Random_Army_Generator:set_faction(force_key, faction_key)
	local force_data = self:get_force_by_key(force_key)

	-- If the force doesn't exist, add it now.
	if not force_data then
		self:new_force(force_key);
	end;

	force_data.faction = faction_key;
end

function WH_Random_Army_Generator:new_force(key)
	pttg:log("[generate_random_army] Random Army Manager: Creating New Force with key [" .. key .. "]");

	if self:get_force_by_key(key) then
		pttg:log("\tForce with key [" .. key .. "] already exists!");
		return false;
	end;

	local existing_force = self:get_force_by_key(key)

	if existing_force ~= false then
		existing_force.key = key;
		existing_force.units = {};
		existing_force.mandatory_units = {};
		existing_force.faction = "";
		pttg:log("\tForce with key [" .. key .. "] already exists - resetting force!");
		return true;
	end

	local force = {};
	force.key = key;
	force.units = {};
	force.mandatory_units = {};
	force.faction = "";
	table.insert(self.force_list, force);
	pttg:log("\tForce with key [" .. key .. "] created!");
	return true;
end;
