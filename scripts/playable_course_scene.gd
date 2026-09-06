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

const KeycapVisualScript = preload("res://scripts/presentation/keycap_visual.gd")
const LegendFont = preload("res://assets/fonts/Barlow-Medium.ttf")
const RunnerVisualScript = preload("res://scripts/presentation/runner_visual.gd")
const WorkshopWorldScript = preload("res://scripts/presentation/workshop_world.gd")
const WorkshopHUDScript = preload("res://scripts/presentation/workshop_hud.gd")
const RenderEvidenceScript = preload("res://tests/render_evidence.gd")

const FIELD_HEIGHT := 0.32
const FIGURE_HEIGHT := 0.55
const MAX_VISUAL_WAYPOINTS := 18
## Presentation bounds, not input timing. A running catch-up window is never
## restarted by another valid key; new route segments are condensed into it.
const MAX_CATCH_UP_SECONDS := 0.05
const CAMERA_CATCH_UP_SECONDS := 0.08
const HEAD_SHAKE_SECONDS := 0.24
const CAMERA_DISTANCE := 7.4
const CAMERA_HEIGHT := 4.7
const CAMERA_LOOK_AHEAD := 3.4
const CAMERA_SHOULDER_OFFSET := 1.0
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

var runner_visual := RunnerVisualScript.new()
var workshop_hud := WorkshopHUDScript.new()
var _grain_texture: ImageTexture
var _normal_texture: ImageTexture

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
	var render_evidence := RenderEvidenceScript.requested()
	if render_evidence:
		_storage_base_path = "user://parkey-test-results/render-evidence/run-%d" % Time.get_ticks_usec()
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
	workshop_hud.build(self)
	runner_visual.build(figure, figure_head)
	figure.rotation.y = -atan2(course_forward().x, -course_forward().z)
	_build_environment()
	_build_course_geometry()
	course_identity_after_render = session.course_identity()
	_reset_visited_fields()
	_snap_presentation_to_logical(true)
	_refresh_view(_now_usec())
	_reset_keycap_press()
	print("Parkey P2b started: fields=%d identity=%s profile=%s renderer=%s" % [
		course.fields.size(), course_identity_before_render, RenderProfileScript.expected_profile(), RenderProfileScript.current_method(),
	])
	if render_evidence:
		add_child(RenderEvidenceScript.new())


func _process(delta: float) -> void:
	if session == null or not session.is_valid():
		return
	var was_moving := not visual_waypoints.is_empty()
	_advance_visual(delta)
	_advance_head_shake(delta)
	for cap in field_nodes.values():
		cap.advance(delta)
	var current_cap: KeycapVisual = field_nodes[session.current_field_id]
	runner_visual.advance(delta, was_moving, _head_shake_remaining > 0.0, current_cap.press_offset if visual_waypoints.is_empty() else 0.0)
	_update_camera(delta)
	_flush_one_pending_result()
	_refresh_view(_now_usec())


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3 and not event.ctrl_pressed and not event.alt_pressed and not event.meta_pressed:
		workshop_hud.set_debug(not workshop_hud.debug_enabled)
		get_viewport().set_input_as_handled()


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
	workshop_hud.result_debug.text = ""
	_reset_visited_fields()
	_snap_presentation_to_logical(true)
	_reset_keycap_press()
	runner_visual.reset()


func _build_environment() -> void:
	var quality := RenderProfileScript.quality_enabled()
	WorkshopWorldScript.build(self, %WorldEnvironment, %Floor, quality)
	get_node("KeyLight").shadow_enabled = quality
	get_node("KeyLight").light_energy = 1.0 if quality else 0.85
	get_node("KeyLight").light_angular_distance = 1.2
	get_node("KeyLight").directional_shadow_max_distance = 75.0
	get_node("KeyLight").shadow_blur = 1.0
	get_node("KeyLight").shadow_normal_bias = 1.5
	if quality:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	get_node("FillLight").light_energy = 0.22
	get_viewport().msaa_3d = Viewport.MSAA_4X if quality else Viewport.MSAA_DISABLED
	var grain := Image.create(128, 128, false, Image.FORMAT_RGB8)
	var normal := Image.create(128, 128, false, Image.FORMAT_RGB8)
	for y in 128:
		for x in 128:
			var value := 0.88 + float((x * 73 + y * 151 + x * y * 13) % 31) / 258.0
			grain.set_pixel(x, y, Color(value, value, value))
			var nx := float((x * 37 + y * 17 + x * y * 3) % 31 - 15) / 160.0
			var ny := float((x * 13 + y * 43 + x * y * 7) % 31 - 15) / 160.0
			normal.set_pixel(x, y, Color(0.5 + nx, 0.5 + ny, 1.0))
	grain.generate_mipmaps()
	normal.generate_mipmaps()
	_grain_texture = ImageTexture.create_from_image(grain)
	_normal_texture = ImageTexture.create_from_image(normal)


func _build_course_geometry() -> void:
	for field in course.fields:
		var field_id := str(field.get("id", ""))
		var layout: Dictionary = course.layouts[field_id]
		var node := KeycapVisualScript.new()
		node.name = "Field_%s" % field_id
		node.position = layout_point_to_world(layout.get("position", []), 0.0)
		node.rotation_degrees.y = -float(layout.get("rotation_deg", 0.0))
		course_root.add_child(node)
		field_nodes[field_id] = node
		_build_field_mesh(node, field_id, str(field.get("letter", "")), layout)
		node.capture_rest_heights()
	for transition in course.transitions:
		_build_transition_mesh(transition)
	_update_markers()


func _build_field_mesh(node: Node3D, field_id: String, letter: String, layout: Dictionary) -> void:
	var size_data: Array = layout.get("size", [2.0, 2.0])
	var size := Vector2(float(size_data[0]), float(size_data[1]))
	var selection := MeshInstance3D.new()
	selection.name = "Selection"
	var selection_mesh := KeycapVisualScript.rounded_mesh(size, 0.04, 0.015)
	selection.mesh = selection_mesh
	selection.position.y = 0.045
	node.add_child(selection)

	var keycap := MeshInstance3D.new()
	keycap.name = "Keycap"
	var key_mesh := KeycapVisualScript.cap_mesh(size, false)
	var color := _default_field_color(field_id)
	if field_id == course.start_id:
		color = Color("3e9e75")
	elif field_id == course.target_id:
		color = Color("b95c78")
	keycap.material_override = _material(color, 0.48)
	keycap.mesh = key_mesh
	keycap.position.y = 0.0
	node.add_child(keycap)

	var state_surface := MeshInstance3D.new()
	state_surface.name = "StateSurface"
	var state_mesh := KeycapVisualScript.cap_mesh(size, true)
	state_surface.mesh = state_mesh
	state_surface.position.y = 0.0
	node.add_child(state_surface)

	var label := Label3D.new()
	label.name = "Letter"
	label.text = letter
	label.font_size = 192
	label.outline_size = 0
	label.shaded = true
	label.modulate = Color("302b26")
	label.font = LegendFont
	var region := KeycapVisualScript.legend_region(size)
	var glyph_size := label.font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, label.font_size)
	label.pixel_size = minf(0.0048, minf(region.size.y / glyph_size.x, region.size.x / glyph_size.y))
	label.position = Vector3(region.get_center().x, KeycapVisualScript.TOP_HEIGHT + 0.004, region.get_center().y)
	label.rotation_degrees = Vector3(-90.0, SURFACE_LABEL_CLOCKWISE_ROTATION_DEG, 0.0)
	node.add_child(label)

	var socket := MeshInstance3D.new()
	socket.name = "Socket"
	socket.mesh = KeycapVisualScript.rounded_mesh(size, 0.15, 0.025)
	socket.material_override = _material(Color("182e31"), 0.8)
	socket.position.y = -0.08
	node.add_child(socket)


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
	return anchor - forward * CAMERA_DISTANCE + Vector3.UP * CAMERA_HEIGHT - Vector3(-forward.z, 0, forward.x) * CAMERA_SHOULDER_OFFSET


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
		var is_current: bool = field_id == session.current_field_id
		(node as KeycapVisual).pressed = is_current
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
		state_surface.material_override = _material(surface_color, 0.62)


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
	return Color("c2ad89")


func _status_surface_color(base_color: Color, is_reachable: bool, is_visited: bool) -> Color:
	if is_visited:
		return base_color.darkened(VISITED_DARKEN_AMOUNT)
	if is_reachable:
		return base_color.lightened(REACHABLE_LIGHTEN_AMOUNT)
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
	workshop_hud.refresh(state_name, session.error_count, route_measurement.summary_lines())
	var neighbor_labels: Array[String] = []
	for neighbor_id in session.course.neighbor_ids(session.current_field_id):
		neighbor_labels.append(str(session.course.field_by_id(neighbor_id).get("letter", "")))
	context_label.text = "Feld %s | erreichbar: %s" % [
		session.course.field_by_id(session.current_field_id).get("letter", ""),
		" ".join(neighbor_labels),
	]
	lock_label.visible = lock_active
	lock_label.text = "Tippfehler · %d ms" % int((lock_remaining + 999) / 1000) if lock_label.visible else ""


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
	var result_line := "ZIEL  ·  %s\nFehler: %d" % [
		format_duration_usec(duration_usec),
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

	var best_usec: int = result_store.personal_best_usec(course_identity) if result_store != null else -1
	var top: Array = result_store.top_entries(course_identity) if result_store != null else []
	workshop_hud.show_results(snapshot, best_usec, top, result_store, bool(outcome.get("retained", true)))
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
	material.roughness_texture = _grain_texture
	material.normal_enabled = true
	material.normal_texture = _normal_texture
	material.normal_scale = 0.32
	material.uv1_scale = Vector3(9, 9, 9)
	material.metallic_specular = 0.38
	_material_cache[material_key] = material
	return material


func _now_usec() -> int:
	return _clock_override.now_usec() if _clock_override != null else Time.get_ticks_usec()


func _reset_keycap_press() -> void:
	for field_id in field_nodes:
		field_nodes[field_id].reset_press(field_id == session.current_field_id)
