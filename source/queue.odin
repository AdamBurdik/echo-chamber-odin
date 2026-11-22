package game

import "core:log"
import "core:strings"
import math "core:math"
import rl "vendor:raylib"

ACTION_QUEUE_WIDTH :: 65
ACTION_QUEUE_HEIGHT :: VIRTUAL_HEIGHT - 50
ACTION_QUEUE_ORIGIN := rl.Vector2{f32(math.round((VIRTUAL_WIDTH - ACTION_QUEUE_WIDTH) / 1.5)), 25}
ACTION_QUEUE_GAP :: 1

CARD_WIDTH :: 63
CARD_HEIGHT :: 20

Queue :: struct {
	stack:    [dynamic]Card,
	selected: [dynamic]Card,
}

get_card_rects :: proc(queue: ^Queue) -> []CardRect {
	all := make([]CardRect, len(queue.stack), context.temp_allocator)

	selected_amount := len(queue.selected)

	offset_y := ACTION_QUEUE_HEIGHT + ACTION_QUEUE_ORIGIN.y - CARD_HEIGHT
	offset_y -= f32(selected_amount * CARD_HEIGHT + selected_amount * ACTION_QUEUE_GAP)

	for card, i in queue.stack {
		x := ACTION_QUEUE_ORIGIN.x + (ACTION_QUEUE_WIDTH - CARD_WIDTH) / 2
		y : = offset_y

		all[i] = {{x, y, CARD_WIDTH, CARD_HEIGHT}, card}

		offset_y -= CARD_HEIGHT + ACTION_QUEUE_GAP
	}

	return all
}

get_selected_card_rects :: proc(queue: ^Queue) -> []CardRect {
	all := make([]CardRect, len(queue.selected), context.temp_allocator)

	offset_y := ACTION_QUEUE_HEIGHT + ACTION_QUEUE_ORIGIN.y - CARD_HEIGHT

	for card, i in queue.selected {
		x := ACTION_QUEUE_ORIGIN.x + (ACTION_QUEUE_WIDTH - CARD_WIDTH) / 2
		y := offset_y

		all[i] = {rl.Rectangle{x, y, CARD_WIDTH, CARD_HEIGHT}, card}

		offset_y -= CARD_HEIGHT + ACTION_QUEUE_GAP
	}

	return all
}

draw_card :: proc(rect: rl.Rectangle, card: Card) {
	color := rl.ORANGE
	if card.is_selected {
		color = rl.PINK
	}


	rl.DrawRectangle(i32(rect.x), i32(rect.y), i32(rect.width), i32(rect.height), color)

	text_offset_y := f32(0)
	for line in card.lines {
		rl.SetTextureFilter(tiny5_font.texture, rl.TextureFilter.POINT)
		rl.DrawTextEx(tiny5_font, strings.clone_to_cstring(line), {rect.x + 2, rect.y + text_offset_y}, 9, 0, rl.WHITE)

		text_offset_y += 10
	}
}

draw_queue :: proc(queue: ^Queue) {
	// Draw background
	rl.DrawRectangle(
		i32(ACTION_QUEUE_ORIGIN.x),
		i32(ACTION_QUEUE_ORIGIN.y),
		ACTION_QUEUE_WIDTH,
		ACTION_QUEUE_HEIGHT,
		rl.GRAY,
	)

	// Draw selected cards
	for card_rect in get_selected_card_rects(queue) {
		rect := card_rect.rect
		card := card_rect.card
		draw_card(rect, card)
	}

	// Draw not selected cards
	for card_rect in get_card_rects(queue) {
		rect := card_rect.rect
		card := card_rect.card
		draw_card(rect, card)
	}
}

handle_card_click :: proc(
	queue: ^Queue,
	i: int,
	rect: rl.Rectangle,
	card: ^Card,
	mouse_x: f32,
	mouse_y: f32,
) -> bool {
	if check_collision(rect, mouse_x, mouse_y) {
		if card.is_selected {
			card.is_selected = false
			ordered_remove(&queue.selected, i)
			inject_at(&queue.stack, 0, card^)
		} else {
			card.is_selected = true
			ordered_remove(&queue.stack, i)
			append(&queue.selected, card^)
		}
		return true
	}
	return false
}

update_queue :: proc(queue: ^Queue) {
	if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
		mouse_x := get_mouse_x()
		mouse_y := get_mouse_y()

		for card_rect, i in get_selected_card_rects(queue) {
			rect := card_rect.rect
			card := card_rect.card
			if handle_card_click(queue, i, rect, &card, mouse_x, mouse_y) {return}
		}

		for card_rect, i in get_card_rects(queue) {
			rect := card_rect.rect
			card := card_rect.card
			if handle_card_click(queue, i, rect, &card, mouse_x, mouse_y) {return}
		}
	}
}

add_card_to_action :: proc(queue: ^Queue, card: Card) {
	append(&queue.stack, card)
}
