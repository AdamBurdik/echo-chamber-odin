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
    type: string,
    icon: CardIcon,
    lines: [dynamic]string,
    is_selected: bool,
    is_echo: bool,
}

CardRect :: struct {
    rect: rl.Rectangle,
    card: Card,
}