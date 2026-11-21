#version 330

uniform sampler2D u_game;
uniform sampler2D u_overlay;
uniform sampler2D u_text_above;
uniform sampler2D u_text_behind;
uniform sampler2D u_hud;
uniform sampler2D u_backdrop;

uniform vec2 u_low_res;
uniform vec2 u_shake;
uniform float u_time;
uniform float u_intensity;
uniform float u_backdrop_speed;

uniform vec4 u_hp_rect;
uniform vec4 u_xp_rect;
uniform float u_hp;
uniform float u_xp;

uniform float u_hp_wave_speed;
uniform float u_hp_wave_amplitude;
uniform float u_xp_wave_speed;
uniform float u_xp_wave_amplitude;
uniform float u_hud_edge_width;

in vec2 uv;
out vec4 f_color;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float rect_mask(vec2 p, vec4 rect) {
    return step(rect.x, p.x) * step(p.x, rect.x + rect.z - 1.0) *
           step(rect.y, p.y) * step(p.y, rect.y + rect.w - 1.0);
}

vec3 apply_hud(vec3 color, vec2 p, float t) {
    vec4 hp_outer = u_hp_rect;
    vec4 hp_inner = vec4(hp_outer.x + 1.0, hp_outer.y + 1.0,
                         hp_outer.z - 2.0, hp_outer.w - 2.0);
    float hp_pct = clamp(u_hp, 0.0, 1.0);
    float hp_amp = smoothstep(0.0, 0.12, hp_pct);
    float hp_fill_x = hp_inner.x + hp_inner.z * hp_pct;
    hp_fill_x += (sin((p.y - hp_inner.y) * 0.55 + t * u_hp_wave_speed) * 1.6
                + sin((p.y - hp_inner.y) * 0.21 - t * u_hp_wave_speed * 0.61) * 1.0)
                * hp_amp * u_hp_wave_amplitude;
    hp_fill_x = clamp(hp_fill_x, hp_inner.x, hp_inner.x + hp_inner.z);

    vec4 xp_outer = u_xp_rect;
    vec4 xp_inner = vec4(xp_outer.x + 1.0, xp_outer.y + 1.0,
                         xp_outer.z - 2.0, xp_outer.w - 2.0);
    float xp_pct = clamp(u_xp, 0.0, 1.0);
    float xp_amp = u_xp_wave_amplitude * smoothstep(0.0, 0.12, xp_pct);
    float xp_speed = u_xp_wave_speed;
    float xp_fill_x = xp_inner.x + xp_inner.z * xp_pct;
    xp_fill_x += (sin((p.y - xp_inner.y) * 0.65 + t * xp_speed) * 1.5
                + sin((p.y - xp_inner.y) * 1.85 - t * (xp_speed * 1.45)) * 0.9) * xp_amp;
    xp_fill_x = clamp(xp_fill_x, xp_inner.x, xp_inner.x + xp_inner.z);

    vec3 hp_border = vec3(18.0, 16.0, 32.0) / 255.0;
    vec3 hp_bg = vec3(46.0, 42.0, 79.0) / 255.0;
    vec3 hp_fill = vec3(0.612, 0.090, 0.231);

    vec3 xp_border = vec3(18.0, 16.0, 32.0) / 255.0;
    vec3 xp_bg = vec3(46.0, 42.0, 79.0) / 255.0;
    vec3 xp_fill = vec3(12.0, 230.0, 242.0) / 255.0;

    if (rect_mask(p, hp_outer) > 0.5) {
        color = hp_border;

        if (rect_mask(p, hp_inner) > 0.5) {
            color = hp_bg;

            if (p.x < hp_fill_x) {
                color = hp_fill;

                float hp_edge = hp_fill_x - p.x;
                if (hp_edge < u_hud_edge_width * 0.5) {
                    color = vec3(0.780, 0.141, 0.302);
                } else if (hp_edge < u_hud_edge_width) {
                    color = vec3(0.420, 0.055, 0.150);
                }
            }
        }
    }

    if (rect_mask(p, xp_outer) > 0.5) {
        color = xp_border;

        if (rect_mask(p, xp_inner) > 0.5) {
            color = xp_bg;

            if (p.x < xp_fill_x) {
                color = xp_fill;

                float xp_edge = xp_fill_x - p.x;
                if (xp_edge < u_hud_edge_width * 0.5) {
                    color = vec3(0.45, 0.95, 1.00);
                } else if (xp_edge < u_hud_edge_width) {
                    color = vec3(0.0, 152.0, 219.0) / 255.0;
                }
            }
        }
    }

    return color;
}

void main() {
    vec2 shake_uv = clamp(uv + u_shake, 0.0, 1.0);
    vec3 color = texture(u_game, shake_uv).bgra.rgb;

    vec4 text_behind = texture(u_text_behind, shake_uv).bgra;
    color = mix(color, text_behind.rgb, text_behind.a);

    vec4 hud = texture(u_hud, uv).bgra;
    color = mix(color, hud.rgb, hud.a);

    vec2 low_px = floor(uv * u_low_res);
    vec2 low_uv = (low_px + 0.5) / u_low_res;

    vec2 texel = 1.0 / u_low_res;
    float a_l = texture(u_backdrop, low_uv - vec2(texel.x, 0.0)).bgra.a;
    float a_r = texture(u_backdrop, low_uv + vec2(texel.x, 0.0)).bgra.a;
    float a_d = texture(u_backdrop, low_uv - vec2(0.0, texel.y)).bgra.a;
    float a_u = texture(u_backdrop, low_uv + vec2(0.0, texel.y)).bgra.a;
    float edge = clamp(abs(a_r - a_l) + abs(a_u - a_d), 0.0, 1.0);

    float t = u_time;
    color = apply_hud(color, low_px, t);

    float anim_t = t * u_backdrop_speed;
    vec2 drift = vec2(sin(anim_t * 0.35 + low_uv.y * 6.0),
                      cos(anim_t * 0.31 - low_uv.x * 5.0));
    vec2 ripple = vec2(sin(low_uv.y * 26.0 + anim_t * 1.7),
                       cos(low_uv.x * 23.0 - anim_t * 1.4));
    vec2 offset_px = (drift * 0.6 + ripple * 1.2) * (0.15 + edge) * u_intensity;

    vec2 offset = floor(offset_px + 0.5) / u_low_res;
    vec4 backdrop = texture(u_backdrop, clamp(low_uv + offset, 0.0, 1.0)).bgra;

    float n = noise(low_uv * 9.0 + vec2(anim_t * 0.12, -anim_t * 0.09));
    vec3 tinted = backdrop.rgb + vec3(0.02, 0.015, 0.03) * edge * (0.5 + 0.5 * n);
    color = mix(color, tinted, backdrop.a);

    vec4 overlay = texture(u_overlay, uv).bgra;
    color = mix(color, overlay.rgb, overlay.a);

    vec4 text_above = texture(u_text_above, shake_uv).bgra;
    color = mix(color, text_above.rgb, text_above.a);

    f_color = vec4(color, 1.0);
}
