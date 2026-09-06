class_name WorkshopHUD
extends RefCounted

const StopwatchIcon = preload("res://scripts/presentation/stopwatch_icon.gd")
var debug_enabled := false
var debug_controls: Array[Control] = []
var player_status: Label
var errors: Label
var route_details: Label


func build(scene: Node) -> void:
	var hud: CanvasLayer = scene.get_node("HUD")
	var card := Panel.new()
	card.name = "TimerCard"
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	card.offset_left = -184
	card.offset_right = 184
	card.offset_top = 16
	card.offset_bottom = 108
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _panel(0.48))
	hud.add_child(card)
	hud.move_child(card, 0)
	var title := _label(hud, "Brand", "PARKEY", 21, Color("fff2d9"))
	title.position = Vector2(28, 24)
	var subtitle := _label(hud, "WorldName", "T A S T A T U R – W E R K S T A T T", 10, Color("d2e0dc"))
	subtitle.position = Vector2(29, 56)
	var stopwatch := StopwatchIcon.new()
	stopwatch.name = "Stopwatch"
	stopwatch.position = Vector2(18, 14)
	stopwatch.size = Vector2(36, 42)
	stopwatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(stopwatch)
	scene.timer_label.reparent(card)
	scene.timer_label.position = Vector2(66, 0)
	scene.timer_label.size = Vector2(285, 62)
	var timer_font := FontVariation.new()
	timer_font.base_font = ThemeDB.fallback_font
	timer_font.variation_embolden = 0.65
	scene.timer_label.add_theme_font_override("font", timer_font)
	scene.timer_label.add_theme_font_size_override("font_size", 46)
	scene.timer_label.add_theme_color_override("font_color", Color("fff2d9"))
	player_status = _label(card, "PlayerStatus", "Bereit", 13, Color("d4e2dc"))
	player_status.position = Vector2(68, 66)
	errors = _label(card, "Errors", "0 Fehler", 13, Color("d4e2dc"))
	errors.position = Vector2(285, 66)
	scene.lock_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	scene.lock_label.offset_left = -150
	scene.lock_label.offset_right = 150
	scene.lock_label.offset_top = 118
	scene.lock_label.offset_bottom = 150
	scene.lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var help: Label = hud.get_node("Help")
	help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	help.offset_left = -545
	help.offset_top = -62
	help.offset_right = -30
	help.offset_bottom = -24
	help.text = "Buchstabe: Bewegen   ·   Backspace: Neustart   ·   Esc: Menü\nF3: Entwickleransicht"
	help.add_theme_color_override("font_color", Color("d1ded6"))
	help.add_theme_color_override("font_shadow_color", Color("182f32"))
	help.add_theme_constant_override("shadow_offset_y", 1)
	var debug_panel := Panel.new()
	debug_panel.name = "DebugPanel"
	debug_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	debug_panel.offset_left = 18
	debug_panel.offset_top = -228
	debug_panel.offset_right = 510
	debug_panel.offset_bottom = -18
	debug_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_panel.add_theme_stylebox_override("panel", _panel(0.94))
	hud.add_child(debug_panel)
	hud.move_child(debug_panel, 0)
	debug_controls.append(debug_panel)
	var diagnostics: Array[Control] = [scene.status_label, scene.context_label, scene.profile_label]
	for index in diagnostics.size():
		var control := diagnostics[index]
		control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		control.offset_left = 32
		control.offset_top = -216 + index * 30
		control.offset_right = 495
		control.offset_bottom = -190 + index * 30
		(control as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		(control as Label).add_theme_font_size_override("font_size", 14)
		debug_controls.append(control)
	debug_controls.append(scene.input_test)
	debug_controls.append(hud.get_node("InputTestLabel"))
	route_details = _label(hud, "RouteDetails", "", 12, Color("d1ded6"))
	route_details.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	route_details.offset_left = -420
	route_details.offset_right = -24
	route_details.offset_top = 24
	route_details.offset_bottom = 140
	debug_controls.append(route_details)
	scene.result_panel.add_theme_stylebox_override("panel", _panel(0.76))
	scene.menu_panel.add_theme_stylebox_override("panel", _panel(0.90))
	scene.result_panel.offset_left = -325
	scene.result_panel.offset_right = 325
	scene.result_panel.offset_top = -200
	scene.result_panel.offset_bottom = -200
	scene.result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scene.result_label.add_theme_font_size_override("font_size", 24)
	scene.result_label.add_theme_color_override("font_color", Color("f3d6a0"))
	scene.leaderboard_label.add_theme_font_size_override("font_size", 14)
	scene.leaderboard_label.add_theme_color_override("font_color", Color("e0e9e3"))
	scene.storage_label.add_theme_font_size_override("font_size", 12)
	set_debug(false)


func set_debug(enabled: bool) -> void:
	debug_enabled = enabled
	for control in debug_controls:
		if not enabled and control.has_focus():
			control.release_focus()
		control.visible = enabled


func refresh(state: String, error_count: int, route_lines: PackedStringArray) -> void:
	var names := {"READY": "Bereit · tippe A", "RUNNING": "Im Lauf", "LOCKED": "Kurz durchatmen", "FINISHED": "Geschafft", "INTERRUPTED": "Unterbrochen", "INVALIDATED": "Lauf abgebrochen"}
	player_status.text = str(names.get(state, "Unterbrochen"))
	errors.text = "%d Fehler" % error_count
	route_details.text = "Routenmessung (nur dieser Lauf):\n" + "\n".join(route_lines) if not route_lines.is_empty() else ""


static func _label(parent: Node, node_name: String, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


static func _panel(alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.12, 0.13, alpha)
	style.border_color = Color(0.76, 0.69, 0.51, 0.24)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style
