class_name RunInputAdapter
extends RefCounted

const KeyInputNormalizer = preload("res://scripts/input/key_input_normalizer.gd")

## Bridges P0's Unicode normalizer to the core without allowing UI or shortcut
## events to become game actions. The caller supplies the receipt timestamp.

static func normalize(
		event: InputEvent,
		game_context: bool = true,
		ui_text_input: bool = false,
		has_focus: bool = true,
) -> Dictionary:
	if not event is InputEventKey:
		return {"action": "ignored", "reason": "not_key"}
	var key_event := event as InputEventKey
	if not has_focus:
		return {"action": "ignored", "reason": "no_focus"}
	if not game_context:
		return {"action": "ignored", "reason": "outside_game_context"}
	if ui_text_input:
		return {"action": "ignored", "reason": "ui_text_input"}
	if not key_event.pressed:
		return {"action": "ignored", "reason": "key_up"}
	if key_event.echo:
		return {"action": "ignored", "reason": "echo"}
	if key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed:
		return {"action": "ignored", "reason": "shortcut_modifier"}
	if key_event.keycode == KEY_BACKSPACE:
		return {"action": "quick_restart", "reason": "backspace"}
	if key_event.keycode == KEY_ESCAPE:
		return {"action": "menu_request", "reason": "escape"}
	var normalized := KeyInputNormalizer.normalize(key_event)
	if normalized.get("accepted", false):
		return {"action": "letter", "letter": normalized.get("letter", ""), "reason": "accepted"}
	return {"action": "ignored", "reason": normalized.get("reason", "not_a_to_z")}


static func dispatch(session: RunSession, event: InputEvent, received_usec: int, game_context: bool = true, ui_text_input: bool = false, has_focus: bool = true) -> Dictionary:
	return session.process_action(normalize(event, game_context, ui_text_input, has_focus), received_usec)
