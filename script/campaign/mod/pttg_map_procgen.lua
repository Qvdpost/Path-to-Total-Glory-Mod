local procgen = {}

local pttg = core:get_static_object("pttg");


MapRoomNode = {}

function MapRoomNode:new(x, y, z)
    local self = {}
    self.x = x
    self.y = y
    self.z = z
    self.edges = {}
    self.parents = {}
    self.class = nil
    setmetatable(self, { __index = MapRoomNode })
    return self
end

function MapRoomNode.__eq(self, other)
    return self.x == other.x and self.y == other.y
end

function MapRoomNode.repr(self)
    return string.format("Node(%s): %i, %i with %i Edges", pttg_get_room_symbol(self.class), self.y, self.x, #self.edges)
end

function MapRoomNode.is_connected(self)
    return #self.edges > 0
end

MapEdge = {}

function MapEdge:new(src_x, src_y, dst_x, dst_y)
    local self = {}
    self.src_x = src_x
    self.src_y = src_y
    self.dst_x = dst_x
    self.dst_y = dst_y
    setmetatable(self, { __index = MapEdge })
    return self
end

function MapEdge:clone(edge)
    return MapEdge:new(edge.src_x, edge.src_y, edge.dst_x, edge.dst_y)
end

function MapEdge.__eq(self, other)
    return self.src_x == other.src_x and self.src_y == other.src_y and self.dst_x == other.dst_x and
        self.dst_y == other.dst_y
end

function MapEdge.repr(self)
    return 'Edge: ' .. self.src_x .. ', ' .. self.src_y .. ', ' .. self.dst_x .. ', ' .. self.dst_y
end

Point = {}

function Point:new(x, y)
    local self = {}
    self.x = x
    self.y = y
    setmetatable(self, { __index = Point })
    return self
end

function Point.get_parents(self, map)
    return map[self.y][self.x].parents
end

function Point.get_node(self, map)
    return map[self.y][self.x]
end

function Point.__eq(self, other)
    return self.x == other.x and self.y == other.y
end

function Point.repr(self)
    return 'Point: ' .. self.x .. ', ' .. self.y
end

-- pub type Map = Vec<Vec<MapRoomNode>>;
local function enum(tbl)
    local length = #tbl
    for i = 1, length do
        local v = tbl[i]
        tbl[v] = i
    end

    return tbl
end

pttg_RoomType = enum {
    "EventRoom",
    "MonsterRoom",
    "MonsterRoomElite",
    "RestRoom",
    "ShopRoom",
    "TreasureRoom",
    "BossRoom"
}

function pttg_get_room_symbol(t)
    if t == nil then
        return "*"
    elseif t == pttg_RoomType.RestRoom then
        return "R"
    elseif t == pttg_RoomType.ShopRoom then
        return "$"
    elseif t == pttg_RoomType.MonsterRoom then
        return "B"
    elseif t == pttg_RoomType.EventRoom then
        return "E"
    elseif t == pttg_RoomType.MonsterRoomElite then
        return "L"
    elseif t == pttg_RoomType.TreasureRoom then
        return "T"
    elseif t == pttg_RoomType.BossRoom then
        return "X"
    end
    return "-"
end

local function generate_room_type(room_chances, available_room_count)
    local acc = {}
    local rooms_type_q = { pttg_RoomType.ShopRoom, pttg_RoomType.RestRoom, pttg_RoomType.MonsterRoomElite, pttg_RoomType
        .EventRoom }

    for _, t in ipairs(rooms_type_q) do
        local chance = room_chances[t]
        local rooms = chance * available_room_count
        local acc_len = #acc
        for i = 0, rooms do
            acc[acc_len + i] = t
        end
    end

    return acc
end

local function rule_assignable_to_row(n, room)
    local applicable_rooms = { [pttg_RoomType.RestRoom] = true, [pttg_RoomType.MonsterRoomElite] = true }

    if n.y <= 5 and applicable_rooms[room] then
        return false
    end

    if n.y >= 14 and room == pttg_RoomType.RestRoom then
        return false
    end

    return true
end

local function filter_redundant_edges(map)
    local existing_edges = {}
    local delete_list = {}

    for i, row in ipairs(map) do
        for j, node in ipairs(row) do
            for _, edge in ipairs(node.edges) do
                for _, prev in ipairs(existing_edges) do
                    if prev:__eq(edge) then
                        table.insert(delete_list, { i, j, MapEdge:clone(edge) })
                        break
                    end
                end
                table.insert(existing_edges, MapEdge:clone(edge))
            end
        end
    end

    for _, del in ipairs(delete_list) do
        for i, edge in ipairs(map[del[1]][del[2]].edges) do
            if edge:__eq(del[3]) then
                table.remove(map[del[1]][del[2]].edges, i)
                break
            end
        end
    end
end

local function get_common_ancestor(map, node1, node2, max_depth)
    assert(node1.y == node2.y, "Equal Y nodes")
    assert(node1.x ~= node2.x, "Unequal X nodes")

    local l_node
    local r_node

    if node1.x < node2.x then
        l_node = node1
        r_node = node2
    else
        l_node = node2
        r_node = node1
    end

    local current_y = node1.y

    local function cmp(t, fn)
        if #t == 0 then return nil, nil end
        local key, value = 1, t[1]
        for i = 2, #t do
            if fn(value, t[i]) then
                key, value = i, t[i]
            end
        end
        return key, value
    end


    while current_y >= 1 and current_y >= node1.y - max_depth do
        if #l_node:get_parents(map) == 0 or #r_node:get_parents(map) == 0 then
            return nil
        end
        _, l_node = cmp(l_node:get_parents(map), function(a, b) return a.x < b.x end)
        _, r_node = cmp(r_node:get_parents(map), function(a, b) return a.x > b.x end)

        if l_node == r_node then
            return l_node
        end
        current_y = current_y - 1
    end

    return nil
end

local function _create_paths(nodes, edge)
    local min
    local max
    local current_node = nodes[edge.dst_y][edge.dst_x]

    if edge.dst_y + 1 > #nodes then
        return nodes
    end

    local row_width = #nodes[edge.dst_y]
    local row_end_node = row_width

    if edge.dst_x == 1 then
        min = 0
        max = 1
    elseif edge.dst_x == row_end_node then
        min = -1
        max = 0
    else
        min = -1
        max = 1
    end

    local new_edge_x = edge.dst_x + math.random(min, max)
    local new_edge_y = edge.dst_y + 1

    local target_node_candidate = nodes[new_edge_y][new_edge_x]
    local target_coord_candidate = Point:new(new_edge_x, new_edge_y)

    local min_ancestor_gap = 3
    local max_ancester_gap = 5

    local current_node_coord = Point:new(current_node.x, current_node.y)

    for i, parent in ipairs(target_node_candidate.parents) do
        if not current_node_coord:__eq(parent) then
            local ancestor = get_common_ancestor(nodes, parent, current_node_coord, max_ancester_gap)
            if ancestor then
                local ancestor_gap = new_edge_y - ancestor.y
                if ancestor_gap < min_ancestor_gap then
                    if target_coord_candidate.x > current_node.x then
                        new_edge_x = edge.dst_x + math.random(-1, 0)
                        if new_edge_x < 1 then
                            new_edge_x = edge.dst_x
                        end
                    elseif target_coord_candidate.x == current_node.x then
                        new_edge_x = edge.dst_x + math.random(-1, 1)
                        if new_edge_x > row_end_node then
                            new_edge_x = edge.dst_x - 1
                        elseif new_edge_x < 1 then
                            new_edge_x = edge.dst_x + 1
                        end
                    else
                        new_edge_x = edge.dst_x + math.random(0, 1)
                        if new_edge_x > row_end_node then
                            new_edge_x = edge.dst_x
                        end
                    end
                    target_coord_candidate = Point:new(new_edge_x, new_edge_y)
                end
            end
        end
    end

    --     //eliminating edge crosses
    if edge.dst_x ~= 1 then
        local left_node = nodes[edge.dst_y][edge.dst_x - 1]
        local right_edge_of_left_node = left_node.edges[#left_node.edges] -- -1?? (last index)
        if right_edge_of_left_node then
            if right_edge_of_left_node.dst_x > new_edge_x then
                new_edge_x = right_edge_of_left_node.dst_x
            end
        end
    end

    if edge.dst_x < row_end_node then
        local right_node = nodes[edge.dst_y][edge.dst_x + 1];
        local left_edge_of_right_node = right_node.edges[1]
        if left_edge_of_right_node then
            if left_edge_of_right_node.dst_x < new_edge_x then
                new_edge_x = left_edge_of_right_node.dst_x
            end
        end
    end

    current_node = nodes[edge.dst_y][edge.dst_x]
    local new_edge = MapEdge:new(edge.dst_x, edge.dst_y, new_edge_x, new_edge_y)
    local copy_edge = MapEdge:new(edge.dst_x, edge.dst_y, new_edge_x, new_edge_y)
    table.insert(current_node.edges, new_edge)


    target_node_candidate = nodes[new_edge_y][new_edge_x]
    target_node_candidate.parents[#target_node_candidate.parents + 1] = Point:new(edge.dst_x, edge.dst_y)

    return _create_paths(nodes, copy_edge)
end



local function create_paths(nodes, path_density)
    assert(#nodes > 0, "Array is empty")
    assert(#nodes[1] > 0, "First Node is empty")

    local row_size = #nodes[1]
    local first_starting_node = 0

    for i = 1, path_density do
        local starting_node = math.random(1, row_size)
        if i == 1 then
            first_starting_node = starting_node
        end

        while starting_node == first_starting_node and i == 2 do
            starting_node = math.random(1, row_size)
        end
        local tmp_edge = MapEdge:new(starting_node, 0, starting_node, 1)

        nodes = _create_paths(nodes, tmp_edge)
    end

    return nodes
end

local function create_nodes(act, height, width)
    local nodes_y = {}
    for y = 1, height do
        local nodes_x = {}
        for x = 1, width do
            table.insert(nodes_x, MapRoomNode:new(x, y, act))
        end
        table.insert(nodes_y, nodes_x)
    end
    return nodes_y
end

local function add_boss(map)
    local boss_node = MapRoomNode:new(math.ceil(#map[1] / 2), #map + 1, map[1][1].z)
    boss_node.class = pttg_RoomType.BossRoom
    for _, node in pairs(map[#map]) do
        if #node.parents > 0 then
            table.insert(boss_node.parents, node)
            table.insert(node.edges, MapEdge:new(node.x, node.y, boss_node.x, boss_node.y))
        end
    end

    local boss_row = {}
    for x = 1, #map[1] do
        -- table.insert(boss_row, MapRoomNode:new(x, #map + 1))
        table.insert(boss_row, boss_node) -- all nodes lead to the boss
    end
    boss_row[boss_node.x] = boss_node

    map[#map + 1] = boss_row

    return map
end

local function generate_dungeon(act, height, width, path_density)
    map = create_nodes(act, height, width)
    map = create_paths(map, path_density);
    filter_redundant_edges(map)
    return map
end

local function count_connected_nodes(map)
    local count = 0
    for _, row in ipairs(map) do
        for _, node in ipairs(row) do
            if #node.edges > 0 and node.class == nil then
                count = count + 1
            end
        end
    end
    return count
end

local function get_siblings(map, node)
    local siblings = {}
    for _, parent in ipairs(node.parents) do
        for _, edge in ipairs(parent:get_node(map).edges) do
            local sib_node = map[edge.dst_y][edge.dst_x]
            if not sib_node:__eq(node) then
                table.insert(siblings, sib_node)
            end
        end
    end
    return siblings
end

local function rule_sibling_matches(sibs, room)
    local applicable_rooms = {
        [pttg_RoomType.RestRoom] = true,
        [pttg_RoomType.TreasureRoom] = true,
        [pttg_RoomType.ShopRoom] = true,
        [pttg_RoomType.MonsterRoomElite] = true,
        [pttg_RoomType.MonsterRoom] = true,
        [pttg_RoomType.EventRoom] = true
    }

    if applicable_rooms[room] then
        for _, sibling in ipairs(sibs) do
            if sibling.class == room then
                return true
            end
        end
    end
    return false
end

local function rule_parent_matches(map, parents, room)
    local applicable_rooms = {
        [pttg_RoomType.RestRoom] = true,
        [pttg_RoomType.TreasureRoom] = true,
        [pttg_RoomType.ShopRoom] = true,
        [pttg_RoomType.MonsterRoomElite] = true
    }
    if applicable_rooms[room] then
        for _, parent in ipairs(parents) do
            if parent.class == room then
                return true
            end
        end
    end
    return false
end


local function get_next_room_type(map, n, room_list)
    local parents = n.parents
    local siblings = get_siblings(map, n)
    for i, room in ipairs(room_list) do
        if rule_assignable_to_row(n, room) then
            if not rule_parent_matches(map, parents, room) and not rule_sibling_matches(siblings, room) then
                return room
            end

            if n.y == 1 then
                return room
            end
        end
    end

    return nil
end

local function assign_rooms_to_nodes(map, room_list)
    local height = #map
    local width = #map[1]

    for y = 1, height do
        for x = 1, width do
            local node = map[y][x]
            if #node.edges > 0 and node.class == nil then
                local room_to_be_set = get_next_room_type(map, node, room_list)
                if room_to_be_set ~= nil then
                    for i, room in ipairs(room_list) do
                        if room == room_to_be_set then
                            table.remove(room_list, i)
                            map[y][x].class = room_to_be_set
                            break
                        end
                    end
                end
            end
        end
    end

    return map
end

local function last_minute_node_checker(map)
    for _, row in ipairs(map) do
        for _, node in ipairs(row) do
            if #node.edges > 0 and node.class == nil then
                print(string.format("DEBUG: Room(%d, %d) was empty. Now populated with monsters)", node.y, node.x))
                node.class = pttg_RoomType.MonsterRoom
            end
        end
    end
    return map
end

local function distribute_rooms_across_map(map, room_list)
    local node_count = count_connected_nodes(map)
    local room_count = math.max(#room_list, node_count)
    for i = 1, room_count - #room_list do
        table.insert(room_list, pttg_RoomType.MonsterRoom)
    end

    local function shuffle(tbl)
        for i = #tbl, 2, -1 do
            local j = math.random(i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
        return tbl
    end

    shuffle(room_list)

    map = assign_rooms_to_nodes(map, room_list)
    map = last_minute_node_checker(map)

    return map
end

local function generate_maps(seed, map_height, map_width, path_density, ascension)
    local ACT_SEEDS = { 1, 200, 600 }

    local maps = {}

    for i, act_seed in ipairs(ACT_SEEDS) do
        math.randomseed(seed + act_seed)

        local map = generate_dungeon(i, map_height, map_width, path_density)
        local count = 0
        for _, row in ipairs(map) do
            for _, node in ipairs(row) do
                if ((#node.edges > 0 or (node.y == #map - 1 and #node.parents > 0)) and node.y ~= #map - 2) then
                    count = count + 1
                end
            end
        end

        for _, node in ipairs(map[1]) do
            node.class = pttg_RoomType.MonsterRoom
        end
        for _, node in ipairs(map[math.ceil(map_height / (1.5))]) do
            node.class = pttg_RoomType.TreasureRoom
        end
        for _, node in ipairs(map[#map]) do
            node.class = pttg_RoomType.RestRoom
        end

        local room_chances = {}
        room_chances[pttg_RoomType.ShopRoom] = 0.10
        room_chances[pttg_RoomType.RestRoom] = 0.12
        room_chances[pttg_RoomType.EventRoom] = 0.22
        if ascension == 0 then
            room_chances[pttg_RoomType.MonsterRoomElite] = 0.08
        else
            room_chances[pttg_RoomType.MonsterRoomElite] = 0.08 * (1.6 * ascension)
        end

        local room_list = generate_room_type(room_chances, count)
        distribute_rooms_across_map(map, room_list)

        map = add_boss(map)

        table.insert(maps, map)
    end

    return maps
end

function procgen:format_map(nodes, cursor)
    local s = ""
    s = s .. "\n__"

    for i = 1, #nodes[1] do
        s = s .. string.format("___", i)
    end

    for row_num = #nodes, 1, -1 do
        s = s .. string.format("\n|") --format!("\n{: <6}", ' ')
        for _, node in ipairs(nodes[row_num]) do
            local left, mid, right = "  ", "   ", "  "
            for _, edge in ipairs(node.edges) do
                if edge.dst_x == node.x then
                    mid = " | "
                elseif edge.dst_x < node.x then
                    left = "\\ "
                else
                    right = "/"
                end
            end
            s = s .. string.format("%s%s%s", left, mid, right)
        end
        s = s .. "\n|"

        --         if row_num < 10 then
        --             s = s .. string.format("\n %i |", row_num) --format!("\n{: <6}", row_num)
        --         else
        --             s = s .. string.format("\n%i |", row_num)  --format!("\n{: <6}", row_num)
        --         end

        for i, node in ipairs(nodes[row_num]) do
            local node_symbol = '  '
            if i % 2 == 0 then
                node_symbol = node_symbol .. ' '
            end

            if row_num == #nodes then
                for _, lower_node in ipairs(nodes[row_num - 1]) do
                    for _, edge in ipairs(lower_node.edges) do
                        if edge.dst_x == node.x then
                            node_symbol = pttg_get_room_symbol(node.class)
                        end
                    end
                end
            elseif #node.edges > 0 then
                node_symbol = pttg_get_room_symbol(node.class)
            end
            if cursor and node:__eq(cursor) then
                s = s .. string.format("  [[col:red]]%s[[/col]]  ", node_symbol)
            else
                s = s .. string.format("  %s  ", node_symbol)
            end
        end
    end

    s = s .. "\n"

    s = s .. "Map seed: " .. tostring(pttg:get_state("gen_seed"))


    return s
end

cm:add_first_tick_callback(function()
    pttg:load_seed()
end)

cm:add_post_first_tick_callback(function()
    local map_height = pttg:get_config("map_height")
    local map_width = pttg:get_config("map_width")
    local path_density = pttg:get_config("map_density")

    local difficulty;

    if pttg:get_config("difficulty") == 'easy' then
        difficulty = 1
    elseif pttg:get_config("difficulty") == 'regular' then
        difficulty = 2
    else
        difficulty = 4
    end

    local seed = pttg:get_config("seed")

    if pttg:get_config("random_seed") and cm:is_new_game() then
        seed = math.random(0, 10000)
    end

    if pttg:get_state("gen_seed") then
        seed = pttg:get_state("gen_seed")
    else
        pttg:set_seed(seed)
    end


    pttg:log(string.format("[ProcGen]Generating maps (seed=%i, difficulty=%s)", seed, difficulty))
    local maps = generate_maps(seed, map_height, map_width, path_density, difficulty)

    pttg:set_state('maps', maps)

    core:trigger_custom_event('pttg_procgen_finished', {})
end)

core:add_static_object("procgen", procgen);
