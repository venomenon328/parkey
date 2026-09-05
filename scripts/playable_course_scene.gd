class_name PlayableCourseScene
extends Node3D

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const RuleProfileScript = preload("res://scripts/core/rule_profile.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")
const RunInputAdapterScript = preload("res://scripts/input/run_input_adapter.gd")
const RenderProfileScript = preload("res://scripts/presentation/render_profile.gd")

const FIELD_HEIGHT := 0.32
const FIGURE_HEIGHT := 0.55
const MAX_VISUAL_WAYPOINTS := 18
const MAX_CATCH_UP_SECONDS := 0.35
const CAMERA_CATCH_UP_SECONDS := 0.45
const HEAD_SHAKE_SECONDS := 0.24

@onready var course_root: Node3D = %CourseRoot
@onready var transition_root: Node3D = %TransitionRoot
@onready var figure: Node3D = %PlayerFigure
@onready var figure_head: MeshInstance3D = $PlayerFigure/Head
@onready var camera: Camera3D = %CourseCamera
@onready var timer_label: Label = %TimerLabel
@onready var status_label: Label = %StatusLabel
@onready var context_label: Label = %ContextLabel
@onready var lock_label: Label = %LockLabel
@onready var result_label: Label = %ResultLabel
@onready var validation_label: Label = %ValidationLabel
@onready var menu_panel: PanelContainer = %MenuPanel
@onready var menu_text: Label = %MenuText
@onready var input_test: LineEdit = %InputTest
@onready var profile_label: Label = %ProfileLabel

var course: CourseData
var session: RunSession
var field_nodes := {}
var visual_waypoints: Array[Vector3] = []
var visual_snap_count := 0
var handled_event_count := 0
var completion_view_count := 0
var course_identity_before_render := ""
var course_identity_after_render := ""

var _clock_override: MonotonicClock
var _has_application_focus := true
var _visual_budget_seconds := 0.0
var _camera_budget_seconds := 0.0
var _head_shake_remaining := 0.0
var _camera_initialized := false


func configure_for_test(clock: MonotonicClock) -> void:
	_clock_override = clock


func _ready() -> void:
	course = HandcraftedCourseScript.build()
	var errors := CourseValidatorScript.validate(course)
	session = RunSessionScript.new(course, RuleProfileScript.new(), _clock_override)
	profile_label.text = "%s | aktiv: %s" % [RenderProfileScript.expected_profile(), RenderProfileScript.current_method()]
	if not errors.is_empty() or not session.is_valid():
		validation_label.visible = true
		validation_label.text = "Strecke ungueltig:\n%s" % "\n".join(errors)
		status_label.text = "NICHT SPIELBAR"
		return
	course_identity_before_render = session.course_identity()
	_build_environment()
	_build_course_geometry()
	course_identity_after_render = session.course_identity()
	_snap_presentation_to_logical()
	_refresh_view(_now_usec())
	print("Parkey P1b started: fields=%d identity=%s profile=%s renderer=%s" % [
		course.fields.size(), course_identity_before_render, RenderProfileScript.expected_profile(), RenderProfileScript.current_method(),
	])


func _process(delta: float) -> void:
	if session == null or not session.is_valid():
		return
	_advance_visual(delta)
	_advance_head_shake(delta)
	_update_camera(delta)
	_refresh_view(_now_usec())


func _unhandled_input(event: InputEvent) -> void:
	if session == null or not session.is_valid():
		return
	var received_usec := _now_usec()
	var focus_owner := get_viewport().gui_get_focus_owner()
	var ui_text_input := focus_owner is LineEdit
	var action := RunInputAdapterScript.normalize(event, true, ui_text_input, _has_application_focus)
	if action.get("action", "ignored") == "ignored":
		return

	if action.get("action") == "menu_request" and session.menu_open:
		session.close_menu()
		menu_panel.visible = false
		handled_event_count += 1
		get_viewport().set_input_as_handled()
		_refresh_view(received_usec)
		return

	var previous_field_id := session.current_field_id
	var result := session.process_action(action, received_usec)
	handled_event_count += 1
	_apply_session_event(result, previous_field_id, received_usec)
	get_viewport().set_input_as_handled()


func simulate_focus_lost(received_usec: int = -1) -> Dictionary:
	_has_application_focus = false
	var event := session.handle_focus_lost(_now_usec() if received_usec < 0 else received_usec)
	visual_waypoints.clear()
	_snap_presentation_to_logical()
	_refresh_view(_now_usec() if received_usec < 0 else received_usec)
	return event


func simulate_focus_gained() -> void:
	_has_application_focus = true


func _notification(what: int) -> void:
	if not is_node_ready() or session == null:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		simulate_focus_lost()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		simulate_focus_gained()


func _apply_session_event(event: Dictionary, previous_field_id: String, received_usec: int) -> void:
	match str(event.get("kind", "")):
		"moved":
			_append_visual_transition(previous_field_id, session.current_field_id)
		"finished":
			_append_visual_transition(previous_field_id, session.current_field_id)
			_show_result()
		"error":
			visual_waypoints.clear()
			_snap_presentation_to_logical()
			_head_shake_remaining = HEAD_SHAKE_SECONDS
		"restarted":
			_reset_presentation()
		"menu_requested":
			menu_panel.visible = true
			menu_text.text = "Unterbrochen\n%s" % (
				"Escape: schliessen, Backspace: neuer Versuch" if session.state == RunSessionScript.State.INTERRUPTED
				else "Escape: zurueck in Bereitschaft"
			)
	_refresh_view(received_usec)


func _reset_presentation() -> void:
	visual_waypoints.clear()
	_visual_budget_seconds = 0.0
	_camera_budget_seconds = 0.0
	_head_shake_remaining = 0.0
	figure_head.rotation_degrees = Vector3.ZERO
	menu_panel.visible = false
	result_label.visible = false
	_snap_presentation_to_logical()


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("18233a")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("9bb6d6")
	environment.ambient_light_energy = 0.75
	%WorldEnvironment.environment = environment

	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(80.0, 60.0)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("101827")
	floor_material.roughness = 0.92
	floor_mesh.material = floor_material
	%Floor.mesh = floor_mesh


func _build_course_geometry() -> void:
	for field in course.fields:
		var field_id := str(field.get("id", ""))
		var layout: Dictionary = course.layouts[field_id]
		var node := Node3D.new()
		node.name = "Field_%s" % field_id
		node.position = layout_point_to_world(layout.get("position", []), 0.0)
		node.rotation_degrees.y = -float(layout.get("rotation_deg", 0.0))
		course_root.add_child(node)
		field_nodes[field_id] = node
		_build_field_mesh(node, field_id, str(field.get("letter", "")), layout)
	for transition in course.transitions:
		_build_transition_mesh(transition)
	_update_markers()


func _build_field_mesh(node: Node3D, field_id: String, letter: String, layout: Dictionary) -> void:
	var size_data: Array = layout.get("size", [2.0, 2.0])
	var size := Vector2(float(size_data[0]), float(size_data[1]))
	var selection := MeshInstance3D.new()
	selection.name = "Selection"
	var selection_mesh := BoxMesh.new()
	selection_mesh.size = Vector3(size.x + 0.18, 0.12, size.y + 0.18)
	selection_mesh.material = _material(Color("f8d66d"), 0.35)
	selection.mesh = selection_mesh
	selection.position.y = 0.06
	node.add_child(selection)

	var keycap := MeshInstance3D.new()
	keycap.name = "Keycap"
	var key_mesh := BoxMesh.new()
	key_mesh.size = Vector3(size.x, FIELD_HEIGHT, size.y)
	var color := Color("d78b3d")
	if field_id == course.start_id:
		color = Color("3e9e75")
	elif field_id == course.target_id:
		color = Color("b95c78")
	key_mesh.material = _material(color, 0.48)
	keycap.mesh = key_mesh
	keycap.position.y = 0.12 + FIELD_HEIGHT * 0.5
	node.add_child(keycap)

	var label := Label3D.new()
	label.name = "Letter"
	label.text = letter
	label.font_size = 150
	label.outline_size = 16
	label.modulate = Color("20160f")
	label.pixel_size = 0.007
	label.position.y = 0.46
	label.rotation_degrees.x = -90.0
	node.add_child(label)

	var marker := Label3D.new()
	marker.name = "StateMarker"
	marker.font_size = 66
	marker.outline_size = 10
	marker.pixel_size = 0.004
	marker.position = Vector3(0.0, 0.82, 0.0)
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.add_child(marker)


func _build_transition_mesh(transition: Dictionary) -> void:
	var first_mid := _segment_midpoint(transition.get("from_edge", []))
	var second_mid := _segment_midpoint(transition.get("to_edge", []))
	var delta := second_mid - first_mid
	var bridge := MeshInstance3D.new()
	bridge.name = "Transition_%s_%s" % [transition.get("from", ""), transition.get("to", "")]
	var mesh := BoxMesh.new()
	mesh.size = Vector3(maxf(delta.length() + 0.08, 0.16), 0.1, 0.7)
	mesh.material = _material(Color("dfc27d"), 0.65)
	bridge.mesh = mesh
	bridge.position = Vector3((first_mid.x + second_mid.x) * 0.5, 0.16, (first_mid.y + second_mid.y) * 0.5)
	bridge.rotation.y = -atan2(delta.y, delta.x)
	transition_root.add_child(bridge)


func _append_visual_transition(first_id: String, second_id: String) -> void:
	var transition := _transition_between(first_id, second_id)
	if not transition.is_empty():
		var first_mid := _segment_midpoint(transition.get("from_edge", []))
		var second_mid := _segment_midpoint(transition.get("to_edge", []))
		if str(transition.get("from", "")) != first_id:
			var swap := first_mid
			first_mid = second_mid
			second_mid = swap
		visual_waypoints.append(Vector3(first_mid.x, FIGURE_HEIGHT, first_mid.y))
		visual_waypoints.append(Vector3(second_mid.x, FIGURE_HEIGHT, second_mid.y))
	visual_waypoints.append(_anchor_world(second_id))
	_visual_budget_seconds = MAX_CATCH_UP_SECONDS
	_camera_budget_seconds = CAMERA_CATCH_UP_SECONDS
	if visual_waypoints.size() > MAX_VISUAL_WAYPOINTS:
		visual_snap_count += 1
		visual_waypoints.clear()
		figure.position = _anchor_world(session.current_field_id)
	_update_markers()


func _advance_visual(delta: float) -> void:
	if visual_waypoints.is_empty() or delta <= 0.0:
		return
	var remaining_distance := _remaining_visual_distance()
	var budget := maxf(_visual_budget_seconds, delta)
	var travel := remaining_distance * minf(1.0, delta / budget)
	while travel > 0.0 and not visual_waypoints.is_empty():
		var target := visual_waypoints[0]
		var distance := figure.position.distance_to(target)
		if distance <= travel + 0.0001:
			figure.position = target
			travel -= distance
			visual_waypoints.pop_front()
		else:
			figure.position = figure.position.move_toward(target, travel)
			travel = 0.0
	_visual_budget_seconds = maxf(0.0, _visual_budget_seconds - delta)
	if _visual_budget_seconds <= 0.0 and not visual_waypoints.is_empty():
		figure.position = visual_waypoints[-1]
		visual_waypoints.clear()


func _remaining_visual_distance() -> float:
	var distance := 0.0
	var previous := figure.position
	for point in visual_waypoints:
		distance += previous.distance_to(point)
		previous = point
	return distance


func _advance_head_shake(delta: float) -> void:
	if _head_shake_remaining <= 0.0:
		figure_head.rotation_degrees.z = 0.0
		return
	_head_shake_remaining = maxf(0.0, _head_shake_remaining - delta)
	var progress := 1.0 - _head_shake_remaining / HEAD_SHAKE_SECONDS
	figure_head.rotation_degrees.z = sin(progress * TAU * 3.0) * 13.0


func _update_camera(delta: float) -> void:
	var focus := _anchor_world(session.current_field_id)
	var target_position := camera_target_for_field(session.current_field_id)
	if not _camera_initialized or delta <= 0.0:
		camera.position = target_position
		_camera_initialized = true
	else:
		var budget := maxf(_camera_budget_seconds, delta)
		camera.position = camera.position.lerp(target_position, minf(1.0, delta / budget))
		_camera_budget_seconds = maxf(0.0, _camera_budget_seconds - delta)
		if _camera_budget_seconds <= 0.0:
			camera.position = target_position
	var look_ahead := Vector2(3.0, 0.0).rotated(deg_to_rad(HandcraftedCourseScript.COURSE_ROTATION_DEG))
	camera.look_at(focus + Vector3(look_ahead.x, 0.0, look_ahead.y), Vector3.UP)


func camera_target_for_field(field_id: String) -> Vector3:
	var focus := _anchor_world(field_id)
	var local_offset := Vector2(-5.8, 7.2).rotated(deg_to_rad(HandcraftedCourseScript.COURSE_ROTATION_DEG))
	return Vector3(focus.x + local_offset.x, 8.4, focus.z + local_offset.y)


func _snap_presentation_to_logical() -> void:
	if session == null or session.current_field_id.is_empty():
		return
	figure.position = _anchor_world(session.current_field_id)
	_update_markers()
	_update_camera(0.0)


func _update_markers() -> void:
	if session == null:
		return
	var neighbors := session.course.neighbor_ids(session.current_field_id)
	for field_id in field_nodes.keys():
		var node: Node3D = field_nodes[field_id]
		var selection: MeshInstance3D = node.get_node("Selection")
		var marker: Label3D = node.get_node("StateMarker")
		if field_id == session.current_field_id:
			selection.visible = true
			marker.visible = true
			marker.text = "●"
			marker.modulate = Color("fff4bc")
		elif neighbors.has(field_id):
			selection.visible = true
			marker.visible = true
			marker.text = "◇"
			marker.modulate = Color("c8f0ff")
		else:
			selection.visible = false
			marker.visible = false


func _refresh_view(now_usec: int) -> void:
	if session == null:
		return
	timer_label.text = format_duration_usec(session.elapsed_usec(now_usec))
	var lock_remaining := session.lock_until_usec - now_usec
	var lock_active := session.state == RunSessionScript.State.LOCKED and lock_remaining > 0
	var state_name: String = str(RunSessionScript.State.keys()[session.state])
	if session.state == RunSessionScript.State.LOCKED and not lock_active:
		state_name = "RUNNING"
	status_label.text = state_name
	var neighbor_labels: Array[String] = []
	for neighbor_id in session.course.neighbor_ids(session.current_field_id):
		neighbor_labels.append(str(session.course.field_by_id(neighbor_id).get("letter", "")))
	context_label.text = "Feld %s | erreichbar: %s" % [
		session.course.field_by_id(session.current_field_id).get("letter", ""),
		" ".join(neighbor_labels),
	]
	lock_label.visible = lock_active
	lock_label.text = "FEHLERSPERRE %d ms" % int((lock_remaining + 999) / 1000) if lock_label.visible else ""


func _show_result() -> void:
	completion_view_count += 1
	result_label.visible = true
	result_label.text = "ZIEL  %s  |  Fehler: %d" % [
		format_duration_usec(int(session.last_result.get("duration_usec", 0))),
		int(session.last_result.get("error_count", 0)),
	]


func _anchor_world(field_id: String) -> Vector3:
	var layout: Dictionary = course.layouts.get(field_id, {})
	return layout_point_to_world(layout.get("anchor", []), FIGURE_HEIGHT)


func _transition_between(first_id: String, second_id: String) -> Dictionary:
	var wanted := CourseData.edge_key(first_id, second_id)
	for transition in course.transitions:
		if CourseData.edge_key(str(transition.get("from", "")), str(transition.get("to", ""))) == wanted:
			return transition
	return {}


static func _segment_midpoint(segment: Array) -> Vector2:
	if segment.size() != 2:
		return Vector2.ZERO
	var first: Array = segment[0]
	var second: Array = segment[1]
	return Vector2((float(first[0]) + float(second[0])) * 0.5, (float(first[1]) + float(second[1])) * 0.5)


static func layout_point_to_world(point: Array, height: float = 0.0) -> Vector3:
	return Vector3(float(point[0]), height, float(point[1])) if point.size() == 2 else Vector3.ZERO


static func format_duration_usec(duration_usec: int) -> String:
	var total_milliseconds: int = maxi(0, duration_usec) / 1000
	var minutes: int = total_milliseconds / 60000
	var seconds: int = (total_milliseconds / 1000) % 60
	var milliseconds: int = total_milliseconds % 1000
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


static func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _now_usec() -> int:
	return _clock_override.now_usec() if _clock_override != null else Time.get_ticks_usec()
