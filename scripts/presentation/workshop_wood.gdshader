shader_type spatial;

uniform sampler2D wood_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D wood_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D wood_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool floor_planks = false;
uniform bool grain_along_z = false;
varying vec3 object_position;
varying vec3 object_normal;

void vertex() {
	object_position = VERTEX;
	object_normal = NORMAL;
}

void fragment() {
	vec3 weights = pow(abs(object_normal), vec3(8.0));
	weights /= max(dot(weights, vec3(1.0)), 0.001);
	vec3 p = object_position * 0.3;
	// Source grain follows V. Rotate all channels together along the boards (X).
	vec2 uv_x = p.zy;
	vec2 uv_y = grain_along_z ? p.xz : vec2(p.z, -p.x);
	vec2 uv_z = vec2(p.y, -p.x);
	vec3 color = texture(wood_color, uv_x).rgb * weights.x + texture(wood_color, uv_y).rgb * weights.y + texture(wood_color, uv_z).rgb * weights.z;
	if (OUTPUT_IS_SRGB) {
		color = mix(color / 12.92, pow((color + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
	}
	// Keep the photographed grain, with the atelier's restrained honey finish.
	float grain = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float value = smoothstep(0.003, 0.055, grain);
	ALBEDO = mix(vec3(0.16, 0.082, 0.033), vec3(0.42, 0.275, 0.14), value);
	float roughness = texture(wood_roughness, uv_x).r * weights.x + texture(wood_roughness, uv_y).r * weights.y + texture(wood_roughness, uv_z).r * weights.z;
	ROUGHNESS = 0.53 + roughness * 0.26;
	SPECULAR = 0.35;
	vec3 nx = texture(wood_normal, uv_x).rgb * 2.0 - 1.0;
	vec3 ny = texture(wood_normal, uv_y).rgb * 2.0 - 1.0;
	vec3 nz = texture(wood_normal, uv_z).rgb * 2.0 - 1.0;
	vec3 n = vec3(nx.z * sign(object_normal.x), nx.y, nx.x) * weights.x;
	n += (grain_along_z ? vec3(ny.x, ny.z * sign(object_normal.y), ny.y) : vec3(-ny.y, ny.z * sign(object_normal.y), ny.x)) * weights.y;
	n += vec3(-nz.y, nz.x, nz.z * sign(object_normal.z)) * weights.z;
	n = normalize(mix(object_normal, n, 0.28));
	NORMAL = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(n, 0.0)).xyz);
	if (floor_planks) {
		vec2 board = vec2(object_position.x / 6.0 + floor(object_position.z / 0.9) * 0.37, object_position.z / 0.9);
		vec2 edge = min(fract(board), 1.0 - fract(board));
		vec2 aa = max(fwidth(board), vec2(0.0001));
		float seam = min(smoothstep(0.002, 0.002 + aa.x, edge.x), smoothstep(0.008, 0.008 + aa.y, edge.y));
		ALBEDO *= mix(0.43, 0.90 + sin(floor(board.y) * 4.7) * 0.06, seam);
		ROUGHNESS = 0.78;
	}
	if (OUTPUT_IS_SRGB) {
		ALBEDO = 1.055 * pow(ALBEDO, vec3(1.0 / 2.4)) - 0.055;
	}
}
