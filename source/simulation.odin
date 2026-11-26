package game

is_simulation_running := false
simulation_cooldown := f32(0)

process_card :: proc(card: ^Card, player: ^Player, board: ^Board, queue: ^Queue) {
	for action in card.actions {
		switch act in action {
		case ActionMove:
			jump_player(player, player.direction, act.distance, board)
		case ActionInstantHeal:

		case ActionRegen:

		case ActionRotate:
			rotate_player(player, act.anti_clockwise)

		case ActionSlash:
			slash_player(player, board, act.amount)
		}
	}

	if card.is_echo {
		card.echo_cooldown = 3
		// Reset the stuff, just in case
		card.is_hovered = false
		card.is_selected = false
		append(&queue.echo, card^)
	} else {
		delete(card.actions)
		delete(card.lines)
	}
}

tick_goblin_enemy :: proc(enemy: ^Enemy, board: ^Board, player: ^Player) {
	path := get_path_to_player(board, enemy.coord, player)
	path_len := len(path)
	if path_len < 1 {
		// This means the enemy is standing on a player, which should not be possible....
		return
	}

	if path_len == 1 {
		// Enemy is right next to player
		// So attack should happen

		player_dir := get_direction_between(enemy.coord, player.grid_pos)
		if enemy.direction != player_dir {
			// Enemy is not looking at player, so it should first rotate
			enemy.direction = player_dir
			return
		}

		// TODO: Change enemy damage
		// TODO: Check if player is actually next to enemy
		attack_enemy(enemy, 10, player)

	} else {
		// Enemy is at least 1 tile away from player
		next_step := path[0]
		jump_enemy(enemy, get_direction_between(enemy.coord, next_step), 1, board)
	}
}

tick_enemies :: proc(board: ^Board, player: ^Player) {
	for &enemy in board.enemies {
		switch enemy.type {
		case .GOBLIN:
			tick_goblin_enemy(&enemy, board, player)

		case .SLIME_FULL, .SLIME_HALF, .SLIME_QUARTER:
		// TODO: implement this ig
		case .CULTIST:
		// TODO: implement this ig
		}
	}
}

tick_simulation :: proc(queue: ^Queue, player: ^Player, board: ^Board) {
	if len(queue.selected) < 1 {
		is_simulation_running = false
		simulation_cooldown = 0
		return
	}

	card := pop_front(&queue.selected)
	process_card(&card, player, board, queue)

	tick_enemies(board, player)
}

update_simulation :: proc(dt: f32, queue: ^Queue, player: ^Player, board: ^Board) {
	if !is_simulation_running {
		return
	}

	simulation_cooldown -= dt

	if simulation_cooldown <= 0 {
		tick_simulation(queue, player, board)
		simulation_cooldown += 1.0 // 1 second
	}
}

run_simulation :: proc(queue: ^Queue) {
	if (len(queue.selected) < 1) {
		return
	}

	is_simulation_running = true
}
