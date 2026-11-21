package game

import "base:runtime"
import rl "vendor:raylib"
import "core:log"
import "core:fmt"
import "core:strings"

Load_Directory_File :: runtime.Load_Directory_File

ASSETS_ROOT: []Load_Directory_File = #load_directory("../assets")
ASSETS_TILES := #load_directory("../assets/tiles")
ASSETS_IDLE_PLAYER := #load_directory("../assets/player/idle")

asset_map: map[string][]byte

run: bool
round_cat_texture: rl.Texture
long_cat_texture: rl.Texture
empty_tile_texture: rl.Texture
player_idle: DirectionalEntity
backdrop_texture: rl.Texture


DirectionalEntity :: struct {
	front: rl.Texture,
	back: rl.Texture,
	left: rl.Texture,
	right: rl.Texture,
}

add_assets :: proc(folder: string, files: []Load_Directory_File) {
	for file in files {
		key := fmt.aprintf("%s/%s", folder, file.name)
		asset_map[key] = file.data
	}
}

init_assets :: proc() {
	add_assets("root", ASSETS_ROOT)
	add_assets("tiles", ASSETS_TILES)
	add_assets("player_idle", ASSETS_IDLE_PLAYER)
}

load_assets :: proc() {
	empty_tile_texture = load_texture("tiles/empty.png")
	player_idle = load_directional_entity("player_idle")
	backdrop_texture = load_texture("root/backdrop.png")
}

// load_texture :: proc(bytes: []u8) -> rl.Texture {
// 	img := rl.LoadImageFromMemory(".png", raw_data(bytes), i32(len(bytes)))
// 	texture := rl.LoadTextureFromImage(img)
// 	rl.UnloadImage(img)
// 	return texture
// }

load_texture :: proc(name: string) -> rl.Texture {
	data := get_asset_data(name)
	img := rl.LoadImageFromMemory(".png", raw_data(data), i32(len(data)))
	texture := rl.LoadTextureFromImage(img)
	rl.UnloadImage(img)
	return texture
}

load_directional_entity :: proc(name: string) -> DirectionalEntity {
	return DirectionalEntity{
		load_texture(strings.concatenate({name, "/front.png"})),
		load_texture(strings.concatenate({name, "/back.png"})),
		load_texture(strings.concatenate({name, "/left.png"})),
		load_texture(strings.concatenate({name, "/right.png"})),
	}
}

get_asset_data :: proc(name: string) -> []u8 {
	return asset_map[name]
}
