package game

import rl "vendor:raylib"

Scene :: enum {
	MAIN_MENU,
	GAMEPLAY,
	DEATH_SCREEN,
}

update_gameplay_scene :: proc(dt: f32, queue: ^Queue, player: ^Player, board: ^Board) {
	update_queue(queue)
	update_player(dt, player, board)
	update_hud(queue)
	update_simulation(dt, queue, player, board)
	update_enemies(dt, board)

	// TODO: Remove
	if rl.IsKeyReleased(rl.KeyboardKey.W) {
		jump_player(player, CardinalDirection.UP, 1, board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.S) {
		jump_player(player, CardinalDirection.DOWN, 1, board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.A) {
		jump_player(player, CardinalDirection.LEFT, 1, board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.D) {
		jump_player(player, CardinalDirection.RIGHT, 1, board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.SPACE) {
		slash_player(player, board, 50)
	}
}

draw_gameplay_scene :: proc(
    queue: ^Queue,
    player: ^Player,
    board: ^Board,
) {
	// TODO: Actually draw backdrop
	draw_board(board, player)
	draw_enemies(board, player)

	rl.DrawTexture(backdrop_texture, 0, 0, rl.WHITE)

	draw_player(player)
	draw_queue(queue)
	draw_hud(player)
}


draw_main_menu_screen :: proc() {

}

update_main_menu_screen :: proc() {

}
