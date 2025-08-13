shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// 0.0 = normal, 1.0 = fully mirrored
uniform float flip_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    // Interpolate between normal UV.x and flipped UV.x
    float flipped_x = 1.0 - uv.x;
    uv.x = mix(uv.x, flipped_x, flip_amount);

    COLOR = texture(SCREEN_TEXTURE, uv);
}
