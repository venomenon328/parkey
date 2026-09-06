class_name WorkshopHUD
extends RefCounted

const StopwatchIcon = preload("res://scripts/presentation/stopwatch_icon.gd")
const InterfaceFont = preload("res://assets/fonts/Barlow-Medium.ttf")
const TimerFont = preload("res://assets/fonts/BarlowSemiCondensed-SemiBold.ttf")
var result_rows: VBoxContainer
var result_debug: Label
var debug_enabled := false
var debug_controls: Array[Control] = []
var player_status: Label
var errors: Label
var route_details: Label


func build(scene: Node) -> void:
	var hud: CanvasLayer = scene.get_node("HUD")
	var ui_theme := Theme.new()
	ui_theme.default_font = InterfaceFont
	for child in hud.get_children():
		if child is Control:
			child.theme = ui_theme
	var card := Panel.new()
	card.name = "TimerCard"
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	card.offset_left = -175
	card.offset_right = 175
	card.offset_top = 16
	card.offset_bottom = 106
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _panel(0.60))
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
	scene.timer_label.position = Vector2(66, -3)
	scene.timer_label.size = Vector2(275, 66)
	scene.timer_label.add_theme_font_override("font", TimerFont)
	scene.timer_label.add_theme_font_size_override("font_size", 54)
	scene.timer_label.add_theme_color_override("font_color", Color("fff2d9"))
	player_status = _label(card, "PlayerStatus", "Bereit", 13, Color("d4e2dc"))
	player_status.position = Vector2(68, 66)
	errors = _label(card, "Errors", "0 Fehler", 13, Color("d4e2dc"))
	errors.position = Vector2(274, 66)
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
	help.text = "BUCHSTABE  Bewegen     /     BACKSPACE  Neustart     /     ESC  Menü"
	help.add_theme_font_size_override("font_size", 12)
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
	scene.result_panel.add_theme_stylebox_override("panel", _panel(0.86))
	scene.menu_panel.add_theme_stylebox_override("panel", _panel(0.90))
	scene.result_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	scene.result_panel.offset_left = -345
	scene.result_panel.offset_right = -24
	scene.result_panel.offset_top = 136
	scene.result_panel.offset_bottom = 136
	scene.result_label.add_theme_font_override("font", TimerFont)
	scene.result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scene.result_label.add_theme_font_size_override("font_size", 22)
	scene.result_label.add_theme_color_override("font_color", Color("f3d6a0"))
	scene.leaderboard_label.add_theme_font_size_override("font_size", 14)
	scene.leaderboard_label.add_theme_color_override("font_color", Color("e0e9e3"))
	scene.storage_label.add_theme_font_size_override("font_size", 12)
	var result_container: VBoxContainer = scene.result_label.get_parent()
	result_container.add_theme_constant_override("separation", 16)
	scene.leaderboard_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_rows = VBoxContainer.new()
	result_rows.name = "LeaderboardRows"
	result_rows.add_theme_constant_override("separation", 5)
	result_container.add_child(result_rows)
	result_container.move_child(result_rows, 2)
	result_debug = _label(hud, "ResultDebug", "", 12, Color("fff2d9"))
	result_debug.position = Vector2(28, 95)
	debug_controls.append(result_debug)
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
	label.add_theme_font_override("font", InterfaceFont)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


static func _panel(alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.12, 0.13, alpha)
	style.border_color = Color(0.76, 0.69, 0.51, 0.24)
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	return style


func show_results(snapshot: Dictionary, best_usec: int, entries: Array, result_store: RefCounted, retained: bool = true) -> void:
	for child in result_rows.get_children():
		result_rows.remove_child(child)
		child.queue_free()
	var board := result_rows.get_parent().get_node("LeaderboardLabel") as Label
	board.text = "Persönliche Bestzeit: %s\n\nBESTZEITEN  ·  Top 10" % PlayableCourseScene.format_duration_usec(best_usec) if best_usec >= 0 else "BESTZEITEN  ·  Top 10"
	var raw_lines: PackedStringArray = ["Ergebnis: %d us" % int(snapshot.duration_usec)]
	for entry in entries:
		var current: bool = entry.run_id == snapshot.run_id
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		result_rows.add_child(row)
		var color := Color("f3d6a0") if current else Color("e0e9e3")
		var entry_rank: int = result_store.rank_for_run(str(snapshot.course_identity), str(entry.run_id))
		var rank_label := _label(row, "Rank", "%02d" % entry_rank, 17, color)
		rank_label.custom_minimum_size.x = 26
		var time := _label(row, "Time", PlayableCourseScene.format_duration_usec(int(entry.duration_usec)), 22, color)
		time.add_theme_font_override("font", TimerFont)
		time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label(row, "Errors", "%d Fehler%s" % [int(entry.error_count), " · Du" if current else ""], 12, color)
		raw_lines.append("#%d: %d us" % [entry_rank, int(entry.duration_usec)])
	if not retained:
		var note := _label(result_rows, "RetentionNote", "Dieser Lauf liegt außerhalb der Top 100.", 12, Color("d1ded6"))
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_debug.text = "\n".join(raw_lines)
