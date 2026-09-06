extends RefCounted

const SceneScript = preload("res://scripts/playable_course_scene.gd")
const ProfileScript = preload("res://scripts/presentation/render_profile.gd")
const WorldScript = preload("res://scripts/presentation/workshop_world.gd")
const ClockScript = preload("res://scripts/core/monotonic_clock.gd")
const REFERENCE_ID := "course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a"


static func run(harness) -> void:
	print("Running suite: presentation")
	var scene := (load("res://scenes/playable_course.tscn") as PackedScene).instantiate() as PlayableCourseScene
	var clock := ClockScript.Manual.new()
	scene.configure_for_test(clock, "user://parkey-test-results/presentation", [], 0)
	harness.root.add_child(scene)
	await harness.process_frame
	scene.set_process(false)
	harness._assert_equal(scene.session.course_identity(), REFERENCE_ID, "The P2a canonical identity is unchanged by the slice.")
	harness._assert_equal(scene.course_identity_after_render, REFERENCE_ID, "Instantiated presentation preserves canonical layout and rules.")
	harness._assert_equal(scene.transition_root.get_child_count(), scene.course.transitions.size(), "Only explicit P2a transitions receive a visible connector.")
	var quality := ProfileScript.quality_enabled()
	harness._assert_equal(scene.get_viewport().msaa_3d, Viewport.MSAA_2X if quality else Viewport.MSAA_DISABLED, "The actual viewport uses the selected MSAA budget.")
	harness._assert_equal(scene.get_node("KeyLight").shadow_enabled, quality, "The actual key light respects the profile's shadow budget.")
	harness._assert_false(scene.get_node("FillLight").shadow_enabled, "The fill light never adds a second shadow pass.")
	for field_id in scene.field_nodes:
		var cap: KeycapVisual = scene.field_nodes[field_id]
		var layout: Dictionary = scene.course.layouts[field_id]
		var mesh: Mesh = cap.get_node("Keycap").mesh
		var aabb := mesh.get_aabb()
		harness._assert_true(is_equal_approx(aabb.size.x, float(layout.size[0])) and is_equal_approx(aabb.size.z, float(layout.size[1])), "Keycap %s preserves P2a outer width/depth." % field_id)
		harness._assert_vector_close(cap.position, SceneScript.layout_point_to_world(layout.position), 0.0001, "Field %s keeps its canonical position." % field_id)
		harness._assert_true(is_equal_approx(cap.rotation_degrees.y, -float(layout.rotation_deg)), "Field %s keeps its canonical rotation." % field_id)
		harness._assert_equal(cap.get_node("Letter").text, scene.course.field_by_id(field_id).letter, "Field %s keeps its required surface letter." % field_id)
		harness._assert_true(cap.get_node("Letter").position.y > cap.get_node("StateSurface").position.y, "The integrated %s legend clears the cap surface." % field_id)
		var letter: Label3D = cap.get_node("Letter")
		var bounds := letter.get_aabb()
		var half := Vector2(float(layout.size[0]), float(layout.size[1])) * 0.5 - Vector2.ONE * (KeycapVisual.TOP_INSET + 0.09)
		var contained := bounds.size.x > 0.0 and bounds.size.y > 0.0
		for corner in 8:
			var point := letter.transform * bounds.get_endpoint(corner)
			contained = contained and absf(point.x) < half.x and absf(point.z) < half.y
		harness._assert_true(contained, "Actual rotated glyph bounds of %s remain inside its flat top, clear of the shoulder." % field_id)
		harness._assert_true(letter.shaded and letter.outline_size == 0, "The %s print receives surface lighting without an overlay outline." % field_id)
		harness._assert_true(_outward_sides(mesh), "The %s skirt has outward facing triangles and normals." % field_id)
	harness._assert_true(_outward_sides(KeycapVisual.rounded_mesh(Vector2(2, 2), 0.4)), "Workshop beveled solids also have outward facing sides.")
	harness._assert_false(scene.workshop_hud.debug_enabled, "The player starts outside debug mode.")
	for control in scene.workshop_hud.debug_controls:
		harness._assert_false(control.visible, "Technical control %s is hidden by default." % control.name)
	_key(scene, KEY_F3)
	harness._assert_true(scene.workshop_hud.debug_enabled, "F3 enables the actual developer view through viewport input.")
	scene.input_test.grab_focus()
	_key(scene, KEY_F3)
	harness._assert_false(scene.workshop_hud.debug_enabled, "F3 closes diagnostics even with the test text field focused.")
	harness._assert_false(scene.input_test.has_focus(), "Hiding debug releases text focus so gameplay remains reachable.")
	harness._assert_equal(scene.session.state, RunSession.State.READY, "Debug toggles never start a run.")
	var start_symbols: Node3D = scene.field_nodes.start.get_node("StateMarker")
	harness._assert_true(start_symbols.get_node("CurrentDot").visible and start_symbols.get_node("VisitedCheck").visible, "Current/visited signals are instantiated geometry independent of font fallback.")
	var start_cap: KeycapVisual = scene.field_nodes.start
	var next_cap: KeycapVisual = scene.field_nodes.approach_a
	harness._assert_true(is_equal_approx(start_cap.press_offset, -KeycapVisual.PRESS_DEPTH), "Occupied start is held down in readiness.")
	var next_letter_rest: float = next_cap.get_node("Letter").position.y
	var socket_rest: float = next_cap.get_node("Socket").position.y
	_key(scene, KEY_A, "A")
	harness._assert_equal(scene.session.current_field_id, "approach_a", "A valid step is immediate before any press animation frame.")
	harness._assert_true(next_cap.pressed and not start_cap.pressed, "The new current cap takes over depression without a queue.")
	harness._assert_true(start_symbols.get_node("VisitedCheck").visible, "Visited return retains its geometric check.")
	harness._assert_false(start_symbols.get_node("ReachableDiamond").visible, "Visited return never regains a reachable diamond.")
	harness._assert_false(start_symbols.get_node("CurrentDot").visible, "Only the actual current cap displays the geometric dot.")
	scene._process(0.05)
	harness._assert_true(is_equal_approx(next_cap.press_offset, -KeycapVisual.PRESS_DEPTH), "Press reaches its endpoint within the visual budget.")
	harness._assert_true(is_zero_approx(start_cap.press_offset), "The previous cap returns to rest.")
	harness._assert_true(is_equal_approx(next_cap.get_node("Letter").position.y, next_letter_rest - KeycapVisual.PRESS_DEPTH), "Legend follows the cap without floating.")
	harness._assert_equal(next_cap.get_node("Socket").position.y, socket_rest, "The mechanical socket stays fixed below the moving cap.")
	scene._process(2.0)
	harness._assert_true(is_equal_approx(next_cap.press_offset, -KeycapVisual.PRESS_DEPTH), "Occupied cap stays depressed during an arbitrarily long stay.")
	harness._assert_equal(scene.runner_visual.state, "idle", "Settled figure returns to idle.")
	_key(scene, KEY_Z, "Z")
	scene._process(0.01)
	harness._assert_equal(scene.runner_visual.state, "move", "A visible transition selects locomotion.")
	harness._assert_true(scene.runner_visual.movement_blend > 0, "Locomotion blends in while visual waypoints move.")
	_key(scene, KEY_X, "X")
	scene._process(0.05)
	harness._assert_equal(scene.runner_visual.state, "reaction", "An actual invalid input selects the reaction pose.")
	harness._assert_true(scene.visual_waypoints.is_empty(), "Reaction does not play stale movement.")
	clock.current_usec = 200000
	_key(scene, KEY_K, "K")
	harness._assert_equal(scene.session.current_field_id, "decision_one", "Exact 200ms boundary accepts input while the 240ms reaction is still active.")
	_key(scene, KEY_BACKSPACE)
	harness._assert_equal(scene.runner_visual.state, "idle", "Restart clears old animation state.")
	harness._assert_equal(scene.figure_head.rotation, Vector3.ZERO, "Restart clears head feedback.")
	harness._assert_true(is_equal_approx(start_cap.press_offset, -KeycapVisual.PRESS_DEPTH), "Restart restores start depression immediately.")
	# All events share a timestamp; no rendering/animation is allowed to gate acceptance.
	for index in 60:
		_key(scene, KEY_A if index % 2 == 0 else KEY_S, "A" if index % 2 == 0 else "S")
	harness._assert_equal(scene.session.current_field_id, "start", "Sixty same-frame inputs are all consumed in order.")
	harness._assert_equal(scene.session.error_count, 0, "Presentation adds no false errors to high-frequency input.")
	harness._assert_true(scene.visual_waypoints.size() <= SceneScript.MAX_VISUAL_WAYPOINTS, "Animation backlog stays bounded.")
	_key(scene, KEY_BACKSPACE)
	var direct := RunSession.new(scene.course)
	for letter in HandcraftedCourse.UPPER_ROUTE:
		clock.current_usec += 1000
		_key(scene, letter.unicode_at(0), letter)
		direct.process_action({"action": "letter", "letter": letter}, clock.current_usec)
	harness._assert_equal(scene.session.last_result, direct.last_result, "Rendered scene and direct kernel produce exactly the same result for identical timestamps.")
	harness._assert_false(scene.leaderboard_label.text.contains("Routenmessung"), "Technical section measurements stay out of the normal result card.")
	harness._assert_not_null(scene.get_node_or_null("PlayerFigure/LeftArm/Hand"), "Figure has connected arms and hands.")
	harness._assert_not_null(scene.get_node_or_null("PlayerFigure/RightLeg/Shoe"), "Figure has legs and shoes.")
	harness._assert_equal(scene.get_node_or_null("PlayerFigure/HeadPivot/HeadIndicator"), null, "The protruding head box is removed.")
	for method in ["forward_plus", "gl_compatibility"]:
		var config := ProfileScript.settings_for_method(method)
		var parent := Node3D.new()
		var environment := WorldEnvironment.new()
		var floor_mesh := MeshInstance3D.new()
		parent.add_child(environment)
		parent.add_child(floor_mesh)
		harness.root.add_child(parent)
		WorldScript.build(parent, environment, floor_mesh, config.ssao)
		harness._assert_equal(environment.environment.ssao_enabled, method == "forward_plus", "Actual %s environment respects the bounded SSAO profile." % method)
		harness._assert_false(environment.environment.glow_enabled, "No profile needs bloom for required signals.")
		harness._assert_equal(environment.environment.fog_sky_affect, 0.0, "Distance fog must not replace the cloud panorama with a flat background.")
		var sky_material := environment.environment.sky.sky_material as PanoramaSkyMaterial
		harness._assert_not_null(sky_material.panorama, "Both profiles receive the baked cloud panorama.")
		harness._assert_not_null(parent.get_node_or_null("Workshop"), "Both profiles instantiate the same workshop environment.")
		parent.queue_free()
	scene.queue_free()
	await harness.process_frame


static func _key(scene: Node, code: int, letter: String = "") -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = code
	event.unicode = letter.unicode_at(0) if not letter.is_empty() else 0
	scene.get_viewport().push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	scene.get_viewport().push_input(event, true)


static func _outward_sides(mesh: Mesh) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var checked := 0
	for index in range(0, vertices.size(), 3):
		var center := (vertices[index] + vertices[index + 1] + vertices[index + 2]) / 3.0
		var normal := (vertices[index + 2] - vertices[index]).cross(vertices[index + 1] - vertices[index]).normalized()
		if absf(normal.y) > 0.95:
			continue
		checked += 1
		if normal.dot(Vector3(center.x, 0, center.z)) <= 0.0 or normal.dot(normals[index]) <= 0.0:
			return false
	return checked > 0
