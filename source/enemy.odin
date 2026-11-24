package game

import rl "vendor:raylib"

EnemyType :: enum {
	GOBLIN,
	SLIME_FULL,
	SLIME_HALF,
	SLIME_QUARTER,
	CULTIST,
}

Enemy :: struct {
	coord:     Coord,
	type:      EnemyType,
	health:    i32,
	direction: CardinalDirection,
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

	x :=
		BOARD_ORIGIN.x +
		f32((enemy.coord.x - player.grid_pos.x) * TILE_SIZE) +
		board.camera_offset.x +
        f32((TILE_SIZE - texture.width) / 2)
	y :=
		BOARD_ORIGIN.y +
		f32((enemy.coord.y - player.grid_pos.y) * TILE_SIZE) +
		board.camera_offset.y

	rl.DrawTextureEx(texture, {x, y}, 0, 1, rl.WHITE)
}

draw_enemies :: proc(board: ^Board, player: ^Player) {
	for &enemy in board.enemies {
		draw_enemy(&enemy, player, board)
	}
}
