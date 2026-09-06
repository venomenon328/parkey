shader_type spatial;

void fragment() {
	vec2 p = UV * vec2(30.0, 100.0);
	float weave = sin(p.x * TAU * 6.0) * sin(p.y * TAU * 6.0);
	float fade = 1.0 - smoothstep(0.025, 0.13, max(fwidth(p.x), fwidth(p.y)));
	// Fine woven rubber, with antialiasing that fades subpixel detail in the distance.
	ALBEDO = vec3(0.041, 0.097, 0.083) * (1.0 + weave * 0.10 * fade);
	if (OUTPUT_IS_SRGB) {
		ALBEDO = 1.055 * pow(ALBEDO, vec3(1.0 / 2.4)) - 0.055;
	}
	ROUGHNESS = 0.83 + weave * 0.025 * fade;
	SPECULAR = 0.24;
	NORMAL_MAP = normalize(vec3(cos(p.x * TAU * 6.0), cos(p.y * TAU * 6.0), 14.0)) * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 0.24 * fade;
}
