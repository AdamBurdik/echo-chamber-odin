package game

import "core:log"
import math "core:math"
import rl "vendor:raylib"

PLAYER_WIDTH :: 8
PLAYER_HEIGHT :: 16
PLAYER_JUMP_DURATION :: 0.35
PLAYER_JUMP_HEIGHT :: 8

Player :: struct {
	grid_pos:          Coord,
	direction:         CardinalDirection,
	target_grid_pos:   Coord,
	is_jumping:        bool,
	jump_start_offset: rl.Vector2,
	jump_t:            f32,
	hop_y:             f32,
}

draw_player :: proc(player: ^Player) {
	texture := player_idle.front
	switch player.direction {
	case CardinalDirection.UP:
		texture = player_idle.back
	case CardinalDirection.DOWN:
		texture = player_idle.front
	case CardinalDirection.LEFT:
		texture = player_idle.left
	case CardinalDirection.RIGHT:
		texture = player_idle.right
	}

	rl.DrawTextureEx(
		texture,
		{
			BOARD_ORIGIN.x + f32(TILE_SIZE - PLAYER_WIDTH) / 2,
			BOARD_ORIGIN.y - f32(PLAYER_HEIGHT) / 3 + player.hop_y,
		},
		0,
		1,
		rl.WHITE,
	)
}

update_player :: proc(dt: f32, player: ^Player, board: ^Board) {
	if player.is_jumping {
		player.jump_t = min(1.0, player.jump_t + dt / PLAYER_JUMP_DURATION)
		t := player.jump_t

		remaining := 1.0 - ease_in_out_cubic(t)
		start := player.jump_start_offset
		board.camera_offset = {f32(start.x) * remaining, f32(start.y) * remaining}

		player.hop_y = -math.sin(math.PI * t) * PLAYER_JUMP_HEIGHT

		if t >= 1 {
			player.grid_pos = player.target_grid_pos

			player.is_jumping = false
			board.camera_offset = {0, 0}
			player.hop_y = 0.0
			player.jump_t = 0
			player.jump_start_offset = {0, 0}
		}
		return
	}
}

move_player :: proc(player: ^Player, direction: CardinalDirection) {
	dir_vector := get_direction_vector(direction)

	player.grid_pos.x += i32(dir_vector.x)
	player.grid_pos.y += i32(dir_vector.y)
}

turn :: proc(player: ^Player, direction: CardinalDirection) {
	player.direction = direction
}

jump_player :: proc(player: ^Player, direction: CardinalDirection, amount: i32, board: ^Board) {
	if player.is_jumping {return}

	turn(player, direction)

	dir_vector := get_direction_vector(direction)

	player.target_grid_pos = Coord {
		player.grid_pos.x + i32(dir_vector.x) * amount,
		player.grid_pos.y + i32(dir_vector.y) * amount,
	}

	player.jump_start_offset = {
		dir_vector.x * f32(TILE_SIZE * amount),
		dir_vector.y * f32(TILE_SIZE * amount),
	}

	board.camera_offset = {f32(player.jump_start_offset.x), f32(player.jump_start_offset.y)}
	player.is_jumping = true
}
