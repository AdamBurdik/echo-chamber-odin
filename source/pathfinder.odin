package game

import "core:math"
import "core:log"

MAX_SEARCH_ITERATIONS :: 100

SearchTile :: struct {
	coord: Coord,
	g_cost:       i32, // Distance from starting tile
	h_cost:       i32, // Distance from ending tile
	f_cost:       i32, // g_cost + h_cost
	parent_coord: Coord,
	has_parent:   bool,
}

heuristic :: proc(a, b: Coord) -> i32 {
	dx := a.x - b.x
	dy := a.y - b.y
	if dx < 0 do dx = -dx
	if dy < 0 do dy = -dy
	return dx + dy
}

// Finds shortest path from start to end tile using A*
// Returns list of coords to the target in order.
// *Does not include starting coord. Includes target node
search_path :: proc(board: ^Board, start: Coord, target: Coord) -> [dynamic]Coord {
	visited: [dynamic]Coord

	if start == target {
		return visited
	}

	searched_tiles := make(map[Coord]SearchTile)
	explored_tiles := make(map[Coord]SearchTile)

	defer delete(searched_tiles)
	defer delete(explored_tiles)

	// Initialize start tile
	start_h := heuristic(start, target)
	searched_tiles[start] = SearchTile{
		coord        = start,
		g_cost       = 0,
		h_cost       = start_h,
		f_cost       = start_h,
		parent_coord = {},
		has_parent   = false,
	}

	found := false
	target_tile: SearchTile

	i := 0

	for len(searched_tiles) > 0 {
		i += 1

		if i > MAX_SEARCH_ITERATIONS {
			log.warn("Max iterations reached")
			return {}
		}

		lowest_ptr := get_lowest_f_cost_tile(&searched_tiles)
		if lowest_ptr == nil {
			break
		}
		
		current := lowest_ptr^

		if current.coord == target {
			target_tile = current
			found = true
			break
		}

		delete_key(&searched_tiles, current.coord)
		explored_tiles[current.coord] = current

		// Check all surrounding neighbors
		for surrounding in get_surrounding_tiles(current.coord) {
			if !is_valid_and_walkable(board, surrounding) do continue

			// If already explored, skip
			if surrounding in explored_tiles {
				continue
			}

			tentative_g_cost := current.g_cost + 1

			in_searched := surrounding in searched_tiles
			neighbor, exists := searched_tiles[surrounding]

			if !in_searched || tentative_g_cost < neighbor.g_cost {
				h := heuristic(surrounding, target)
				searched_tiles[surrounding] = SearchTile{
					coord        = surrounding,
					g_cost       = tentative_g_cost,
					h_cost       = h,
					f_cost       = tentative_g_cost + h,
					parent_coord = current.coord,
					has_parent   = true,
				}
			}
		}
	}

	// If path was found, backtrack from target to start
	if found {
		curr := target_tile
		for curr.has_parent {
			append(&visited, curr.coord)
			if curr.parent_coord == start {
				break
			}
			curr = explored_tiles[curr.parent_coord]
		}

		// Reverse the array so it goes from start to target
		n := len(visited)
		for i := 0; i < n / 2; i += 1 {
			visited[i], visited[n - 1 - i] = visited[n - 1 - i], visited[i]
		}
	}

	return visited
}

// Gets just 4 surrounding tiles. (Fixed duplicate y-1 to y+1)
get_surrounding_tiles :: proc(source: Coord) -> [4]Coord {
	return {
		{source.x, source.y - 1}, // Down
		{source.x + 1, source.y}, // Right
		{source.x, source.y + 1}, // Up (Fixed)
		{source.x - 1, source.y}, // Left
	}
}

get_lowest_f_cost_tile :: proc(searched_tiles: ^map[Coord]SearchTile) -> ^SearchTile {
	lowest: ^SearchTile = nil

	for coord, &search_tile in searched_tiles^ {
		if lowest == nil || search_tile.f_cost < lowest.f_cost {
			lowest = &search_tile
		}
	}

	return lowest
}

is_valid_and_walkable :: proc(board: ^Board, coord: Coord) -> bool {
    // TODO: Check if surrounding is walkable
	exists, _ := get_enemy_at(board, coord)
    return !exists
}