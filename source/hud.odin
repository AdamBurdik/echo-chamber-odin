package game

import math "core:math"
import rl "vendor:raylib"

BEGIN_BUTTON_WIDTH :: 145
BEGIN_BUTTON_HEIGHT :: 28

begin_button_hovering := false

draw_hud :: proc() {
	// Draw begin button
	begin_button_x := ACTION_QUEUE_ORIGIN.x
	begin_button_y := ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 4

	rl.DrawRectangle(
		i32(begin_button_x),
		i32(begin_button_y),
		BEGIN_BUTTON_WIDTH,
		BEGIN_BUTTON_HEIGHT,
		COLOR_TWILIGHT,
	)

	text_size := rl.MeasureTextEx(tiny5_font, "BEGIN_RUN", 18, 0)

	rl.DrawTextEx(
		tiny5_font,
		"BEGIN_RUN",
		{
			// Again... rounding cause the text is wierd when doing using factions idk
			ACTION_QUEUE_ORIGIN.x + math.round((BEGIN_BUTTON_WIDTH - text_size.x) / 2),
			ACTION_QUEUE_ORIGIN.y + ACTION_QUEUE_HEIGHT + 4 + (math.round(BEGIN_BUTTON_HEIGHT - text_size.y) / 2),
		},
		18,
		0,
		COLOR_CHARTREUSE,
	)


	if begin_button_hovering {
		rl.DrawRectangle(
			i32(begin_button_x),
			i32(begin_button_y),
			BEGIN_BUTTON_WIDTH,
			BEGIN_BUTTON_HEIGHT,
			COLOR_HOVERED,
		)
	}

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
