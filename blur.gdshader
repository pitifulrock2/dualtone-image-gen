shader_type canvas_item;

uniform int strength: hint_range(1, 100) = 2;
uniform float scroll_speed = 1.0;

vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {

    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);

    vec2 pixel = fragCoord/pixelSize;
    int x_min = max(int(pixel.x-strengthFloat), 0);
    int x_max = min(int(pixel.x+strengthFloat), int(1./pixelSize.x));
    int y_min = max(int(pixel.y-strengthFloat), 0);
    int y_max = min(int(pixel.y+strengthFloat), int(1./pixelSize.y));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {
            color += texture(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }

    // Divide the color by the number of colors you summed up
    color /= float(count);

    return color;
}

void fragment() {
	vec2 uv = vec2(UV.x*2.0, UV.y*2.0);

    // Calculate the scrolled UV position
    float scrolled_v = mod(uv.y - TIME * scroll_speed, 1.0);
	float scrolled_h = mod(uv.x - TIME * scroll_speed, 1.0);

    // If the UV is beyond the visible range, wrap it around to the top
    if (scrolled_v < 0.0) {
        scrolled_v += 1.0;
    }
	if (scrolled_h < 0.0) {
        scrolled_h += 1.0;
    }

    COLOR = blur_size(TEXTURE,vec2(scrolled_h, scrolled_v),TEXTURE_PIXEL_SIZE);
	COLOR.a = 0.1;
}