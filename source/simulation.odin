package game

import "core:log"

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

tick_simulation :: proc(queue: ^Queue, player: ^Player, board: ^Board) {
	if len(queue.selected) < 1 {
		is_simulation_running = false
		simulation_cooldown = 0
		return
	}

	card := pop_front(&queue.selected)
	process_card(&card, player, board, queue)
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
