package game

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:strings"
import rl "vendor:raylib"

Load_Directory_File :: runtime.Load_Directory_File

ASSETS_ROOT: []Load_Directory_File = #load_directory("../assets")
ASSETS_TILES := #load_directory("../assets/tiles")
ASSETS_IDLE_PLAYER := #load_directory("../assets/player/idle")
ASSETS_FONTS := #load_directory("../assets/fonts")
ASSETS_ICONS := #load_directory("../assets/icons")

ASSETS_IDLE_GOBLIN := #load_directory("../assets/goblin/idle")
ASSETS_IDLE_CULTIST := #load_directory("../assets/cultist/idle")
ASSETS_SUMMON_CULTIST := #load_directory("../assets/cultist/summon")
ASSETS_FULL_IDLE_SLIME := #load_directory("../assets/slime/full/idle")
ASSETS_HALF_IDLE_SLIME := #load_directory("../assets/slime/full/idle")
ASSETS_QUARTER_IDLE_SLIME := #load_directory("../assets/slime/full/idle")

// Color pallete
COLOR_VOID :: rl.Color{13, 12, 21, 255}
COLOR_DEEP_NIGHT :: rl.Color{33, 29, 56, 255}
COLOR_TWILIGHT :: rl.Color{46, 42, 79, 255}
COLOR_SHADOW :: rl.Color{59, 64, 94, 255}
COLOR_DUST_PURPLE :: rl.Color{96, 85, 110, 255}
COLOR_ROSE :: rl.Color{154, 92, 120, 255}
COLOR_TERRACOTTA :: rl.Color{199, 120, 111, 255}
COLOR_PEACH :: rl.Color{207, 169, 138, 255}
COLOR_CHARTREUSE :: rl.Color{205, 212, 165, 255}

COLOR_ECHO_BG :: rl.Color{40, 118, 153, 255}
COLOR_ECHO_FG :: rl.Color{0, 152, 219, 255}
COLOR_ECHO_HIGHLIGHT :: rl.Color{12, 230, 242, 255}

COLOR_HOVERED :: rl.Color{207, 169, 138, 25}
COLOR_CARD_HOVERED :: rl.Color{96, 85, 110, 50}

COLOR_BLOCKED_OVERLAY :: rl.Color{0, 0, 0, 50}

asset_map: map[string][]byte

run: bool // Why is run defined here?
round_cat_texture: rl.Texture
long_cat_texture: rl.Texture
empty_tile_texture: rl.Texture
player_idle: DirectionalEntity
backdrop_texture: rl.Texture

// Icons
anti_clockwise_icon_texture: rl.Texture
clockwise_icon_texture: rl.Texture
arrow_icon_texture: rl.Texture
curse_icon_texture: rl.Texture
heart_icon_texture: rl.Texture
plus_icon_texture: rl.Texture
spikes_icon_texture: rl.Texture
sword_icon_texture: rl.Texture

// Fonts
tiny5_font: rl.Font
m3x6_font: rl.Font

// Enemies
goblin_idle: DirectionalEntity
cultist_idle: DirectionalEntity
slime_full: DirectionalEntity
slime_half: DirectionalEntity
slime_quarter: DirectionalEntity


DirectionalEntity :: struct {
	front: rl.Texture,
	back:  rl.Texture,
	left:  rl.Texture,
	right: rl.Texture,
}

get_texture_from_directional_entity :: proc(
	entity: ^DirectionalEntity,
	direction: CardinalDirection,
) -> rl.Texture {
	switch direction {
	case .UP:
		return entity.back
	case .DOWN:
		return entity.front
	case .RIGHT:
		return entity.right
	case .LEFT:
		return entity.left
	}
	panic("Unhandleded CardinalDirection case")
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
	add_assets("fonts", ASSETS_FONTS)
	add_assets("icons", ASSETS_ICONS)

	add_assets("goblin_idle", ASSETS_IDLE_GOBLIN)
	add_assets("cultist_idle", ASSETS_IDLE_CULTIST)
	add_assets("slime_full_idle", ASSETS_FULL_IDLE_SLIME)
	add_assets("slime_half_idle", ASSETS_HALF_IDLE_SLIME)
	add_assets("slime_quarter_idle", ASSETS_QUARTER_IDLE_SLIME)
}

load_assets :: proc() {
	empty_tile_texture = load_texture("tiles/empty.png")
	player_idle = load_directional_entity("player_idle")
	backdrop_texture = load_texture("root/backdrop.png")
	// tiny5_font = load_font("fonts/tiny5.ttf", 32)
	// m3x6_font = load_font("fonts/m3x6_font.ttf", 32)
	// TODO: Load fonts from bundled directory somehow idk
	tiny5_font = rl.LoadFontEx("./assets/fonts/Tiny5-Regular.ttf", 9, nil, 0)
	rl.SetTextureFilter(tiny5_font.texture, rl.TextureFilter.POINT)
	m3x6_font = rl.LoadFont("./assets/fonts/m3x6.ttf")

	if tiny5_font.texture.id == 0 {
		log.error("Failed to load tiny5_font!")
	}

	anti_clockwise_icon_texture = load_texture("icons/anti_clockwise.png")
	clockwise_icon_texture = load_texture("icons/clockwise.png")
	arrow_icon_texture = load_texture("icons/arrow.png")
	curse_icon_texture = load_texture("icons/curse.png")
	heart_icon_texture = load_texture("icons/heart.png")
	plus_icon_texture = load_texture("icons/plus.png")
	spikes_icon_texture = load_texture("icons/spikes.png")
	sword_icon_texture = load_texture("icons/sword.png")

	goblin_idle = load_directional_entity("goblin_idle")
	cultist_idle = load_directional_entity("cultist_idle")
	slime_full = load_directional_entity("slime_full_idle")
	slime_half = load_directional_entity("slime_half_idle")
	slime_quarter = load_directional_entity("slime_quarter_idle")

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
	return DirectionalEntity {
		load_texture(strings.concatenate({name, "/front.png"})),
		load_texture(strings.concatenate({name, "/back.png"})),
		load_texture(strings.concatenate({name, "/left.png"})),
		load_texture(strings.concatenate({name, "/right.png"})),
	}
}

load_font :: proc(name: string, font_size: i32) -> rl.Font {
	data := get_asset_data(name)
	return rl.LoadFontFromMemory(".ttf", raw_data(data), i32(len(data)), font_size, nil, 0)
}

get_asset_data :: proc(name: string) -> []u8 {
	return asset_map[name]
}
