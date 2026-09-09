class_name RenderProfile
extends RefCounted

## The label is diagnostic only. Export settings remain the authoritative
## renderer selection; the runtime method is shown to make deviations visible.

static func expected_profile() -> String:
	if OS.has_feature("web"):
		return "Web / Compatibility"
	return "Windows / Forward+"


static func current_method() -> String:
	return RenderingServer.get_current_rendering_method()


static func quality_enabled() -> bool:
	return not OS.has_feature("web") and current_method() == "forward_plus"


static func settings_for_method(method: String) -> Dictionary:
	var quality := method == "forward_plus"
	return {"ssao": quality, "shadows": quality, "glow": false, "msaa_samples": 4 if quality else 0}
