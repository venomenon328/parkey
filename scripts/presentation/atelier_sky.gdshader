shader_type sky;

// The floating atelier sees below the astronomical horizon. Lift the sampled
// cloud hemisphere without rotating a diagonal horizon through the composition.
uniform sampler2D panorama : source_color, filter_linear_mipmap, repeat_enable;
uniform float energy = 0.55;
uniform float horizon_lift = 0.65;
uniform bool srgb_output = false;

void sky() {
	vec3 direction = normalize(vec3(EYEDIR.x, EYEDIR.y + horizon_lift, EYEDIR.z));
	vec2 uv = vec2(atan(direction.x, direction.z) / TAU + 0.5, acos(clamp(direction.y, -1.0, 1.0)) / PI);
	vec3 radiance = max(texture(panorama, uv).rgb * energy, vec3(0.0));
	// The Compatibility sky writes to an LDR target; the HDR source is linear.
	COLOR = srgb_output ? mix(radiance * 12.92, 1.055 * pow(radiance, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), radiance)) : radiance;
}
