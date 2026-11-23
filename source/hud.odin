package game

import math "core:math"
import rl "vendor:raylib"

BEGIN_BUTTON_WIDTH :: 137
BEGIN_BUTTON_HEIGHT :: 14

begin_button_hovering := false

draw_hud :: proc() {
	// Draw begin button
	begin_button_x := ACTION_QUEUE_ORIGIN.x + 8
	begin_button_y := ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 2

	// rl.DrawRectangle(
	// 	i32(begin_button_x),
	// 	i32(begin_button_y),
	// 	BEGIN_BUTTON_WIDTH,
	// 	BEGIN_BUTTON_HEIGHT,
	// 	rl.RED,
	// )

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
}

update_hud :: proc() {
	mouse_x := get_mouse_x()
	mouse_y := get_mouse_y()

	begin_button_x := ACTION_QUEUE_ORIGIN.x
	begin_button_y := ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 4

	if rl.CheckCollisionPointRec(
		{mouse_x, mouse_y},
		{begin_button_x, begin_button_y, BEGIN_BUTTON_WIDTH, BEGIN_BUTTON_HEIGHT},
	) {
		begin_button_hovering = true
	} else {
		begin_button_hovering = false
	}
}
