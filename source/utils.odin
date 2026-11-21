// Wraps os.read_entire_file and os.write_entire_file, but they also work with emscripten.

package game

import rl "vendor:raylib"
import random "core:math/rand"

@(require_results)
read_entire_file :: proc(name: string, allocator := context.allocator, loc := #caller_location) -> (data: []byte, success: bool) {
	return _read_entire_file(name, allocator, loc)
}

write_entire_file :: proc(name: string, data: []byte, truncate := true) -> (success: bool) {
	return _write_entire_file(name, data, truncate)
}

random_color :: proc() -> rl.Color {
	return {
		u8(random.int32_range(0, 255)),
		u8(random.int32_range(0, 255)),
		u8(random.int32_range(0, 255)),
		255,
	}
}