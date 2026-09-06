class_name PlayableCourseScene
extends Node3D

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const RouteSectionContractScript = preload("res://scripts/course/route_section_contract.gd")
const RouteMeasurementScript = preload("res://scripts/course/route_measurement.gd")
const RuleProfileScript = preload("res://scripts/core/rule_profile.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")
const RunInputAdapterScript = preload("res://scripts/input/run_input_adapter.gd")
const RenderProfileScript = preload("res://scripts/presentation/render_profile.gd")
const LocalResultStoreScript = preload("res://scripts/storage/local_result_store.gd")
const RunIdGeneratorScript = preload("res://scripts/storage/run_id_generator.gd")

const FIELD_HEIGHT := 0.32
const FIGURE_HEIGHT := 0.55
const MAX_VISUAL_WAYPOINTS := 18
## Presentation bounds, not input timing. A running catch-up window is never
## restarted by another valid key; new route segments are condensed into it.
const MAX_CATCH_UP_SECONDS := 0.05
const CAMERA_CATCH_UP_SECONDS := 0.08
const HEAD_SHAKE_SECONDS := 0.24
const CAMERA_DISTANCE := 7.2
const CAMERA_HEIGHT := 6.2
const CAMERA_LOOK_AHEAD := 7.2
const SURFACE_LABEL_CLOCKWISE_ROTATION_DEG := -90.0
const VISITED_DARKEN_AMOUNT := 0.28
const REACHABLE_LIGHTEN_AMOUNT := 0.18
const CURRENT_BORDER_LIGHTEN_AMOUNT := 0.12

@onready var course_root: Node3D = %CourseRoot
@onready var transition_root: Node3D = %TransitionRoot
@onready var figure: Node3D = %PlayerFigure
@onready var figure_head: Node3D = %HeadPivot
@onready var camera: Camera3D = %CourseCamera
@onready var timer_label: Label = %TimerLabel
@onready var status_label: Label = %StatusLabel
@onready var context_label: Label = %ContextLabel
@onready var lock_label: Label = %LockLabel
@onready var result_label: Label = %ResultLabel
@onready var leaderboard_label: Label = %LeaderboardLabel
@onready var storage_label: Label = %StorageLabel
@onready var result_panel: PanelContainer = %ResultPanel
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
var visited_field_ids := {}
var result_store: RefCounted
var route_measurement: RouteMeasurement
var section_contracts: Array[Dictionary] = []

var _clock_override: MonotonicClock
var _has_application_focus := true
var _visual_budget_seconds := 0.0
var _camera_budget_seconds := 0.0
var _head_shake_remaining := 0.0
var _camera_initialized := false
var _camera_focus := Vector3.ZERO
var _material_cache := {}
var _storage_base_path := "user://parkey-results"
var _storage_persistent_override := -1
var _storage_faults := {}
var _run_id_generator: RefCounted
var _pending_result_snapshots: Array[Dictionary] = []
var _last_handled_result_count := 0
var _shown_result_run_id := ""
var _next_store_attempt_usec := 0


func configure_for_test(
		clock: MonotonicClock,
		storage_base_path: String = "",
		scripted_run_ids: Array = [],
		persistent_override: int = 1,
		storage_faults: Dictionary = {},
) -> void:
	_clock_override = clock
	if not storage_base_path.is_empty():
		_storage_base_path = storage_base_path
	_storage_persistent_override = persistent_override
	_storage_faults = storage_faults.duplicate(true)
	_run_id_generator = RunIdGeneratorScript.new(scripted_run_ids)


func _ready() -> void:
	course = HandcraftedCourseScript.build()
	var errors := CourseValidatorScript.validate(course)
	section_contracts = HandcraftedCourseScript.section_contracts()
	errors.append_array(RouteSectionContractScript.validate(course, section_contracts))
	session = RunSessionScript.new(course, RuleProfileScript.new(), _clock_override)
	route_measurement = RouteMeasurementScript.new(section_contracts)
	if _run_id_generator == null:
		_run_id_generator = RunIdGeneratorScript.new()
	result_store = LocalResultStoreScript.new(_storage_base_path, _storage_persistent_override, _storage_faults)
	result_store.load()
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
	_reset_visited_fields()
	_snap_presentation_to_logical(true)
	_refresh_view(_now_usec())
	print("Parkey P2a started: fields=%d identity=%s profile=%s renderer=%s" % [
		course.fields.size(), course_identity_before_render, RenderProfileScript.expected_profile(), RenderProfileScript.current_method(),
	])


func _process(delta: float) -> void:
	if session == null or not session.is_valid():
		return
	_advance_visual(delta)
	_advance_head_shake(delta)
	_update_camera(delta)
	_flush_one_pending_result()
	_refresh_view(_now_usec())


func _unhandled_input(event: InputEvent) -> void:
	if session == null or not session.is_valid():
		return
	var received_usec := _now_usec()
	var focus_owner := get_viewport().gui_get_focus_owner()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if focus_owner is LineEdit:
			focus_owner.release_focus()
			get_viewport().set_input_as_handled()
		return
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
	var now_usec := _now_usec() if received_usec < 0 else received_usec
	var previous_field_id := session.current_field_id
	var event := session.handle_focus_lost(now_usec)
	if route_measurement != null:
		route_measurement.record_session_event(event, previous_field_id, session.current_field_id, now_usec)
	visual_waypoints.clear()
	_visual_budget_seconds = 0.0
	_reconcile_figure_to_logical()
	_refresh_view(now_usec)
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
	if route_measurement != null:
		route_measurement.record_session_event(event, previous_field_id, session.current_field_id, received_usec)
	match str(event.get("kind", "")):
		"moved":
			visited_field_ids[session.current_field_id] = true
			_append_visual_transition(previous_field_id, session.current_field_id)
		"finished":
			visited_field_ids[session.current_field_id] = true
			_append_visual_transition(previous_field_id, session.current_field_id)
			_queue_finished_result()
		"error":
			visual_waypoints.clear()
			_visual_budget_seconds = 0.0
			_reconcile_figure_to_logical()
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
	result_panel.visible = false
	result_label.visible = false
	leaderboard_label.visible = false
	storage_label.visible = false
	_shown_result_run_id = ""
	_reset_visited_fields()
	_snap_presentation_to_logical(true)


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
	selection_mesh.size = Vector3(size.x + 0.24, 0.14, size.y + 0.24)
	selection_mesh.material = _material(Color("f8d66d"), 0.35)
	selection.mesh = selection_mesh
	selection.position.y = 0.35
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

	var state_surface := MeshInstance3D.new()
	state_surface.name = "StateSurface"
	var state_mesh := BoxMesh.new()
	state_mesh.size = Vector3(maxf(0.4, size.x - 0.12), 0.035, maxf(0.4, size.y - 0.12))
	state_surface.mesh = state_mesh
	state_surface.position.y = 0.4575
	node.add_child(state_surface)

	var label := Label3D.new()
	label.name = "Letter"
	label.text = letter
	label.font_size = 192
	label.outline_size = 18
	label.modulate = Color("fff4d7")
	label.outline_modulate = Color("17233a")
	label.pixel_size = 0.0075
	label.position = Vector3(0.0, 0.49, -minf(0.48, size.y * 0.24))
	label.rotation_degrees = Vector3(-90.0, SURFACE_LABEL_CLOCKWISE_ROTATION_DEG, 0.0)
	node.add_child(label)

	var marker := Label3D.new()
	marker.name = "StateMarker"
	marker.font_size = 72
	marker.outline_size = 10
	marker.pixel_size = 0.0035
	marker.position = Vector3(0.0, 0.5, minf(0.5, size.y * 0.28))
	marker.rotation_degrees.x = -90.0
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
	# Keep the original deadline while the presentation is already catching up.
	# Resetting it here made every normal key postpone the whole remaining route.
	if _visual_budget_seconds <= 0.0:
		_visual_budget_seconds = MAX_CATCH_UP_SECONDS
	if _camera_budget_seconds <= 0.0:
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


func visual_backlog_distance() -> float:
	return _remaining_visual_distance()


func _advance_head_shake(delta: float) -> void:
	if _head_shake_remaining <= 0.0:
		figure_head.rotation_degrees.z = 0.0
		return
	_head_shake_remaining = maxf(0.0, _head_shake_remaining - delta)
	var progress := 1.0 - _head_shake_remaining / HEAD_SHAKE_SECONDS
	figure_head.rotation_degrees.z = sin(progress * TAU * 3.0) * 13.0


func _update_camera(delta: float) -> void:
	var target_position := camera_target_for_field(session.current_field_id)
	var target_focus := camera_focus_for_field(session.current_field_id)
	if not _camera_initialized:
		_initialize_camera(target_position, target_focus)
		return
	if delta <= 0.0:
		return
	var budget := maxf(_camera_budget_seconds, delta)
	var weight := minf(1.0, delta / budget)
	camera.position = camera.position.lerp(target_position, weight)
	_camera_focus = _camera_focus.lerp(target_focus, weight)
	_camera_budget_seconds = maxf(0.0, _camera_budget_seconds - delta)
	if _camera_budget_seconds <= 0.0:
		camera.position = target_position
		_camera_focus = target_focus
	camera.look_at(_camera_focus, Vector3.UP)


func camera_target_for_field(field_id: String) -> Vector3:
	var anchor := _anchor_world(field_id)
	var forward := course_forward()
	return anchor - forward * CAMERA_DISTANCE + Vector3.UP * CAMERA_HEIGHT


func camera_focus_for_field(field_id: String) -> Vector3:
	var preview_anchor = RouteSectionContractScript.preview_anchor(course, section_contracts, field_id)
	if preview_anchor != null:
		return Vector3(preview_anchor.x, FIGURE_HEIGHT, preview_anchor.y)
	return _anchor_world(field_id) + course_forward() * CAMERA_LOOK_AHEAD


func course_forward() -> Vector3:
	var direction := Vector2(1.0, 0.0).rotated(deg_to_rad(HandcraftedCourseScript.COURSE_ROTATION_DEG))
	return Vector3(direction.x, 0.0, direction.y)


func _snap_presentation_to_logical(reset_camera: bool = false) -> void:
	if session == null or session.current_field_id.is_empty():
		return
	figure.position = _anchor_world(session.current_field_id)
	_update_markers()
	if reset_camera:
		_initialize_camera(
			camera_target_for_field(session.current_field_id),
			camera_focus_for_field(session.current_field_id),
		)


func _reconcile_figure_to_logical() -> void:
	if session == null or session.current_field_id.is_empty():
		return
	figure.position = _anchor_world(session.current_field_id)
	_update_markers()


func _initialize_camera(target_position: Vector3, target_focus: Vector3) -> void:
	camera.position = target_position
	_camera_focus = target_focus
	_camera_initialized = true
	camera.look_at(_camera_focus, Vector3.UP)


func _update_markers() -> void:
	if session == null:
		return
	var neighbors := session.course.neighbor_ids(session.current_field_id)
	for raw_field_id in field_nodes.keys():
		var field_id := str(raw_field_id)
		var node: Node3D = field_nodes[field_id]
		var selection: MeshInstance3D = node.get_node("Selection")
		var keycap: MeshInstance3D = node.get_node("Keycap")
		var state_surface: MeshInstance3D = node.get_node("StateSurface")
		var marker: Label3D = node.get_node("StateMarker")
		var is_current: bool = field_id == session.current_field_id
		var is_reachable: bool = neighbors.has(field_id)
		var is_visited: bool = visited_field_ids.has(field_id)
		var base_color := _default_field_color(field_id)
		var surface_color := _status_surface_color(base_color, is_reachable, is_visited)
		var show_reachable_status := is_reachable and not is_visited
		keycap.material_override = _material(base_color, 0.48)
		selection.visible = is_current or show_reachable_status
		selection.material_override = _material(
			base_color.lightened(CURRENT_BORDER_LIGHTEN_AMOUNT if is_current else REACHABLE_LIGHTEN_AMOUNT),
			0.3,
		)
		state_surface.material_override = _material(surface_color, 0.38)
		marker.visible = is_current or is_reachable or is_visited
		marker.text = "● ✓" if is_current else "✓" if is_visited else "◇" if is_reachable else ""
		marker.modulate = _marker_color(base_color, is_current, is_reachable, is_visited)


func field_visual_state(field_id: String) -> Dictionary:
	if session == null:
		return {}
	return {
		"current": field_id == session.current_field_id,
		"reachable": session.course.neighbor_ids(session.current_field_id).has(field_id),
		"visited": visited_field_ids.has(field_id),
	}


func _reset_visited_fields() -> void:
	visited_field_ids = {session.course.start_id: true}


func _default_field_color(field_id: String) -> Color:
	if field_id == course.start_id:
		return Color("3e9e75")
	if field_id == course.target_id:
		return Color("b95c78")
	return Color("d78b3d")


func _status_surface_color(base_color: Color, is_reachable: bool, is_visited: bool) -> Color:
	if is_visited:
		return base_color.darkened(VISITED_DARKEN_AMOUNT)
	if is_reachable:
		return base_color.lightened(REACHABLE_LIGHTEN_AMOUNT)
	return base_color


func _marker_color(base_color: Color, is_current: bool, is_reachable: bool, is_visited: bool) -> Color:
	if is_current:
		return base_color.darkened(0.72)
	if is_visited:
		return base_color.lightened(0.45)
	if is_reachable:
		return base_color.darkened(0.72)
	return base_color


func field_material_colors(field_id: String) -> Dictionary:
	var node: Node3D = field_nodes.get(field_id)
	if node == null:
		return {}
	var keycap: MeshInstance3D = node.get_node("Keycap")
	var state_surface: MeshInstance3D = node.get_node("StateSurface")
	var selection: MeshInstance3D = node.get_node("Selection")
	return {
		"keycap": (keycap.material_override as StandardMaterial3D).albedo_color,
		"surface": (state_surface.material_override as StandardMaterial3D).albedo_color,
		"border": (selection.material_override as StandardMaterial3D).albedo_color,
	}


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


func _queue_finished_result() -> void:
	if session.result_count <= _last_handled_result_count or not bool(session.last_result.get("ranked", false)):
		return
	_last_handled_result_count = session.result_count
	var snapshot := session.last_result.duplicate(true)
	snapshot["run_id"] = _run_id_generator.next_id()
	_pending_result_snapshots.append(snapshot)
	completion_view_count += 1
	_show_result(snapshot)


func _flush_one_pending_result() -> void:
	if result_store == null or _pending_result_snapshots.is_empty():
		return
	if session.state == RunSessionScript.State.RUNNING or session.state == RunSessionScript.State.LOCKED:
		return
	var now_usec := _now_usec()
	if now_usec < _next_store_attempt_usec:
		return
	var snapshot := _pending_result_snapshots[0]
	var outcome: Dictionary = result_store.offer_result(snapshot)
	if not outcome.get("ok", false):
		_pending_result_snapshots.pop_front()
		_update_shown_result(snapshot, outcome)
		return
	var saved: Dictionary = result_store.save()
	_update_shown_result(snapshot, outcome)
	if saved.get("ok", false):
		_pending_result_snapshots.pop_front()
		_next_store_attempt_usec = 0
		return
	if result_store.status == LocalResultStoreScript.Status.READ_ERROR or result_store.status == LocalResultStoreScript.Status.UNSUPPORTED:
		_pending_result_snapshots.pop_front()
		return
	# Keep exactly this immutable snapshot for a later retry. A retry never
	# creates a new ID or turns an old screen back on after Quick Restart.
	_next_store_attempt_usec = now_usec + 1000000


func _show_result(snapshot: Dictionary, outcome: Dictionary = {}) -> void:
	result_panel.visible = true
	result_label.visible = true
	leaderboard_label.visible = true
	storage_label.visible = true
	_shown_result_run_id = str(snapshot.get("run_id", ""))
	_render_result(snapshot, outcome)


func _update_shown_result(snapshot: Dictionary, outcome: Dictionary) -> void:
	if not result_panel.visible or _shown_result_run_id != str(snapshot.get("run_id", "")):
		return
	_render_result(snapshot, outcome)


func _render_result(snapshot: Dictionary, outcome: Dictionary) -> void:
	var course_identity := str(snapshot.get("course_identity", ""))
	var rank := int(outcome.get("rank", 0))
	if rank <= 0 and result_store != null:
		rank = result_store.rank_for_run(course_identity, str(snapshot.get("run_id", "")))
	var duration_usec := int(snapshot.get("duration_usec", 0))
	var result_line := "ZIEL  %s  (%d us)  |  Fehler: %d" % [
		format_duration_usec(duration_usec),
		duration_usec,
		int(snapshot.get("error_count", 0)),
	]
	if rank > 0:
		result_line += "  |  Rang: %d" % rank
	var best_kind := str(outcome.get("best_kind", ""))
	if best_kind == "first" or best_kind == "improved":
		result_line += "  |  neue Bestzeit"
	elif best_kind == "tied":
		result_line += "  |  Bestzeit eingestellt"
	result_label.text = result_line

	var leaderboard_lines: Array[String] = []
	var best_usec: int = result_store.personal_best_usec(course_identity) if result_store != null else -1
	if best_usec >= 0:
		leaderboard_lines.append("Persoenliche Bestzeit: %s (%d us)" % [format_duration_usec(best_usec), best_usec])
	else:
		leaderboard_lines.append("Persoenliche Bestzeit: wird vorbereitet")
	var top: Array = result_store.top_entries(course_identity) if result_store != null else []
	if top.is_empty():
		leaderboard_lines.append("Top 10: wird gespeichert ...")
	else:
		leaderboard_lines.append("Top 10:")
		for entry in top:
			var entry_rank: int = result_store.rank_for_run(course_identity, str(entry["run_id"]))
			leaderboard_lines.append("#%d  %s  (%d us)  |  %d Fehler" % [
				entry_rank,
				format_duration_usec(int(entry["duration_usec"])),
				int(entry["duration_usec"]),
				int(entry["error_count"]),
			])
	if route_measurement != null and not route_measurement.completed_sections.is_empty():
		leaderboard_lines.append("Routenmessung (nur dieser Lauf):")
		leaderboard_lines.append_array(route_measurement.summary_lines())
	if outcome.has("retained") and not bool(outcome["retained"]):
		leaderboard_lines.append("Dieser Lauf bleibt sichtbar, liegt aber ausserhalb der Top 100.")
	leaderboard_label.text = "\n".join(leaderboard_lines)
	storage_label.text = result_store.status_message() if result_store != null else "Speicher wird vorbereitet."


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


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material_key := "%0.4f:%0.4f:%0.4f:%0.4f:%0.3f" % [color.r, color.g, color.b, color.a, roughness]
	if _material_cache.has(material_key):
		return _material_cache[material_key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	_material_cache[material_key] = material
	return material


func _now_usec() -> int:
	return _clock_override.now_usec() if _clock_override != null else Time.get_ticks_usec()
