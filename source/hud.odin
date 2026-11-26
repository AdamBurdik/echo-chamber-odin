package game

import math "core:math"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

BEGIN_BUTTON_WIDTH :: 137
BEGIN_BUTTON_HEIGHT :: 14

begin_button_hovering := false

draw_hud :: proc(player: ^Player) {
	// Draw begin button
	begin_button_x := ACTION_QUEUE_ORIGIN.x + 8
	begin_button_y := ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 1

	text_size := rl.MeasureTextEx(tiny5_font, "<< BEGIN RUN >>", 18, 0)

	text_color := COLOR_DUST_PURPLE
	if begin_button_hovering {
		text_color = COLOR_ROSE
	}

	rl.DrawTextEx(
		tiny5_font,
		"<< BEGIN RUN >>",
		{
			// Again... rounding cause the text is wierd when doing using factions idk
			begin_button_x + math.round((BEGIN_BUTTON_WIDTH - text_size.x) / 2),
			begin_button_y + (math.round(BEGIN_BUTTON_HEIGHT - text_size.y) / 2),
		},
		18,
		0,
		text_color,
	)

	// Overlay rectangle when it should be blocked
	if is_simulation_running {
		rl.DrawRectangle(
			i32(begin_button_x),
			i32(begin_button_y),
			BEGIN_BUTTON_WIDTH,
			BEGIN_BUTTON_HEIGHT,
			COLOR_BLOCKED_OVERLAY,
		)
	}

	// Draw player health
	heatlh_text := strings.clone_to_cstring(fmt.tprintf("%d HP", player.health), context.temp_allocator)

	rl.DrawTextEx(
		tiny5_font,
		heatlh_text,
		{11, 56},
		9,
		0,
		COLOR_RED,
	)

	// Draw player XP
	rl.DrawTextEx(
		tiny5_font,
		strings.clone_to_cstring(fmt.tprintf("%d XP", player.experience), context.temp_allocator),
		{11, 73},
		9,
		0,
		COLOR_ECHO_HIGHLIGHT,
	)

	rl.DrawTextEx(
		tiny5_font,
		strings.clone_to_cstring(fmt.tprintf("%3d", player.xp_level), context.temp_allocator),
		{51, 73},
		9,
		0,
		COLOR_ECHO_HIGHLIGHT,
	)
}

update_hud :: proc(queue: ^Queue) {
	mouse_x := get_mouse_x()
	mouse_y := get_mouse_y()

	begin_button_x := ACTION_QUEUE_ORIGIN.x
	begin_button_y := ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 4

	if !is_simulation_running &&
	   rl.CheckCollisionPointRec(
		   {mouse_x, mouse_y},
		   {begin_button_x, begin_button_y, BEGIN_BUTTON_WIDTH, BEGIN_BUTTON_HEIGHT},
	   ) {
		begin_button_hovering = true

		if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
			run_simulation(queue)
		}
	} else {
		begin_button_hovering = false
	}
}
