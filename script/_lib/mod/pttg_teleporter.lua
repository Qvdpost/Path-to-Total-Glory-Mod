local pttg = core:get_static_object("pttg");

local pttg_tele = {
    distance_upper_bound = 6
}

function pttg_tele:get_random_region(excluded_owners)
    if excluded_owners == nil then
        excluded_owners = {}
    end
    if not is_table(excluded_owners) then
        script_error("excluded owner parameter should be a table not: "..type(excluded_owners))
        return
    end
    excluded_owners = excluded_owners or {}
    local owner = nil
    local region
    -- Find a random region with an owner for recruitment.
    local root = cco("CcoCampaignRoot", "CcoCampaignRoot")
    local settlement_count = root:Call("SettlementList.Size")
    while not owner or excluded_owners[owner:name()] do
        local rand = cm:random_number(settlement_count-1, 0)
        local random_settlement = root:Call("SettlementList.At("..rand..")")

        local random_region_name = random_settlement:Call("ModelRegionContext.RecordKey")
        region = cm:get_region_data(random_region_name):region()

        while not region do -- sometimes there's no data...
            pttg:log(string.format("[pttg_teleporter] Trying again: No region data found for region: %s",
                random_region_name))
            region = cm:get_region_data(random_region_name):region()
        end

        if region.is_abandoned and not region:is_abandoned() then
            owner = region:owning_faction()
        elseif region.adjacent_region_list then -- Region is abandoned, but perhaps has a neighbour to take ownership
            pttg:log(string.format("[pttg_teleporter] No owning faction data for region: %s", random_region_name))
            for i = 0, region:adjacent_region_list():num_items() - 1 do
                local neighbour = region:adjacent_region_list():item_at(i)
                if not neighbour:is_abandoned() then -- Viable neighbour found.
                    -- Give the region to neighbour to enable mercenary recruitment
                    cm:transfer_region_to_faction(random_region_name, neighbour:owning_faction():name())
                    owner = neighbour:owning_faction()
                    break
                end
            end
        else -- Region has data, but no functionality...
            pttg:log(string.format("[pttg_teleporter] Dud region %s", random_region_name))
        end
    end
    pttg:log(string.format("[pttg_teleporter] Random region %s with owner %s", region:name(),
        region:owning_faction():name()))
    return region
end

function pttg_tele:teleport_to_random_region(distance_upper_bound)
    local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
    at_war_with = {}
    warring_factions = cm:get_local_faction():factions_at_war_with()
    for i = 0, warring_factions:num_items() - 1 do
        at_war_with[warring_factions:item_at(i):name()] = true
    end

    local x = -1
    local y = -1
    local random_region
    local distance

    while x == -1 do
        random_region = self:get_random_region(at_war_with)

        -- Cover some random distance to reach cool places for battle maps.
        distance = cm:random_number(distance_upper_bound or self.distance_upper_bound, 1)

        ---@diagnostic disable-next-line: cast-local-type
        x, y = cm:find_valid_spawn_location_for_character_from_settlement(cm:get_local_faction_name(),
            random_region:name(), false, true, distance)
    end
    pttg:log(string.format("[pttg_teleport][random_region] Teleporting to %s at %i, %i with a distance of %i.",
        random_region:name(), x, y, distance))

    local tele = cm:teleport_to(cm:char_lookup_str(character), x, y)

    pttg:log(string.format("[pttg_teleport][random_region] Teleported: %s.", tostring(tele)))
end

function pttg_tele:teleport_random_distance(distance_upper_bound)
    local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
    local x = -1
    local y = -1
    local distance
    while x == -1 do
        distance = cm:random_number(distance_upper_bound or (self.distance_upper_bound * 10), 1)
        ---@diagnostic disable-next-line: cast-local-type
        x, y = cm:find_valid_spawn_location_for_character_from_character(cm:get_local_faction_name(),
            cm:char_lookup_str(character:command_queue_index()), false, distance)
    end

    pttg:log(string.format("[pttg_teleport][random_distance] Teleporting to %i, %i for a distance of %i.", x, y, distance))

    local tele = cm:teleport_to(cm:char_lookup_str(character), x, y)

    pttg:log(string.format("[pttg_teleport][random_distance] Teleported: %s.", tostring(tele)))
end

core:add_static_object("pttg_tele", pttg_tele);
