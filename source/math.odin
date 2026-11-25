package game

import "core:log"
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
	panic("unhandled CardinalDirection rotated case")
}

get_direction_rotation :: proc(direction: CardinalDirection) -> f32 {
	switch (direction) {
	case CardinalDirection.UP:
		return 0
	case CardinalDirection.DOWN:
		return 180
	case CardinalDirection.LEFT:
		return 270
	case CardinalDirection.RIGHT:
		return 90
	}
	panic("unhandled CardinalDirection rotated case")
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

get_direction_between :: proc(from, to: Coord) -> CardinalDirection {
	delta_x := to.x - from.x
	delta_y := to.y - from.y

	for direction in CardinalDirection {
		vec := get_direction_vector(direction)
		if i32(vec.x) == delta_x && i32(vec.y) == delta_y {
			return direction
		}
	}

	log.panicf("Coords are not adjacent: from=%v to=%v", from, to)
}

// Converts value from 0 to 1 to specified range
map_range :: proc(t: f32, min: f32, max: f32) -> f32 {
	return min + (t) * (max - min)
}
