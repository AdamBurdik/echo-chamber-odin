package game

import rl "vendor:raylib"

CardIcon :: enum {
	ANTI_CLOCKWISE,
	CLOCKWISE,
	ARROW,
	CURSE,
	HEART,
	PLUS,
	SPIKES,
	SWORD,
}

CardAction :: enum {
	MOVE,
	ROTATE,
}

CardActionValue :: struct {
	type: CardAction,
}

Card :: struct {
	type:        string,
	icon:        CardIcon,
	lines:       [dynamic]string,
	is_selected: bool,
	is_echo:     bool,
}

CardRect :: struct {
	rect: rl.Rectangle,
	card: Card,
}

get_icon_texture :: proc(icon: CardIcon) -> rl.Texture {
	switch icon {
	case CardIcon.ANTI_CLOCKWISE:
		return anti_clockwise_icon_texture
	case CardIcon.CLOCKWISE:
		return clockwise_icon_texture
	case CardIcon.ARROW:
		return arrow_icon_texture
	case CardIcon.CURSE:
		return curse_icon_texture
	case CardIcon.HEART:
		return heart_icon_texture
	case CardIcon.PLUS:
		return plus_icon_texture
	case CardIcon.SPIKES:
		return spikes_icon_texture
	case CardIcon.SWORD:
		return sword_icon_texture
	}

	panic("unhandled CardIcon type")
}
