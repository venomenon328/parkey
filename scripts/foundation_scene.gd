extends Node3D

const KeyInputNormalizer = preload("res://scripts/input/key_input_normalizer.gd")
const RenderProfile = preload("res://scripts/presentation/render_profile.gd")

@onready var profile_label: Label = %ProfileLabel
@onready var input_label: Label = %InputLabel


func _ready() -> void:
	profile_label.text = "Profil: %s | aktiv: %s" % [
		RenderProfile.expected_profile(),
		RenderProfile.current_method(),
	]
	input_label.text = "Tastaturdiagnose: Druecke A-Z (Y/Z, Shift, Echo und Modifier werden angezeigt)."
	print("Parkey foundation started: %s; renderer=%s" % [
		RenderProfile.expected_profile(),
		RenderProfile.current_method(),
	])


func _unhandled_input(event: InputEvent) -> void:
	# This is the application receipt boundary. P0 deliberately does not invent
	# an operating-system event timestamp or make this diagnostic a run timer.
	var received_at_usec := Time.get_ticks_usec()
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	var normalized := KeyInputNormalizer.normalize(key_event)
	if normalized.is_empty():
		return

	var letter: String = normalized.get("letter", "")
	var headline := "Eingabe verworfen (%s)" % normalized.get("reason", "unbekannt")
	if normalized.get("accepted", false):
		headline = "Empfangener Buchstabe: %s" % letter
	input_label.text = "%s\ncaptured_usec=%d %s" % [
		headline,
		received_at_usec,
		KeyInputNormalizer.describe(key_event),
	]
	print(input_label.text)
