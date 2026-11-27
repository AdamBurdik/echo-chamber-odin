package game

import "core:fmt"
import math "core:math"
import "core:strings"
import rl "vendor:raylib"

BEGIN_BUTTON_WIDTH :: 137
BEGIN_BUTTON_HEIGHT :: 14

PLAYER_HEALTH_BAR_ORIGIN :: rl.Vector2{11, 50}
PLAYER_HEALTH_BAR_WIDTH :: 47
PLAYER_HEALTH_BAR_HEIGHT :: 7

PLAYER_XP_BAR_ORIGIN :: rl.Vector2{11, 67}
PLAYER_XP_BAR_WIDTH :: 47
PLAYER_XP_BAR_HEIGHT :: 7

begin_button_hovering := false

draw_player_health_bar :: proc(player: ^Player) {
	heatlh_text := strings.clone_to_cstring(
		fmt.tprintf("%d HP", player.health),
		context.temp_allocator,
	)

	rl.DrawTextEx(tiny5_font, heatlh_text, {11, 56}, 9, 0, COLOR_RED)

	// 100%         player.max_health
	// x  %         player.current_health
	health_pct := f32(player.health) / f32(player.max_health)
	rl.DrawRectangleRec(
		{
			PLAYER_HEALTH_BAR_ORIGIN.x,
			PLAYER_HEALTH_BAR_ORIGIN.y,
			PLAYER_HEALTH_BAR_WIDTH,
			PLAYER_HEALTH_BAR_HEIGHT,
		},
		COLOR_DEEP_NIGHT,
	)
	rl.DrawRectangleLines(
		i32(PLAYER_HEALTH_BAR_ORIGIN.x),
		i32(PLAYER_HEALTH_BAR_ORIGIN.y),
		i32(PLAYER_HEALTH_BAR_WIDTH),
		PLAYER_HEALTH_BAR_HEIGHT,
		COLOR_TWILIGHT,
	)

	if player.health > 0 {
		rl.DrawRectangleRec(
			{
				PLAYER_HEALTH_BAR_ORIGIN.x,
				PLAYER_HEALTH_BAR_ORIGIN.y,
				PLAYER_HEALTH_BAR_WIDTH * health_pct,
				PLAYER_HEALTH_BAR_HEIGHT,
			},
			COLOR_DARK_RED,
		)
		// Left line
		rl.DrawRectangleLinesEx(
			{PLAYER_HEALTH_BAR_ORIGIN.x, PLAYER_HEALTH_BAR_ORIGIN.y, 1, PLAYER_HEALTH_BAR_HEIGHT},
			1,
			COLOR_RED,
		)
		// Top line
		rl.DrawRectangleLinesEx(
			{
				PLAYER_HEALTH_BAR_ORIGIN.x,
				PLAYER_HEALTH_BAR_ORIGIN.y,
				PLAYER_HEALTH_BAR_WIDTH * health_pct,
				1,
			},
			1,
			COLOR_RED,
		)
		rl.DrawRectangleLinesEx(
			{
				PLAYER_HEALTH_BAR_ORIGIN.x,
				PLAYER_HEALTH_BAR_ORIGIN.y + PLAYER_HEALTH_BAR_HEIGHT - 1,
				PLAYER_HEALTH_BAR_WIDTH * health_pct,
				1,
			},
			1,
			COLOR_RED,
		)
		if player.health >= player.max_health {
			rl.DrawRectangleLinesEx(
				{
					PLAYER_HEALTH_BAR_ORIGIN.x + PLAYER_HEALTH_BAR_WIDTH,
					PLAYER_HEALTH_BAR_ORIGIN.y,
					1,
					PLAYER_HEALTH_BAR_HEIGHT,
				},
				1,
				COLOR_RED,
			)
		}
	}
}

draw_player_xp_bar :: proc(player: ^Player) {
	xp_text := strings.clone_to_cstring(
		fmt.tprintf("%d XP", player.experience),
		context.temp_allocator,
	)

	rl.DrawTextEx(tiny5_font, xp_text, {11, PLAYER_XP_BAR_ORIGIN.y + 6}, 9, 0, COLOR_ECHO_HIGHLIGHT)

	rl.DrawTextEx(
		tiny5_font,
		strings.clone_to_cstring(fmt.tprintf("%3d", player.xp_level), context.temp_allocator),
		{51, PLAYER_XP_BAR_ORIGIN.y + 6},
		9,
		0,
		COLOR_ECHO_HIGHLIGHT,
	)

	// 100%         player.max_health
	// x  %         player.current_health
	xp_pct := f32(player.experience) / f32(player.required_xp)
	rl.DrawRectangleRec(
		{
			PLAYER_XP_BAR_ORIGIN.x,
			PLAYER_XP_BAR_ORIGIN.y,
			PLAYER_XP_BAR_WIDTH,
			PLAYER_XP_BAR_HEIGHT,
		},
		COLOR_DEEP_NIGHT,
	)
	rl.DrawRectangleLines(
		i32(PLAYER_XP_BAR_ORIGIN.x),
		i32(PLAYER_XP_BAR_ORIGIN.y),
		i32(PLAYER_XP_BAR_WIDTH),
		PLAYER_XP_BAR_HEIGHT,
		COLOR_TWILIGHT,
	)

	if player.experience > 0 {
		rl.DrawRectangleRec(
			{
				PLAYER_XP_BAR_ORIGIN.x,
				PLAYER_XP_BAR_ORIGIN.y,
				PLAYER_XP_BAR_WIDTH * xp_pct,
				PLAYER_XP_BAR_HEIGHT,
			},
			COLOR_ECHO_FG,
		)
		// Left line
		rl.DrawRectangleLinesEx(
			{PLAYER_XP_BAR_ORIGIN.x, PLAYER_XP_BAR_ORIGIN.y, 1, PLAYER_XP_BAR_HEIGHT},
			1,
			COLOR_ECHO_HIGHLIGHT,
		)
		// Top line
		rl.DrawRectangleLinesEx(
			{
				PLAYER_XP_BAR_ORIGIN.x,
				PLAYER_XP_BAR_ORIGIN.y,
				PLAYER_XP_BAR_WIDTH * xp_pct,
				1,
			},
			1,
			COLOR_ECHO_HIGHLIGHT,
		)
		rl.DrawRectangleLinesEx(
			{
				PLAYER_XP_BAR_ORIGIN.x,
				PLAYER_XP_BAR_ORIGIN.y + PLAYER_XP_BAR_HEIGHT - 1,
				PLAYER_XP_BAR_WIDTH * xp_pct,
				1,
			},
			1,
			COLOR_ECHO_HIGHLIGHT,
		)
		if player.experience >= player.required_xp {
			rl.DrawRectangleLinesEx(
				{
					PLAYER_XP_BAR_ORIGIN.x + PLAYER_XP_BAR_WIDTH,
					PLAYER_XP_BAR_ORIGIN.y,
					1,
					PLAYER_XP_BAR_HEIGHT,
				},
				1,
				COLOR_ECHO_HIGHLIGHT,
			)
		}
	}
}

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

	draw_player_health_bar(player)
	draw_player_xp_bar(player)
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
