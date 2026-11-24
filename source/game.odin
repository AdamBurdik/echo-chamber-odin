#+feature dynamic-literals

package game

import "core:c"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"


// Global generic contants
DISPLAY_WIDTH :: 1920
DISPLAY_HEIGHT :: 1080

VIRTUAL_WIDTH :: 480
VIRTUAL_HEIGHT :: 270

TILE_SIZE :: i32(16)


// Later initialized stuff
board: Board
virtual_texture: rl.RenderTexture
queue: Queue
player: Player

init :: proc() {
	init_assets()

	// Initialize systems and other stuff
	board = create_board()
	queue = {}

	add_card_to_action(
		&queue,
		Card {
			icon = .ARROW,
			lines = [dynamic]string{"Move 1 tile", "forward"},
			actions = {ActionMove{distance = 1}},
			is_selected = false,
			is_echo = false,
			is_hovered = false,
		},
	)
	add_card_to_action(
		&queue,
		Card {
			icon = .HEART,
			lines = [dynamic]string{"Instant heal", "25HP"},
			actions = {ActionInstantHeal{amount = 25}},
			is_selected = false,
			is_echo = false,
			is_hovered = false,
		},
	)
		add_card_to_action(
		&queue,
		Card {
			icon = .CLOCKWISE,
			lines = [dynamic]string{"Rotate right"},
			actions = {ActionRotate{anti_clockwise=false}},
			is_selected = false,
			is_echo = false,
			is_hovered = false,
		},
	)
	player = Player{{0, 0}, CardinalDirection.DOWN, {}, false, {}, 0, 0}


	run = true
	rl.SetConfigFlags({.FULLSCREEN_MODE, .WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(DISPLAY_WIDTH, DISPLAY_HEIGHT, "Hello! Odin + Raylib on the web __float__")

	virtual_texture = rl.LoadRenderTexture(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
	rl.SetTextureFilter(virtual_texture.texture, .POINT)
	load_assets()

	// Anything in `assets` folder is available to load.
	// texture = rl.LoadTexture("assets/round_cat.png")

	// A different way of loading a texture: using `read_entire_file` that works
	// both on desktop and web. Note: You can import `core:os` and use
	// `os.read_entire_file`. But that won't work on web. Emscripten has a way
	// to bundle files into the build, and we access those using this
	// special `read_entire_file`.
	// if long_cat_data, long_cat_ok := read_entire_file("assets/long_cat.png", context.temp_allocator); long_cat_ok {
	// 	long_cat_img := rl.LoadImageFromMemory(".png", raw_data(long_cat_data), c.int(len(long_cat_data)))
	// 	texture2 = rl.LoadTextureFromImage(long_cat_img)

	// 	rl.UnloadImage(long_cat_img)
	// }
}

update :: proc() {
	dt := rl.GetFrameTime()

	sourceRec := rl.Rectangle{0, 0, VIRTUAL_WIDTH, -VIRTUAL_HEIGHT}
	destRec := rl.Rectangle{0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT}
	origin := rl.Vector2{0, 0}

	update_queue(&queue)
	update_player(dt, &player, &board)
	update_hud(&queue, &player, &board)

	// TODO: Remove
	if rl.IsKeyReleased(rl.KeyboardKey.W) {
		jump_player(&player, CardinalDirection.UP, 1, &board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.S) {
		jump_player(&player, CardinalDirection.DOWN, 1, &board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.A) {
		jump_player(&player, CardinalDirection.LEFT, 1, &board)
	}
	if rl.IsKeyReleased(rl.KeyboardKey.D) {
		jump_player(&player, CardinalDirection.RIGHT, 1, &board)
	}

	// -- Virtual Drawing --
	rl.BeginTextureMode(virtual_texture)
	{
		rl.ClearBackground({0, 0, 0, 255})

		// TODO: Actually draw backdrop
		draw_board(&board, &player)

		rl.DrawTexture(backdrop_texture, 0, 0, rl.WHITE)

		draw_player(&player)
		draw_queue(&queue)
		draw_hud()
	}
	rl.EndTextureMode()

	// -- Actual Drawing --
	rl.BeginDrawing()
	{
		rl.ClearBackground({0, 0, 0, 255})
		rl.DrawTexturePro(virtual_texture.texture, sourceRec, destRec, origin, 0, rl.WHITE)

		rl.DrawText(
			strings.clone_to_cstring(
				fmt.tprintf("Player pos: %d; %d", player.grid_pos.x, player.grid_pos.y),
			),
			10,
			10,
			30,
			rl.GREEN,
		)
		rl.DrawFPS(10, 50)
	}

	rl.EndDrawing()

	// Anything allocated using temp allocator is invalid after this.
	free_all(context.temp_allocator)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			run = false
		}
	}

	return run
}
