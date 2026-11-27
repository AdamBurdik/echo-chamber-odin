package game

import "core:fmt"
import "core:log"
import math "core:math"
import "core:strings"
import rl "vendor:raylib"

ENEMY_JUMP_DURATION :: 0.35
ENEMY_JUMP_HEIGHT :: 8
ENEMY_HIT_TINT_DURATION :: 0.25
ENEMY_ATTACK_DURATION :: 0.2
ENEMY_ATTACK_DISTANCE :: 5

EnemyType :: enum {
	GOBLIN,
	SLIME_FULL,
	SLIME_HALF,
	SLIME_QUARTER,
	CULTIST,
}

Enemy :: struct {
	coord:              Coord,
	type:               EnemyType,
	health:             i32,
	direction:          CardinalDirection,
	is_dead:            bool,

	// jump animation
	is_jumping:         bool,
	jump_start_offset:  rl.Vector2,
	jump_offset:        rl.Vector2,
	jump_t:             f32,
	hop_y:              f32,

	// Damaging
	hit_overlay_t:      f32,

	// Hiting animation. Hiting for enemies is just sliding into a player
	is_attacking:       bool,
	attack_t:           f32,
	attack_offset:      rl.Vector2,

	// Cultist specific stuff
	// It should be probably seperated to like union or smth
	// but im too lazy for that
	is_summoning:       bool,
	summoning_t:        f32,
	summoning_cooldown: f32,
}

get_enemy_texture :: proc(enemy: ^Enemy) -> rl.Texture {
	type := enemy.type
	direction := enemy.direction

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
		if enemy.is_summoning {
			return get_texture_from_directional_entity(&cultist_summon, direction)
		}
		return get_texture_from_directional_entity(&cultist_idle, direction)
	}
	panic("Unhandled EnemyType case")
}

draw_enemy :: proc(enemy: ^Enemy, player: ^Player, board: ^Board) {
	texture := get_enemy_texture(enemy)

	// TODO: fix centering
	x :=
		BOARD_ORIGIN.x +
		f32((enemy.coord.x - player.grid_pos.x) * TILE_SIZE) +
		board.camera_offset.x +
		enemy.jump_offset.x +
		f32((TILE_SIZE - texture.width) / 2) +
		enemy.attack_offset.x

	y :=
		BOARD_ORIGIN.y +
		f32((enemy.coord.y - player.grid_pos.y) * TILE_SIZE) +
		board.camera_offset.y +
		enemy.jump_offset.y +
		enemy.hop_y +
		f32((TILE_SIZE - texture.height) / 2) +
		enemy.attack_offset.y

	player_center := rl.Vector2{x + f32(texture.width) / 2, y + f32(texture.height) / 2}

	if enemy.is_summoning {
		frame_index := i32(map_range(enemy.summoning_t, 0, f32(summoning_circle_effect.frame_count)))
		summoning_texture := summoning_circle_effect.frames[frame_index]

		rl.DrawTextureEx(
			summoning_texture,
			{
				player_center.x - f32(summoning_texture.width) / 2,
				player_center.y - f32(summoning_texture.height) / 2,
			},
			0,
			1,
			rl.WHITE,
		)
	}

	tint := rl.WHITE

	if (enemy.hit_overlay_t > 0) {
		tint = COLOR_HIT_OVERLAY
	}

	rl.DrawTextureEx(texture, {x, y}, 0, 1, tint)
}

draw_enemies :: proc(board: ^Board, player: ^Player) {
	for &enemy in board.enemies {
		draw_enemy(&enemy, player, board)
	}
}

update_enemy :: proc(dt: f32, enemy: ^Enemy) {
	if enemy.is_jumping {
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

	if (enemy.hit_overlay_t > 0) {
		enemy.hit_overlay_t -= dt / ENEMY_HIT_TINT_DURATION
	}

	if (enemy.is_attacking) {
		enemy.attack_t += dt / ENEMY_ATTACK_DURATION

		if enemy.attack_t >= 1 {
			enemy.attack_offset = {0, 0}
			enemy.is_attacking = false
			enemy.attack_t = 0.0
		} else {
			offset := math.sin(enemy.attack_t * math.PI)

			dir_vector := get_direction_vector(enemy.direction)

			enemy.attack_offset = {
				dir_vector.x * ENEMY_ATTACK_DISTANCE * offset,
				dir_vector.y * ENEMY_ATTACK_DISTANCE * offset,
			}
		}
	}

	if enemy.is_summoning {
		enemy.summoning_t += dt / CULTIST_SUMMONING_DURATION
		if enemy.summoning_t >= 1 {
			enemy.is_summoning = false
			enemy.summoning_cooldown = 1
		}
	}
	if enemy.summoning_cooldown > 0 {
		enemy.summoning_cooldown -= dt / CULTIST_SUMMONING_COOLDOWN
	}

}

update_enemies :: proc(dt: f32, board: ^Board) {
	for i := len(board.enemies) - 1; i >= 0; i -= 1 {
		if board.enemies[i].is_dead {
			ordered_remove(&board.enemies, i)
		}
	}

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

// Enemy takes damage
damage_enemy :: proc(enemy: ^Enemy, damage: i32) {
	enemy.health -= damage

	if (enemy.health <= 0) {
		enemy.is_dead = true
		return
	}

	enemy.hit_overlay_t = 1

	// TODO: Play some damage animation or smth idk
}

// The enemy attacks
attack_enemy :: proc(enemy: ^Enemy, damage: i32, player: ^Player) {
	if enemy.is_attacking {
		return
	}

	dir_vector := get_direction_vector(enemy.direction)
	dx := i32(dir_vector.x)
	dy := i32(dir_vector.y)

	forward := Coord{enemy.coord.x + i32(dx), enemy.coord.y + i32(dy)}

	if forward == player.grid_pos {
		// Player is actually forward, so we can atack him
		enemy.is_attacking = true
		damage_player(player, damage)
	}
}
