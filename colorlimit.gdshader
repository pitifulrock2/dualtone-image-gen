shader_type canvas_item;
uniform int num_colors: hint_range(2,16) = 8;
uniform sampler2D PALETTE_TEXTURE: hint_default_black;

uniform float brightness : hint_range(0.5, 2.25) = 1.0;
uniform bool inverted = false;
uniform bool enabled = true;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

vec3 palette_limiter (in vec3 albedo){
	float estimation_cutoff = 0.001;
	vec3 closest_color;
	float min_dist = 2.0;
	float n = float(num_colors);

	for (int i=0; i<num_colors; i++ ){
		float index = 1.000/(2.000*n)+float(i)/n;
		vec3 index_color = texture(PALETTE_TEXTURE, vec2(index,0.5)).rgb;
		float dist = length(index_color - albedo);
		if (dist < min_dist) {
			min_dist = dist;
			closest_color = index_color;
			if (min_dist < estimation_cutoff){
				return closest_color;
			}
		}
	}
	return closest_color;
}

void fragment() {
	if(enabled == true) {
		COLOR.rgb = palette_limiter(texture(screen_texture, SCREEN_UV).rgb * brightness);
	}
	if(enabled == false) {
		COLOR.rgb = texture(screen_texture, SCREEN_UV).rgb * brightness;
	}
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
