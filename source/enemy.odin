package game

import math "core:math"
import rl "vendor:raylib"

ENEMY_JUMP_DURATION :: 0.35
ENEMY_JUMP_HEIGHT :: 8

EnemyType :: enum {
	GOBLIN,
	SLIME_FULL,
	SLIME_HALF,
	SLIME_QUARTER,
	CULTIST,
}

Enemy :: struct {
	coord:             Coord,
	type:              EnemyType,
	health:            i32,
	direction:         CardinalDirection,

	// jump animation
	is_jumping:        bool,
	jump_start_offset: rl.Vector2,
	jump_offset:       rl.Vector2,
	jump_t:            f32,
	hop_y:             f32,
}

get_enemy_texture :: proc(type: EnemyType, direction: CardinalDirection) -> rl.Texture {
	switch type {
	case .GOBLIN:
		return get_texture_from_directional_entity(&goblin_idle, direction)
	case .SLIME_FULL:
		return get_texture_from_directional_entity(&slime_full, direction)
	case .SLIME_HALF:
		return get_texture_from_directional_entity(&slime_half, direction)
	case .SLIME_QUARTER:
		return get_texture_from_directional_entity(&slime_quarter, direction)
	case .CULTIST:
		return get_texture_from_directional_entity(&cultist_idle, direction)
	}
	panic("Unhandled EnemyType case")
}

draw_enemy :: proc(enemy: ^Enemy, player: ^Player, board: ^Board) {
	texture := get_enemy_texture(enemy.type, enemy.direction)

	// TODO: fix centering
	x :=
		BOARD_ORIGIN.x +
		f32((enemy.coord.x - player.grid_pos.x) * TILE_SIZE) +
		board.camera_offset.x +
		enemy.jump_offset.x +
		f32((TILE_SIZE - texture.width) / 2)
	y :=
		BOARD_ORIGIN.y +
		f32((enemy.coord.y - player.grid_pos.y) * TILE_SIZE) +
		board.camera_offset.y +
		enemy.jump_offset.y +
		enemy.hop_y +
		f32((TILE_SIZE - texture.height) / 2)

	rl.DrawTextureEx(texture, {x, y}, 0, 1, rl.WHITE)
}

draw_enemies :: proc(board: ^Board, player: ^Player) {
	for &enemy in board.enemies {
		draw_enemy(&enemy, player, board)
	}
}

update_enemy :: proc(dt: f32, enemy: ^Enemy) {
	if !enemy.is_jumping {return}

	enemy.jump_t = min(1.0, enemy.jump_t + dt / ENEMY_JUMP_DURATION)
	t := enemy.jump_t

	remaining := 1.0 - ease_in_out_cubic(t)
	start := enemy.jump_start_offset
	enemy.jump_offset = {start.x * remaining, start.y * remaining}

	enemy.hop_y = -math.sin(math.PI * t) * ENEMY_JUMP_HEIGHT

	if t >= 1.0 {
		enemy.is_jumping = false
		enemy.jump_offset = {0, 0}
		enemy.hop_y = 0.0
		enemy.jump_t = 0.0
		enemy.jump_start_offset = {0, 0}
	}
}

update_enemies :: proc(dt: f32, board: ^Board) {
	for &enemy in board.enemies {
		update_enemy(dt, &enemy)
	}
}

jump_enemy :: proc(enemy: ^Enemy, direction: CardinalDirection, amount: i32, board: ^Board) {
	if enemy.is_jumping {return}

	enemy.direction = direction
	dir_vector := get_direction_vector(direction)

	old_coord := enemy.coord

	enemy.coord = Coord {
		enemy.coord.x + i32(dir_vector.x) * amount,
		enemy.coord.y + i32(dir_vector.y) * amount,
	}

	dx := f32((old_coord.x - enemy.coord.x) * TILE_SIZE)
	dy := f32((old_coord.y - enemy.coord.y) * TILE_SIZE)

	enemy.jump_start_offset = {dx, dy}
	enemy.jump_offset = enemy.jump_start_offset
	enemy.is_jumping = true
	enemy.jump_t = 0.0
}
