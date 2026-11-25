package game

import "core:flags/example"
import "core:log"
import math "core:math"
import rl "vendor:raylib"

PLAYER_WIDTH :: 8
PLAYER_HEIGHT :: 16
PLAYER_JUMP_DURATION :: 0.35
PLAYER_JUMP_HEIGHT :: 8

PLAYER_SLASHING_DURATION :: 0.4

Player :: struct {
	grid_pos:          Coord,
	direction:         CardinalDirection,
	target_grid_pos:   Coord,

	// Jumping stuff
	is_jumping:        bool,
	jump_start_offset: rl.Vector2,
	jump_t:            f32,
	hop_y:             f32,

	// Slashing stuff
	is_slashing:       bool,
	slashing_t:        f32, // From 0 to 1
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

	x := BOARD_ORIGIN.x + f32(TILE_SIZE - PLAYER_WIDTH) / 2
	y := BOARD_ORIGIN.y - f32(PLAYER_HEIGHT) / 3 + player.hop_y

	rl.DrawTextureEx(texture, {x, y}, 0, 1, rl.WHITE)

	if player.is_slashing {
		frame_index := i32(map_range(player.slashing_t, 0, f32(slash_effect.frame_count)))

		effect := slash_effect.frames[frame_index]

		width := f32(effect.width)
		height := f32(effect.height)

		player_center := rl.Vector2{x + (PLAYER_WIDTH / 2), y + (PLAYER_HEIGHT / 2)}

		source := rl.Rectangle{0, 0, f32(effect.width), f32(effect.height)}
		// dest := rl.Rectangle{x - f32(effect.width) / 3, y - f32(effect.height) / 1.2, f32(effect.width), f32(effect.height)}
		dest := rl.Rectangle{player_center.x, player_center.y, width, height}
		origin := rl.Vector2{width / 2, height / 2 + PLAYER_HEIGHT / 1.1}

		rl.DrawTexturePro(effect, source, dest, origin, get_direction_rotation(player.direction), rl.WHITE)
	}
}

update_player :: proc(dt: f32, player: ^Player, board: ^Board) {
	if player.is_jumping {
		player.jump_t = min(1.0, player.jump_t + dt / PLAYER_JUMP_DURATION)
		t := player.jump_t

		remaining := 1.0 - ease_in_out_cubic(t)
		start := player.jump_start_offset
		board.camera_offset = {start.x * remaining, start.y * remaining}

		player.hop_y = -math.sin(math.PI * t) * PLAYER_JUMP_HEIGHT

		if t >= 1.0 {
			player.is_jumping = false
			board.camera_offset = {0, 0}
			player.hop_y = 0.0
			player.jump_t = 0.0
			player.jump_start_offset = {0, 0}
		}
	}

	if player.is_slashing {
		player.slashing_t += dt / PLAYER_SLASHING_DURATION

		if player.slashing_t >= 1 {
			player.is_slashing = false
			player.slashing_t = 0
		}
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

	old_grid_pos := player.grid_pos

	player.target_grid_pos = Coord {
		player.grid_pos.x + i32(dir_vector.x) * amount,
		player.grid_pos.y + i32(dir_vector.y) * amount,
	}

	player.grid_pos = player.target_grid_pos

	dx := f32((player.grid_pos.x - old_grid_pos.x) * TILE_SIZE)
	dy := f32((player.grid_pos.y - old_grid_pos.y) * TILE_SIZE)

	player.jump_start_offset = {dx, dy}
	board.camera_offset = player.jump_start_offset
	player.is_jumping = true
	player.jump_t = 0.0
}
rotate_player :: proc(player: ^Player, anti_clockwise: bool) {
	player.direction = get_rotated_direction(player.direction, anti_clockwise)
}

slash_player :: proc(player: ^Player) {
	if player.is_slashing {
		return
	}
	player.is_slashing = true
	player.slashing_t = 0
}
