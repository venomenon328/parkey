shader_type spatial;

// Original fine-grained laminated worktop, independent of the floor's photo maps.
// Workshop-local X follows the length of each counter after static batching.
varying vec3 local_position;
varying vec3 local_normal;

float grain_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float grain_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(grain_hash(cell), grain_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(grain_hash(cell + vec2(0.0, 1.0)), grain_hash(cell + vec2(1.0)), f.x), f.y);
}

void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 p = local_position;
	float strip = floor(p.z / 0.42);
	float drift = grain_noise(vec2(p.x * 0.45, strip * 3.7)) * 0.11;
	float broad = grain_noise(vec2(p.x * 0.3, (p.z + drift) * 14.0));
	float fine = grain_noise(vec2(p.x * 1.1, (p.z + drift) * 110.0));
	float fade = 1.0 - smoothstep(0.015, 0.08, max(fwidth(p.x), fwidth(p.z)));
	float fiber = smoothstep(0.32, 0.76, fine);
	float board_tone = grain_hash(vec2(strip, 0.0));
	float value = clamp(0.46 + broad * 0.24 + board_tone * 0.11 + (fiber - 0.5) * 0.11 * fade, 0.0, 1.0);
	ALBEDO = mix(vec3(0.34, 0.21, 0.10), vec3(0.72, 0.54, 0.33), value);
	// Fine continuous edge bands and pale dense fibers, no floor-plank joints.
	ALBEDO *= 1.0 - (1.0 - abs(local_normal.y)) * 0.07;
	ROUGHNESS = 0.49 + broad * 0.10 + fine * 0.025 * fade;
	SPECULAR = 0.32;
	vec3 n = normalize(local_normal);
	vec3 tangent = normalize(vec3(1.0, 0.0, 0.0) - n * n.x + vec3(0.0001, 0.0001, 0.0));
	vec3 across = normalize(cross(n, tangent));
	n = normalize(n + across * (fiber - 0.5) * 0.035 * fade);
	NORMAL = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(n, 0.0)).xyz);
	if (OUTPUT_IS_SRGB) {
		ALBEDO = 1.055 * pow(ALBEDO, vec3(1.0 / 2.4)) - 0.055;
	}
}
