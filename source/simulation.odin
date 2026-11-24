package game

is_simulation_running := false

process_card :: proc(card: ^Card, player: ^Player, board: ^Board) {
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

	delete(card.actions)
	delete(card.lines)
}

run_simulation :: proc(queue: ^Queue, player: ^Player, board: ^Board) {
	if (len(queue.selected) < 1) {
		return
	}

	card := pop(&queue.selected)
	process_card(&card, player, board)
}
