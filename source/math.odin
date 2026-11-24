package game

import math "core:math"
import rl "vendor:raylib"

CardinalDirection :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

get_direction_vector :: proc(direction: CardinalDirection) -> rl.Vector2 {
	switch (direction) {
	case CardinalDirection.UP:
		return {0, -1}
	case CardinalDirection.DOWN:
		return {0, 1}
	case CardinalDirection.LEFT:
		return {-1, 0}
	case CardinalDirection.RIGHT:
		return {1, 0}
	}
	return {0, 0}
}

get_rotated_direction :: proc(
	direction: CardinalDirection,
	anti_clockwise: bool,
) -> CardinalDirection {
	if !anti_clockwise {
		switch (direction) {
		case .UP:
			return .RIGHT
		case .RIGHT:
			return .DOWN
		case .DOWN:
			return .LEFT
		case .LEFT:
			return .UP
		}
	} else {
		switch (direction) {
		case .UP:
			return .LEFT
		case .LEFT:
			return .DOWN
		case .DOWN:
			return .RIGHT
		case .RIGHT:
			return .UP
		}
	}
	panic("unhandled CardinalDirection rotated case")
}

check_collision_rect_point :: proc(rect: rl.Rectangle, point: rl.Vector2) -> bool {
	return check_collision_rect_xy(rect, point.x, point.y)
}

check_collision_rect_xy :: proc(rect: rl.Rectangle, x: f32, y: f32) -> bool {
	return x >= rect.x && x <= rect.x + rect.width && y >= rect.y && y <= rect.y + rect.height
}

check_collision :: proc {
	check_collision_rect_point,
	check_collision_rect_xy,
}

get_mouse_x :: proc() -> f32 {
	return f32(rl.GetMouseX() / (rl.GetScreenWidth() / VIRTUAL_WIDTH))
}

get_mouse_y :: proc() -> f32 {
	return f32(rl.GetMouseY() / (rl.GetScreenHeight() / VIRTUAL_HEIGHT))
}

ease_in_out_cubic :: proc(t: f32) -> f32 {
	if t < 0.5 {
		return 4 * t * t * t
	}
	return 1 - math.pow(-2 * t + 2, 3) / 2
}
