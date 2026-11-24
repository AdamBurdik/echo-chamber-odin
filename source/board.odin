package game

import "core:fmt"
import "core:log"
import random "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

BOARD_GRID_WIDTH :: 21
BOARD_GRID_HEIGHT :: 21
BOARD_RENDER_DISTANCE :: 10
BOARD_WIDTH :: BOARD_GRID_WIDTH * TILE_SIZE
BOARD_HEIGHT :: BOARD_GRID_HEIGHT * TILE_SIZE
BOARD_ORIGIN :: rl.Vector2 {
	// (VIRTUAL_WIDTH - BOARD_GRID_WIDTH) / 2.5,
	// (VIRTUAL_HEIGHT - BOARD_GRID_HEIGHT) / 2,
	180,
	138,
}

Coord :: struct {
	x: i32,
	y: i32,
}

Tile :: struct {
	tile_id: i32,
}

Board :: struct {
	grid:          map[Coord]Tile,
	enemies:       [dynamic]Enemy,

	// Using raylib vector for camera offset, to make it smoother and not jittery
	camera_offset: rl.Vector2,
}

create_board :: proc() -> Board {
	board := Board{}
	board.grid = make(map[Coord]Tile)

	for y := i32(-BOARD_GRID_HEIGHT / 2); y < BOARD_GRID_HEIGHT / 2 + 1; y += 1 {
		for x := i32(-BOARD_GRID_WIDTH / 2); x < BOARD_GRID_WIDTH / 2 + 1; x += 1 {
			coord := Coord{x, y}

			board.grid[coord] = {0}
		}

	}

	return board
}

get_surrounding_coords :: proc(center: Coord, radius: i32) -> []Coord {
	width := radius * 2 + 1
	// Using temp allocation cause this function is expected to be just for rendering tiles
	array := make([]Coord, width * width, context.temp_allocator)

	i := 0
	for y := center.y - radius; y <= center.y + radius; y += 1 {
		for x := center.x - radius; x <= center.x + radius; x += 1 {
			array[i] = {x, y}
			i += 1
		}
	}

	return array
}

get_tile :: proc(board: ^Board, coord: Coord) -> Tile {
	tile, exists := board.grid[coord]
	if exists {
		return tile
	}

	// TODO: Do some random generation or smth idk
	tile = Tile{0}
	board.grid[coord] = tile

	random := random.int32_range(0, 10)
	type := EnemyType.GOBLIN

	if random <= 1 {
		type = .GOBLIN
	} else if (random <= 2) {
		type = .SLIME_FULL
	} else if (random <= 3) {
		type = .CULTIST
	}

	if (random <= 3) {
		append(&board.enemies, Enemy{coord = coord, type = type, health = 100, direction = .DOWN})
	}


	return tile
}


draw_board :: proc(board: ^Board, player: ^Player) {
	surrounding := get_surrounding_coords(player.grid_pos, BOARD_RENDER_DISTANCE)

	for coord in surrounding {
		tile := get_tile(board, coord)
		grid_x := coord.x
		grid_y := coord.y

		x := BOARD_ORIGIN.x + f32((grid_x - player.grid_pos.x) * TILE_SIZE) + board.camera_offset.x
		y := BOARD_ORIGIN.y + f32((grid_y - player.grid_pos.y) * TILE_SIZE) + board.camera_offset.y

		rl.DrawTextureEx(empty_tile_texture, {x, y}, 0, 1, rl.WHITE)
	}
}
