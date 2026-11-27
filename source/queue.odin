package game

import "core:log"
import math "core:math"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

ACTION_QUEUE_WIDTH :: 71
ACTION_QUEUE_HEIGHT :: 203
ACTION_QUEUE_ORIGIN := rl.Vector2{316, 38}
ACTION_QUEUE_GAP :: 1

CARD_WIDTH :: 69
CARD_HEIGHT :: 18
CARD_BOTTOM_MARGIN :: 1 // Offset from bottom of action queue (so its not touching its bottom)

Queue :: struct {
	stack:    [dynamic]Card,
	selected: [dynamic]Card,
	echo:     [dynamic]Card,
}

get_card_rects :: proc(
	queue: ^Queue,
	working: [dynamic]Card,
	ignore_selected: bool = false,
) -> []CardRect {
	has_selected_cards := len(queue.selected) > 0

	all := make([]CardRect, len(working), context.temp_allocator)

	selected_amount := len(queue.selected)

	offset_y := ACTION_QUEUE_HEIGHT + ACTION_QUEUE_ORIGIN.y - CARD_HEIGHT - CARD_BOTTOM_MARGIN
	if !ignore_selected {
		offset_y -= f32(selected_amount * CARD_HEIGHT + selected_amount * ACTION_QUEUE_GAP)
		if has_selected_cards {
			offset_y -= 12
		}
	}

	for &card, i in working {
		x := ACTION_QUEUE_ORIGIN.x + (ACTION_QUEUE_WIDTH - CARD_WIDTH) / 2
		y := offset_y

		all[i] = {{x, y, CARD_WIDTH, CARD_HEIGHT}, &card}

		offset_y -= CARD_HEIGHT + ACTION_QUEUE_GAP
	}

	return all
}

get_selected_card_rects :: proc(queue: ^Queue) -> []CardRect {
	all := make([]CardRect, len(queue.selected), context.temp_allocator)

	offset_y := ACTION_QUEUE_HEIGHT + ACTION_QUEUE_ORIGIN.y - CARD_HEIGHT - CARD_BOTTOM_MARGIN

	for &card, i in queue.selected {
		x := ACTION_QUEUE_ORIGIN.x + (ACTION_QUEUE_WIDTH - CARD_WIDTH) / 2
		y := offset_y

		all[i] = {rl.Rectangle{x, y, CARD_WIDTH, CARD_HEIGHT}, &card}

		offset_y -= CARD_HEIGHT + ACTION_QUEUE_GAP
	}

	return all
}

draw_card :: proc(rect: rl.Rectangle, card: ^Card) {
	color := COLOR_DUST_PURPLE
	icon_color := COLOR_TERRACOTTA
	if card.is_echo {
		color = COLOR_ECHO_BG
		icon_color = COLOR_ECHO_HIGHLIGHT
	}

	icon_texture := get_icon_texture(card.icon)

	rl.DrawRectangle(i32(rect.x), i32(rect.y), i32(rect.width), i32(rect.height), color)
	if card.is_echo {
		// Draw echo borders

		top_left := rl.Vector2{rect.x + 1, rect.y}
		top_right := rl.Vector2{rect.x + rect.width, rect.y}
		bottom_left := rl.Vector2{rect.x, rect.y + rect.height - 1}
		bottom_right := rl.Vector2{rect.x + rect.width, rect.y + rect.height - 1}

		// top line
		rl.DrawLineEx(top_left, top_right, 1, COLOR_ECHO_FG)

		// left line
		rl.DrawLineEx(top_left, bottom_left, 1, COLOR_ECHO_FG)

		// bottom line
		rl.DrawLineEx(bottom_left, bottom_right, 1, COLOR_ECHO_HIGHLIGHT)

		// right line
		rl.DrawLineEx(top_right, bottom_right, 1, COLOR_ECHO_HIGHLIGHT)

		// Echo cooldown
		if card.echo_cooldown > 0 {
			buf: [32]u8
			s := strconv.write_int(buf[:], i64(card.echo_cooldown), 10)
			buf[len(s)] = 0
			cstr := cstring(&buf[0])

			text_size := rl.MeasureTextEx(tiny5_font, cstr, 9, 0)

			rl.DrawTextEx(
				tiny5_font,
				cstr,
				{bottom_right.x - text_size.x - 2, bottom_right.y - text_size.y},
				9,
				0,
				rl.WHITE,
			)
		}
	}

	rl.DrawTextureEx(
		icon_texture,
		{
			rect.x + rect.width - f32(icon_texture.width) - 4,
			rect.y + (rect.height - f32(icon_texture.height)) / 2 - 1,
		},
		0,
		1,
		icon_color,
	)

	text_offset_y := f32(0)
	for line in card.lines {
		// rl.SetTextureFilter(tiny5_font.texture, rl.TextureFilter.POINT)
		rl.DrawTextEx(
			tiny5_font,
			strings.clone_to_cstring(line),
			{rect.x + 2, rect.y + text_offset_y},
			9,
			0,
			COLOR_CHARTREUSE,
		)

		text_offset_y += 9
	}

	if card.is_hovered && !is_simulation_running {
		move_offset := math.min(0, math.max(-rect.width + 5, card.moved_distance))

		rl.DrawRectangleRec(
			{
				rect.x + rect.width - 5 + move_offset,
				rect.y,
				5,
				rect.height,
			},
			rl.ORANGE,
		)

		rl.DrawRectangleRec(
			{
				rect.x + rect.width + move_offset,
				rect.y,
				-move_offset,
				rect.height,
			},
			COLOR_RED,
		)
		// rl.DrawRectangle(
		// 	i32(rect.x),
		// 	i32(rect.y),
		// 	i32(rect.width),
		// 	i32(rect.height),
		// 	COLOR_CARD_HOVERED,
		// )
	}
}

draw_queue :: proc(queue: ^Queue) {
	// Draw selected cards
	last_card_rect: rl.Rectangle
	has_selected_cards := false

	for card_rect in get_selected_card_rects(queue) {
		rect := card_rect.rect
		card := card_rect.card
		draw_card(rect, card)
		last_card_rect = rect
		has_selected_cards = true
	}

	if has_selected_cards {
		text_size := rl.MeasureTextEx(tiny5_font, "Selected cards", 9, 0)

		rl.DrawTextEx(
			tiny5_font,
			"Selected cards",
			// Rounding cause it sometimes causes wierd font
			{
				last_card_rect.x + math.round((CARD_WIDTH - text_size.x) / 2),
				last_card_rect.y - CARD_HEIGHT / 1.65,
			},
			9,
			0,
			COLOR_ROSE,
		)
	}

	// Draw not selected cards
	for card_rect in get_card_rects(queue, queue.stack) {
		rect := card_rect.rect
		card := card_rect.card
		draw_card(rect, card)
	}

	// Overlay rectangle when it should be blocked
	if is_simulation_running {
		rl.DrawRectangle(
			i32(ACTION_QUEUE_ORIGIN.x),
			i32(ACTION_QUEUE_ORIGIN.y),
			ACTION_QUEUE_WIDTH,
			ACTION_QUEUE_HEIGHT,
			COLOR_BLOCKED_OVERLAY,
		)
	}

	// Draw echo queue
	for card_rect in get_card_rects(queue, queue.echo, true) {
		rect := card_rect.rect
		rect.x += 82
		card := card_rect.card
		draw_card(rect, card)
	}
}

handle_card_click :: proc(queue: ^Queue, card: ^Card) {
	moved := card^
	moved.is_hovered = false

	if moved.is_selected {
		moved.is_selected = false
		for _, i in queue.selected {
			if &queue.selected[i] == card {
				ordered_remove(&queue.selected, i)
				break
			}
		}
		inject_at(&queue.stack, 0, moved)
	} else {
		moved.is_selected = true
		for _, i in queue.stack {
			if &queue.stack[i] == card {
				ordered_remove(&queue.stack, i)
				break
			}
		}
		append(&queue.selected, moved)
	}
}

update_queue :: proc(queue: ^Queue) {
	mouse_x := get_mouse_x()
	mouse_y := get_mouse_y()

	for card_rect in get_selected_card_rects(queue) {
		rect := card_rect.rect
		card := card_rect.card

		if card.is_being_moved && rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
			card.moved_distance = mouse_x - card.mouse_pos.x
			return
		}

		if check_collision(rect, mouse_x, mouse_y) {
			card.is_hovered = true
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {

				if check_collision(
					{
						rect.x + rect.width - 5,
						rect.y,
						5,
						rect.height,
					},
					mouse_x,
					mouse_y,
				) {
					card.is_being_moved = true
					card.mouse_pos = {mouse_x, mouse_y}
					log.info("Starting move")
					return
				}


			}
			if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
				handle_card_click(queue, card)
				return
			}
		} else {
			card.is_hovered = false
			card.is_being_moved = false
		}
	}

	for card_rect in get_card_rects(queue, queue.stack) {
		rect := card_rect.rect
		card := card_rect.card

		if check_collision(rect, mouse_x, mouse_y) {
			card.is_hovered = true
			if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
				handle_card_click(queue, card)
				return
			}
		} else {
			card.is_hovered = false
		}
	}
}

add_card_to_action :: proc(queue: ^Queue, card: Card) {
	append(&queue.stack, card)
}
