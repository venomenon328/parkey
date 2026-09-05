class_name KeyInputNormalizer
extends RefCounted

## Normalizes actual key events by their generated Unicode character, never by
## their physical position. This keeps visible A-Z labels independent of QWERTZ
## or QWERTY layouts. Run rules are deliberately not part of this P0 adapter.

static func normalize(event: InputEvent) -> Dictionary:
	if not event is InputEventKey:
		return {}

	var key_event := event as InputEventKey
	var common := {
		"unicode": key_event.unicode,
		"keycode": key_event.keycode,
		"physical_keycode": key_event.physical_keycode,
		"shift": key_event.shift_pressed,
	}

	if not key_event.pressed:
		return common.merged(_result(false, "", "key_up"))
	if key_event.echo:
		return common.merged(_result(false, "", "echo"))
	if key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed:
		return common.merged(_result(false, "", "shortcut_modifier"))
	if not _is_latin_letter(key_event.unicode):
		return common.merged(_result(false, "", "not_a_to_z"))

	return common.merged(_result(true, char(key_event.unicode).to_upper(), "accepted"))


static func describe(event: InputEventKey) -> String:
	var normalized := normalize(event)
	return "unicode=%d keycode=%d physical=%d shift=%s echo=%s reason=%s" % [
		normalized.get("unicode", 0),
		normalized.get("keycode", 0),
		normalized.get("physical_keycode", 0),
		str(normalized.get("shift", false)),
		str(event.echo),
		normalized.get("reason", "not_key"),
	]


static func _is_latin_letter(codepoint: int) -> bool:
	return (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122)


static func _result(accepted: bool, letter: String, reason: String) -> Dictionary:
	return {
		"accepted": accepted,
		"letter": letter,
		"reason": reason,
	}
