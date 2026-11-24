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

CardActionType :: enum {
	MOVE,
	ROTATE,
	INSTANT_HEAL,
	REGEN,
}

ActionMove :: struct {
	distance: i32,
}

ActionInstantHeal :: struct {
	amount: i32,
}

ActionRegen :: struct {
	amount:  i32,
	seconds: i32,
}

ActionRotate :: struct {
	anti_clockwise: bool,
}

CardAction :: union {
	ActionMove,
	ActionInstantHeal,
	ActionRegen,
	ActionRotate,
}

Card :: struct {
	icon:          CardIcon,
	lines:         [dynamic]string,
	actions:       [dynamic]CardAction,
	is_selected:   bool,
	is_echo:       bool,
	is_hovered:    bool,
	echo_cooldown: i32,
}

CardRect :: struct {
	rect: rl.Rectangle,
	card: ^Card,
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
