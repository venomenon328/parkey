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
