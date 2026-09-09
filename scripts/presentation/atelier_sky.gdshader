shader_type sky;

// The floating atelier sees below the astronomical horizon. Lift the sampled
// cloud hemisphere without rotating a diagonal horizon through the composition.
uniform sampler2D panorama : source_color, filter_linear_mipmap, repeat_enable;
uniform float energy = 0.72;
uniform float horizon_lift = 0.45;
uniform bool srgb_output = false;

void sky() {
	vec3 direction = normalize(vec3(EYEDIR.x, EYEDIR.y + horizon_lift, EYEDIR.z));
	vec2 uv = vec2(atan(direction.x, direction.z) / TAU + 0.5, acos(clamp(direction.y, -1.0, 1.0)) / PI);
	vec3 radiance = max(texture(panorama, uv).rgb * energy, vec3(0.0));
	// Shift clear sky toward a softer cyan while preserving neutral cloud light.
	float clear_sky = smoothstep(0.05, 0.45, (radiance.b - radiance.r) / max(radiance.b, 0.001));
	radiance *= mix(vec3(1.0), vec3(0.82, 1.45, 1.05), clear_sky);
	// The Compatibility sky writes to an LDR target; the HDR source is linear.
	COLOR = srgb_output ? mix(radiance * 12.92, 1.055 * pow(radiance, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), radiance)) : radiance;
}
