shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform vec2 scroll1 = vec2(0.05, 0.0);
uniform vec2 scroll2 = vec2(-0.03, 0.0);
uniform float distortion_strength : hint_range(-1, 1) = 0.2;
uniform vec4 tone_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 top_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float light_start : hint_range(0.0, 1.0) = 0.275;
uniform float light_end : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // scroll two noise textures
    float depth1 = texture(noise1, UV + scroll1 * TIME).r;
    float depth2 = texture(noise2, UV + scroll2 * TIME).r;
    float depth = depth1 * depth2;

    // distort the screen texture with depth
    vec4 screen_col = texture(SCREEN_TEXTURE,
        SCREEN_UV + distortion_strength * vec2(depth));

    // add shimmer/highlight
    float light_mask = smoothstep(light_start, light_end, depth);
    vec4 top_light = light_mask * top_color;

    // final color
    COLOR = screen_col * tone_color + top_light;
    COLOR.a = 1.0;
}
