package game

import "core:slice"
import "core:strings"
import rl "vendor:raylib"

RendererPipeline :: struct {
	calls: [dynamic]RendererCall,
}

renderer_pipeline := RendererPipeline{}

TextureCall :: struct {
	texture: rl.Texture,
	color:   rl.Color,
}

RectangleCall :: struct {
	color:  rl.Color,
	width:  f32,
	height: f32,
}

TextCall :: struct {
	text:      string,
	font_size: i32,
	color:     rl.Color,
}

RendererCall :: struct {
	x, y:       f32,
	z_layer:    i32,
	is_virtual: bool,
	data:       union {
		TextureCall,
		RectangleCall,
		TextCall,
	},
}

render :: proc(call: RendererCall) {
	append(&renderer_pipeline.calls, call)
}

draw_virtual_texture :: proc(texture: rl.Texture, x: f32, y: f32) {
	render({x, y, 1, true, {texture, rl.WHITE}})
}

draw_virtual_rectangle :: proc(x: f32, y: f32, width: f32, height: f32, color: rl.Color) {
	render({x, y, 1, true, {color, width, height}})
}

draw_text :: proc(x: f32, y: f32, text: string, font_size: i32, color: rl.Color) {
    render({x, y, 1, true, {text, font_size, color}}) // Set is_virtual to true
}

draw_virtual_text :: proc(x: f32, y: f32, text: string, font_size: i32, color: rl.Color) {
	render({x, y, 1, true, {text, font_size, color}})
}

by_z_layer :: proc(a, b: RendererCall) -> bool {
	return a.z_layer < b.z_layer
}

draw_renderer :: proc() {
	scale_x := f32(rl.GetScreenWidth()) / f32(VIRTUAL_WIDTH)
	scale_y := f32(rl.GetScreenHeight()) / f32(VIRTUAL_HEIGHT)

	calls := renderer_pipeline.calls
	slice.sort_by(calls[:], by_z_layer)

	for call in calls {
		x := call.x
		y := call.y

		if call.is_virtual {
			x *= scale_x
			y *= scale_y
		}

		switch data in call.data {
		case RectangleCall:
			width := data.width
			height := data.height

			if call.is_virtual {
				width *= scale_x
				height *= scale_y
			}

			rl.DrawRectangle(i32(x), i32(y), i32(width), i32(height), data.color)

		case TextureCall:
			texture_width := f32(data.texture.width)
			texture_height := f32(data.texture.height)

			if call.is_virtual {
				texture_width *= scale_x
				texture_height *= scale_y
			}

			rl.DrawTexturePro(
				data.texture,
				{0, 0, f32(data.texture.width), f32(data.texture.height)},
				{x, y, texture_width, texture_height},
				{0, 0},
				0,
				data.color,
			)

		case TextCall:
			// Font size stays exactly what you passed, unscaled by scale_y
			font_size := f32(data.font_size)

			text_cstr, err := strings.clone_to_cstring(data.text, context.temp_allocator)
			if err != nil {
				continue
			}

			rl.DrawTextEx(
				rl.GetFontDefault(),
				text_cstr,
				{x, y}, // Uses the already-scaled virtual x and y coordinates
				font_size,
				1,
				data.color,
			)
		}
	}
}
