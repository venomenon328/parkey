class_name IntegrationSuite
extends RefCounted

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const MonotonicClockScript = preload("res://scripts/core/monotonic_clock.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")
const PlayableCourseSceneScript = preload("res://scripts/playable_course_scene.gd")


static func run(harness) -> void:
	print("Running suite: integration")
	_test_handcrafted_course(harness)
	_test_timer_format(harness)
	await _test_scene_input_ui_and_routes(harness)
	await _test_lock_restart_menu_and_focus(harness)
	await _test_fast_input_and_presentation_budget(harness)


static func _test_handcrafted_course(harness) -> void:
	var course := HandcraftedCourseScript.build()
	harness._assert_equal(course.fields.size(), 26, "The hand-authored P1b course contains 26 fields.")
	harness._assert_true(CourseValidatorScript.validate_graph(course).is_empty(), "The actual hand course passes graph validation.")
	harness._assert_true(CourseValidatorScript.validate_layout(course).is_empty(), "The actual hand course passes layout validation.")
	harness._assert_true(CourseValidatorScript.validate(course).is_empty(), "The actual hand course is never partially released.")
	harness._assert_equal(course.neighbor_ids("fork").size(), 3, "The visible fork has a returning edge and two route choices.")
	harness._assert_equal(course.neighbor_ids("merge").size(), 3, "Both route branches visibly merge before the finale.")
	harness._assert_equal(course.field_by_id("approach_z").get("letter"), "Z", "The approach contains a reachable Z passage.")
	harness._assert_equal(course.field_by_id("upper_6").get("letter"), "Y", "The upper route contains a reachable Y passage.")
	harness._assert_true(is_equal_approx(float(course.layouts["upper_4"]["size"][0]), 2.6), "The irregular passage includes a moderately wider field.")
	harness._assert_true(is_equal_approx(float(course.layouts["upper_5"]["size"][0]), 1.4), "The irregular passage includes a moderately narrower field.")
	harness._assert_equal(course.layouts["fork"].get("rotation_deg"), 18.0, "The course includes a data-authored slanted orientation.")
	harness._assert_true(
		_branch_clearance(course, "upper_2", "lower_2") >= HandcraftedCourseScript.BRANCH_SEPARATOR_WIDTH - 0.001,
		"The W/F representative pair has a clearly wider separator than a playable transition gap.",
	)
	for pair in [["upper_1", "lower_1"], ["upper_4", "lower_4"], ["upper_8", "lower_8"]]:
		harness._assert_false(course.has_edge(pair[0], pair[1]), "Separated branch fields %s/%s are explicitly non-neighbors." % pair)
		harness._assert_true(
			_branch_clearance(course, pair[0], pair[1]) >= HandcraftedCourseScript.BRANCH_SEPARATOR_WIDTH - 0.001,
			"Separated branch fields %s/%s retain the documented visible clearance." % pair,
		)
	for pair in [["fork", "upper_1"], ["fork", "lower_1"], ["upper_8", "merge"], ["lower_8", "merge"]]:
		harness._assert_true(course.has_edge(pair[0], pair[1]), "Representative visible transition %s/%s has an explicit graph edge." % pair)

	var upper := RunSession.new(course)
	_drive_letters_direct(upper, HandcraftedCourseScript.UPPER_ROUTE, 1000)
	harness._assert_equal(upper.state, RunSessionScript.State.FINISHED, "The complete upper route reaches the target.")
	var lower := RunSession.new(course)
	_drive_letters_direct(lower, HandcraftedCourseScript.LOWER_ROUTE, 2000)
	harness._assert_equal(lower.state, RunSessionScript.State.FINISHED, "The complete lower route reaches the target.")
	var returning := RunSession.new(course)
	_drive_letters_direct(returning, HandcraftedCourseScript.RETURN_SAMPLE, 3000)
	harness._assert_equal(returning.current_field_id, "start", "The documented sample can return from the upper branch to start.")
	harness._assert_equal(returning.state, RunSessionScript.State.RUNNING, "A readable return remains part of the active attempt.")


static func _test_timer_format(harness) -> void:
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(0), "00:00.000", "Readiness renders an integer zero time.")
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(59999999), "00:59.999", "59,999,999 microseconds are truncated, not rounded.")
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(60000000), "01:00.000", "60,000,000 microseconds carry into minutes.")
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(60000999), "01:00.000", "Sub-millisecond remainder does not mutate stored time.")


static func _test_scene_input_ui_and_routes(harness) -> void:
	var fixture := await _scene_fixture(harness)
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]
	harness._assert_not_null(scene.get_node_or_null("HUD/TimerLabel"), "The real scene initializes its timer HUD in the SceneTree.")
	harness._assert_not_null(scene.get_node_or_null("PlayerFigure/HeadPivot/Head"), "The real scene contains a distinguishable player head.")
	harness._assert_not_null(scene.get_node_or_null("PlayerFigure/HeadPivot/HeadIndicator"), "The head has an asymmetric orientation signal that makes shaking visible.")
	harness._assert_not_null(scene.get_node_or_null("CourseCamera"), "The real scene initializes the automatic camera.")
	harness._assert_equal(scene.field_nodes.size(), 26, "The renderer builds every field from CourseData.")
	harness._assert_equal(scene.course_identity_after_render, scene.course_identity_before_render, "Scene construction does not mutate course identity.")
	harness._assert_equal(ProjectSettings.get_setting("application/run/main_scene"), "res://scenes/playable_course.tscn", "The playable scene is the regular export entry.")
	harness._assert_true(ResourceLoader.exists("res://scenes/foundation.tscn"), "The P0 diagnostic scene remains separately startable.")
	clock.current_usec = 9999999
	scene._process(0.0)
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Arbitrary scene rendering never starts the waiting run.")
	harness._assert_equal(scene.timer_label.text, "00:00.000", "The visible timer remains zero throughout readiness.")
	var ready_start_state := scene.field_visual_state("start")
	harness._assert_true(ready_start_state["current"] and ready_start_state["visited"], "The start field is visibly current and visited in readiness.")
	harness._assert_true(scene.field_visual_state("approach_a")["reachable"], "The first reachable field has its own visible state.")
	harness._assert_false(scene.field_visual_state("approach_z")["visited"], "An untouched non-neighbor remains in the standard state.")
	var course_identity_before_states := scene.session.course_identity()
	var camera_to_start := scene.camera_target_for_field("start") - scene._anchor_world("start")
	harness._assert_true(camera_to_start.dot(scene.course_forward()) < -PlayableCourseSceneScript.CAMERA_DISTANCE + 0.01, "The camera starts behind the figure along the course direction.")
	harness._assert_true(absf(camera_to_start.dot(Vector3(-scene.course_forward().z, 0.0, scene.course_forward().x))) < 0.001, "The rear camera has no isometric side offset.")
	harness._assert_true(scene.camera.projection == Camera3D.PROJECTION_PERSPECTIVE, "The reproducible rear composition uses perspective projection.")
	var viewport_rect := scene.get_viewport().get_visible_rect()
	harness._assert_true(scene.profile_label.get_global_rect().end.x <= viewport_rect.end.x, "The renderer profile stays inside the responsive top bar.")
	harness._assert_true(scene.input_test.get_global_rect().end.y <= viewport_rect.end.y, "The bottom-anchored focus control stays inside the viewport.")
	harness._assert_true(scene.profile_label.clip_contents and scene.profile_label.autowrap_mode != TextServer.AUTOWRAP_OFF, "Long diagnostic profile text wraps and clips inside its assigned HUD region.")

	var fork_layout: Dictionary = scene.course.layouts["fork"]
	var fork_node: Node3D = scene.field_nodes["fork"]
	harness._assert_vector_close(fork_node.position, PlayableCourseSceneScript.layout_point_to_world(fork_layout["position"]), 0.0001, "Data [x,z] maps to Godot [x,y,z] without mirroring.")
	var expected_axis := Vector3(cos(deg_to_rad(18.0)), 0.0, sin(deg_to_rad(18.0)))
	harness._assert_vector_close(fork_node.basis.x.normalized(), expected_axis, 0.001, "Negative Godot yaw preserves the data profile's positive 2D rotation.")

	clock.current_usec = 10000000
	var echo := _key(KEY_A, 97)
	echo.echo = true
	await _push_key(scene, echo)
	var key_up := _key(KEY_A, 97)
	key_up.pressed = false
	await _push_key(scene, key_up)
	var shortcut := _key(KEY_A, 97)
	shortcut.ctrl_pressed = true
	await _push_key(scene, shortcut)
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Echo, key-up and shortcut events do not start through the scene path.")
	var shifted_a := _key(KEY_A, 65)
	shifted_a.shift_pressed = true
	var camera_before_first_move := scene.camera.global_transform
	scene.get_viewport().push_input(shifted_a)
	harness._assert_equal(scene.session.current_field_id, "approach_a", "The viewport path uses the first letter as start and movement.")
	harness._assert_equal(scene.session.start_usec, 10000000, "The scene forwards the captured receipt time unchanged.")
	harness._assert_transform_close(scene.camera.global_transform, camera_before_first_move, 0.0001, "A logical step does not snap camera position or orientation inside the input callback.")
	harness._assert_true(scene.field_visual_state("start")["visited"] and scene.field_visual_state("start")["reachable"], "The visited return neighbor combines both states.")
	harness._assert_true(scene.field_visual_state("approach_a")["current"] and scene.field_visual_state("approach_a")["visited"], "The logical destination becomes current and visited before animation catches up.")
	await scene.get_tree().process_frame
	var field_before_ui := scene.session.current_field_id
	await _push_mouse_click(scene, scene.input_test.get_global_rect().get_center())
	harness._assert_equal(scene.get_viewport().gui_get_focus_owner(), scene.input_test, "A real viewport click focuses the LineEdit.")
	await _push_key(scene, _key(KEY_B, 98))
	await _push_key(scene, _key(KEY_C, 99))
	harness._assert_equal(scene.input_test.text, "bc", "Real viewport key events enter text in the focused LineEdit.")
	clock.current_usec = 10000100
	await _push_key(scene, _key(KEY_BACKSPACE))
	harness._assert_equal(scene.session.current_field_id, field_before_ui, "A focused LineEdit consumes Backspace without Quick Restart.")
	harness._assert_equal(scene.session.state, RunSessionScript.State.RUNNING, "UI text editing does not alter the active run.")
	harness._assert_equal(scene.input_test.text, "b", "The focused LineEdit performs its own Backspace edit.")
	clock.current_usec = 10000200
	await _push_key(scene, _key(KEY_Z, 122))
	harness._assert_equal(scene.session.current_field_id, field_before_ui, "A focused LineEdit consumes letters without movement.")
	harness._assert_equal(scene.input_test.text, "bz", "The focused LineEdit receives the typed letter.")
	var position_before_canvas_click := scene.session.current_field_id
	await _push_mouse_click(scene, Vector2(1050.0, 520.0))
	harness._assert_true(scene.get_viewport().gui_get_focus_owner() != scene.input_test, "A real click in free gameplay space releases text focus.")
	harness._assert_equal(scene.session.current_field_id, position_before_canvas_click, "The canvas refocus click itself neither starts nor moves the run.")
	var qwertz_z := _key(KEY_Z, 122)
	qwertz_z.physical_keycode = KEY_Y
	clock.current_usec = 10000300
	await _push_key(scene, qwertz_z)
	harness._assert_equal(scene.session.current_field_id, "approach_z", "The scene uses visible Unicode Z even on physical Y.")
	harness._assert_true(not scene.visual_waypoints.is_empty(), "The presentation may still be following valid movement when another input arrives.")
	harness._assert_equal(scene.session.course_identity(), course_identity_before_states, "Visited and reachable presentation state never mutates course identity.")

	clock.current_usec = 10000400
	await _push_key(scene, _key(KEY_BACKSPACE))
	harness._assert_true(scene.visual_waypoints.is_empty(), "Restart during visual movement cancels its old route immediately.")
	harness._assert_equal(scene.visited_field_ids.size(), 1, "Quick Restart clears the old visit trail.")
	harness._assert_true(scene.visited_field_ids.has("start"), "Quick Restart restores only the visited start field.")
	var repeated_backspace := _key(KEY_BACKSPACE)
	repeated_backspace.echo = true
	await _push_key(scene, repeated_backspace)
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Held Backspace echo cannot cascade scene restarts.")
	await _drive_letters_viewport(scene, clock, HandcraftedCourseScript.UPPER_ROUTE, 10001000, 1000)
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "A complete upper run uses the real viewport event path.")
	harness._assert_equal(scene.session.result_count, 1, "The first viewport run produces exactly one core result.")
	harness._assert_equal(scene.completion_view_count, 1, "The first viewport run produces exactly one completion view.")
	var upper_duration := int(scene.session.last_result.get("duration_usec", -1))
	harness._assert_equal(upper_duration, (HandcraftedCourseScript.UPPER_ROUTE.length() - 1) * 1000, "Logical target time is independent of unfinished presentation.")
	harness._assert_equal(scene.timer_label.text, PlayableCourseSceneScript.format_duration_usec(upper_duration), "The HUD freezes on the exact logical result.")
	var result_copy := scene.session.last_result.duplicate(true)
	clock.current_usec += 1000
	await _push_key(scene, _key(KEY_ESCAPE))
	harness._assert_true(scene.menu_panel.visible, "Escape after finish can show the menu response without changing the result.")
	var repeated_escape := _key(KEY_ESCAPE)
	repeated_escape.echo = true
	await _push_key(scene, repeated_escape)
	harness._assert_true(scene.menu_panel.visible, "Held Escape echo cannot close or reopen the response repeatedly.")
	harness._assert_equal(scene.session.last_result, result_copy, "A post-finish menu response preserves the exact result.")
	await _push_key(scene, _key(KEY_ESCAPE))
	clock.current_usec += 1000
	await _push_key(scene, _key(KEY_A, 97))
	scene.simulate_focus_lost(clock.current_usec)
	harness._assert_equal(scene.session.result_count, 1, "Late input and focus loss do not duplicate a finished result.")
	harness._assert_equal(scene.session.last_result, result_copy, "Late presentation and focus events do not mutate a finished result.")
	scene.simulate_focus_gained()

	clock.current_usec += 1000
	await _push_key(scene, _key(KEY_BACKSPACE))
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Viewport Backspace returns a finished attempt to readiness.")
	harness._assert_false(scene.result_label.visible, "Restart does not redisplay the retained old last_result.")
	harness._assert_equal(scene.session.last_result, result_copy, "Restart retains but does not re-emit the prior core result.")
	await _drive_letters_viewport(scene, clock, HandcraftedCourseScript.LOWER_ROUTE, clock.current_usec + 1000, 1000)
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "The complete lower route also uses the scene input path.")
	harness._assert_equal(scene.session.result_count, 2, "Only the second distinct completion increments result count.")
	_scene_cleanup(scene)
	await harness.process_frame


static func _test_lock_restart_menu_and_focus(harness) -> void:
	var fixture := await _scene_fixture(harness)
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]
	clock.current_usec = 100000
	await _push_key(scene, _key(KEY_X, 120))
	harness._assert_equal(scene.session.state, RunSessionScript.State.LOCKED, "A wrong first viewport letter starts the run and lock together.")
	harness._assert_equal(scene.session.error_count, 1, "The scene counts exactly one first-input error.")
	harness._assert_equal(scene.session.lock_until_usec, 300000, "The integrated P1 lock lasts exactly 200,000 microseconds.")
	harness._assert_true(scene.lock_label.visible, "The integrated lock has immediate visible feedback.")
	harness._assert_vector_close(scene.figure.position, scene._anchor_world("start"), 0.0001, "Error feedback reconciles visible and logical positions.")
	harness._assert_true(scene._head_shake_remaining > 0.0, "Error feedback starts the visible asymmetric head-pivot motion.")
	harness._assert_equal(scene.visited_field_ids.size(), 1, "A rejected first letter does not add a visited field.")

	clock.current_usec = 299999
	scene._process(0.0)
	harness._assert_true(scene.lock_label.visible, "The lock indicator remains visible at 199,999 microseconds.")
	await _push_key(scene, _key(KEY_A, 97))
	harness._assert_equal(scene.session.current_field_id, "start", "Input just before the deadline is discarded and not buffered.")
	clock.current_usec = 300000
	scene._process(0.0)
	harness._assert_false(scene.lock_label.visible, "The visible lock expires without requiring another input event.")
	harness._assert_equal(scene.status_label.text, "RUNNING", "The HUD does not retain a misleading LOCKED status after the deadline.")
	await _push_key(scene, _key(KEY_A, 97))
	harness._assert_equal(scene.session.current_field_id, "approach_a", "Input exactly at the deadline is delegated to RunSession and accepted.")
	clock.current_usec = 300001
	await _push_key(scene, _key(KEY_X, 120))
	harness._assert_equal(scene.session.error_count, 2, "A new error one microsecond after release is processed normally.")
	harness._assert_equal(scene.timer_label.text, "00:00.200", "The timer continues through error lock without a second penalty.")

	clock.current_usec = 310000
	await _push_key(scene, _key(KEY_BACKSPACE))
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Quick Restart remains available during error feedback.")
	harness._assert_equal(scene.session.error_count, 0, "Quick Restart clears errors and lock.")
	harness._assert_true(scene.visual_waypoints.is_empty(), "Quick Restart clears every old movement waypoint.")
	harness._assert_equal(scene.figure_head.rotation_degrees, Vector3.ZERO, "Quick Restart cancels old head feedback.")
	harness._assert_vector_close(scene.figure.position, scene._anchor_world("start"), 0.0001, "Quick Restart snaps presentation to the start anchor.")
	clock.current_usec = 311000
	await _push_key(scene, _key(KEY_X, 120))
	scene.simulate_focus_lost(311100)
	harness._assert_equal(scene.session.state, RunSessionScript.State.ABORTED, "Focus loss during error feedback aborts the attempt.")
	harness._assert_equal(scene.session.lock_until_usec, 0, "Focus loss clears the obsolete error deadline.")
	scene.simulate_focus_gained()
	clock.current_usec = 312000
	await _push_key(scene, _key(KEY_BACKSPACE))

	clock.current_usec = 320000
	await _push_key(scene, _key(KEY_ESCAPE))
	harness._assert_true(scene.menu_panel.visible, "Escape before start opens a separate visible menu response.")
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Pre-run Escape neither starts nor resets the session.")
	clock.current_usec = 320001
	await _push_key(scene, _key(KEY_ESCAPE))
	harness._assert_false(scene.menu_panel.visible, "A second Escape closes the pre-run response.")
	clock.current_usec = 321000
	await _push_key(scene, _key(KEY_A, 97))
	var position_before_menu := scene.session.current_field_id
	clock.current_usec = 322000
	await _push_key(scene, _key(KEY_ESCAPE))
	harness._assert_equal(scene.session.state, RunSessionScript.State.INTERRUPTED, "Escape during a run invalidates ranked continuation.")
	harness._assert_equal(scene.session.current_field_id, position_before_menu, "Menu interruption preserves position instead of restarting.")
	clock.current_usec = 323000
	await _push_key(scene, _key(KEY_ESCAPE))
	clock.current_usec = 324000
	await _push_key(scene, _key(KEY_Z, 122))
	harness._assert_equal(scene.session.current_field_id, position_before_menu, "Closing the interruption cannot resume a ranked attempt.")

	clock.current_usec = 330000
	await _push_key(scene, _key(KEY_BACKSPACE))
	clock.current_usec = 331000
	await _push_key(scene, _key(KEY_A, 97))
	clock.current_usec = 332000
	await _push_key(scene, _key(KEY_ESCAPE))
	clock.current_usec = 333000
	await _push_key(scene, _key(KEY_BACKSPACE))
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Backspace starts a new attempt directly from the interruption response.")
	harness._assert_false(scene.menu_panel.visible, "Quick Restart closes the minimal interruption response.")
	clock.current_usec = 340000
	await _push_key(scene, _key(KEY_A, 97))
	scene.simulate_focus_lost(341000)
	harness._assert_equal(scene.session.state, RunSessionScript.State.ABORTED, "Application focus loss reaches the core and aborts a started run.")
	scene.simulate_focus_gained()
	clock.current_usec = 342000
	await _push_key(scene, _key(KEY_Z, 122))
	harness._assert_equal(scene.session.current_field_id, "approach_a", "Focus return neither resumes nor replays movement.")
	clock.current_usec = 350000
	await _push_key(scene, _key(KEY_BACKSPACE))
	scene.simulate_focus_lost(351000)
	harness._assert_equal(scene.session.state, RunSessionScript.State.READY, "Focus loss before the first letter leaves readiness intact.")
	scene.simulate_focus_gained()
	_scene_cleanup(scene)
	await harness.process_frame


static func _test_fast_input_and_presentation_budget(harness) -> void:
	var fixture := await _scene_fixture(harness)
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]
	clock.current_usec = 500000
	var handled_before := scene.handled_event_count
	for index in 50:
		var letter := "A" if index % 2 == 0 else "S"
		scene.get_viewport().push_input(_key(KEY_A if letter == "A" else KEY_S, letter.unicode_at(0)))
	harness._assert_equal(scene.handled_event_count - handled_before, 50, "Fifty scene events are handled without waiting for a render frame.")
	harness._assert_equal(scene.session.current_field_id, "start", "Fifty same-time scene events preserve receipt order.")
	harness._assert_equal(scene.session.elapsed_usec(500000), 0, "The integration adds no frame- or distance-based minimum time.")
	harness._assert_true(scene.visual_waypoints.size() <= PlayableCourseSceneScript.MAX_VISUAL_WAYPOINTS, "The presentation queue has a central finite bound.")
	harness._assert_true(scene.visual_snap_count > 0, "An excessive burst uses the documented immediate correction strategy.")
	var camera_before_zero_delta := scene.camera.global_transform
	scene._update_camera(0.0)
	harness._assert_transform_close(scene.camera.global_transform, camera_before_zero_delta, 0.0001, "Zero delta never reinitializes an already active camera.")
	scene._advance_visual(PlayableCourseSceneScript.MAX_CATCH_UP_SECONDS)
	harness._assert_vector_close(scene.figure.position, scene._anchor_world("start"), 0.0001, "The bounded burst tail follows its remaining route and reaches the logical anchor.")

	clock.current_usec = 510000
	await _push_key(scene, _key(KEY_A, 97))
	clock.current_usec = 511000
	await _push_key(scene, _key(KEY_Z, 122))
	harness._assert_true(not scene.visual_waypoints.is_empty(), "Normal movement follows data transition waypoints.")
	scene._advance_visual(PlayableCourseSceneScript.MAX_CATCH_UP_SECONDS)
	harness._assert_true(scene.visual_waypoints.is_empty(), "Presentation catches up within the central 350 ms budget.")
	harness._assert_vector_close(scene.figure.position, scene._anchor_world(scene.session.current_field_id), 0.0001, "Catch-up ends on the logical data anchor.")
	var camera_before_follow := scene.camera.position
	var focus_before_follow := scene._camera_focus
	var direction_before_follow := -scene.camera.global_basis.z
	scene._update_camera(0.05)
	harness._assert_true(scene.camera.position.distance_to(camera_before_follow) > 0.001, "A small frame advances camera position continuously.")
	harness._assert_true(scene.camera.position.distance_to(scene.camera_target_for_field(scene.session.current_field_id)) > 0.001, "A small frame does not jump straight to the camera goal.")
	harness._assert_true(scene._camera_focus.distance_to(focus_before_follow) > 0.001, "The camera focus advances together with position instead of snapping on input.")
	harness._assert_true(scene._camera_focus.distance_to(scene.camera_focus_for_field(scene.session.current_field_id)) > 0.001, "The smoothed look target remains between its old and new goals after a small frame.")
	harness._assert_true(direction_before_follow.angle_to(-scene.camera.global_basis.z) < deg_to_rad(5.0), "A small follow frame cannot abruptly reorient the camera.")
	var camera_before_error := scene.camera.global_transform
	clock.current_usec = 511100
	scene.get_viewport().push_input(_key(KEY_X, 120))
	harness._assert_transform_close(scene.camera.global_transform, camera_before_error, 0.0001, "An error reconciles the figure without snapping camera position or orientation.")
	await scene.get_tree().process_frame
	scene._update_camera(PlayableCourseSceneScript.CAMERA_CATCH_UP_SECONDS - 0.05)
	harness._assert_vector_close(scene.camera.position, scene.camera_target_for_field(scene.session.current_field_id), 0.0001, "The camera catches up within its central 450 ms budget.")
	harness._assert_vector_close(scene._camera_focus, scene.camera_focus_for_field(scene.session.current_field_id), 0.0001, "The camera look target catches up within the same finite budget.")

	clock.current_usec = 720000
	await _push_key(scene, _key(KEY_BACKSPACE))
	clock.current_usec = 721000
	await _push_key(scene, _key(KEY_A, 97))
	scene._update_camera(0.08)
	var camera_during_forward := scene.camera.global_transform
	clock.current_usec = 722000
	scene.get_viewport().push_input(_key(KEY_S, 115))
	harness._assert_transform_close(scene.camera.global_transform, camera_during_forward, 0.0001, "A rapid return step cannot hard-turn or relocate the camera in the input callback.")
	await scene.get_tree().process_frame
	var direction_before_return_follow := -scene.camera.global_basis.z
	scene._update_camera(0.04)
	harness._assert_true(scene.camera.position.distance_to(scene.camera_target_for_field("start")) > 0.001, "A direction change remains a gradual camera correction.")
	harness._assert_true(direction_before_return_follow.angle_to(-scene.camera.global_basis.z) < deg_to_rad(5.0), "A return follow frame keeps camera orientation continuous.")

	clock.current_usec = 730000
	await _push_key(scene, _key(KEY_BACKSPACE))
	var camera_before_route_burst := scene.camera.global_transform
	for index in HandcraftedCourseScript.UPPER_ROUTE.length():
		clock.current_usec = 731000 + index
		var burst_letter := HandcraftedCourseScript.UPPER_ROUTE.substr(index, 1)
		scene.get_viewport().push_input(_key(burst_letter.unicode_at(0), burst_letter.unicode_at(0)))
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "A complete route burst reaches the logical target before any render frame.")
	harness._assert_transform_close(scene.camera.global_transform, camera_before_route_burst, 0.0001, "A full route burst cannot cut the camera to its final field.")
	scene._update_camera(0.03)
	harness._assert_true(scene.camera.position.distance_to(scene.camera_target_for_field("target")) > 0.001, "The burst camera begins with a continuous partial catch-up step.")
	scene._update_camera(PlayableCourseSceneScript.CAMERA_CATCH_UP_SECONDS - 0.03)
	harness._assert_vector_close(scene.camera.position, scene.camera_target_for_field("target"), 0.0001, "The burst camera reaches its final position at the finite budget boundary.")
	harness._assert_vector_close(scene._camera_focus, scene.camera_focus_for_field("target"), 0.0001, "The burst look target reaches the same finite budget boundary.")

	clock.current_usec = 820000
	await _push_key(scene, _key(KEY_BACKSPACE))
	var start_without_frames := 821000
	for index in 50:
		clock.current_usec = start_without_frames
		var letter := "A" if index % 2 == 0 else "S"
		scene.get_viewport().push_input(_key(KEY_A if letter == "A" else KEY_S, letter.unicode_at(0)))
	await harness.process_frame
	var state_without_frames := [scene.session.current_field_id, scene.session.elapsed_usec(start_without_frames), scene.session.error_count]
	clock.current_usec = 830000
	await _push_key(scene, _key(KEY_BACKSPACE))
	for index in 50:
		clock.current_usec = 831000
		var letter := "A" if index % 2 == 0 else "S"
		await _push_key(scene, _key(KEY_A if letter == "A" else KEY_S, letter.unicode_at(0)))
	var state_with_frames := [scene.session.current_field_id, scene.session.elapsed_usec(831000), scene.session.error_count]
	harness._assert_equal(state_with_frames, state_without_frames, "Different render progress produces the same controlled core state and time.")
	_scene_cleanup(scene)
	await harness.process_frame


static func _scene_fixture(harness) -> Dictionary:
	var packed := load("res://scenes/playable_course.tscn") as PackedScene
	harness._assert_not_null(packed, "The actual playable scene loads as a PackedScene.")
	var scene := packed.instantiate() as PlayableCourseScene
	var clock := MonotonicClockScript.Manual.new()
	scene.configure_for_test(clock)
	harness.root.add_child(scene)
	await harness.process_frame
	harness._assert_true(scene.is_node_ready(), "The integration fixture waits for the real scene _ready lifecycle.")
	harness._assert_true(scene.session != null and scene.session.is_valid(), "The real scene releases only its fully validated course.")
	return {"scene": scene, "clock": clock}


static func _push_key(scene: PlayableCourseScene, event: InputEventKey) -> void:
	scene.get_viewport().push_input(event, true)
	await scene.get_tree().process_frame


static func _push_mouse_click(scene: PlayableCourseScene, position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.global_position = position
	event.pressed = true
	scene.get_viewport().push_input(event, true)
	await scene.get_tree().process_frame
	event = event.duplicate()
	event.pressed = false
	scene.get_viewport().push_input(event, true)
	await scene.get_tree().process_frame


static func _drive_letters_viewport(scene: PlayableCourseScene, clock: MonotonicClock, letters: String, start_usec: int, step_usec: int) -> void:
	for index in letters.length():
		clock.current_usec = start_usec + index * step_usec
		var letter := letters.substr(index, 1)
		await _push_key(scene, _key(letter.unicode_at(0), letter.unicode_at(0)))


static func _drive_letters_direct(session: RunSession, letters: String, received_usec: int) -> void:
	for index in letters.length():
		session.handle_letter(letters.substr(index, 1), received_usec + index)


static func _scene_cleanup(scene: Node) -> void:
	scene.queue_free()


static func _key(keycode: Key, unicode: int = 0) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.unicode = unicode
	event.pressed = true
	return event


static func _branch_clearance(course: CourseData, first_id: String, second_id: String) -> float:
	var first: Dictionary = course.layouts[first_id]
	var second: Dictionary = course.layouts[second_id]
	var first_position := Vector2(float(first["position"][0]), float(first["position"][1]))
	var second_position := Vector2(float(second["position"][0]), float(second["position"][1]))
	var delta := (second_position - first_position).rotated(deg_to_rad(-float(first["rotation_deg"])))
	return absf(delta.y) - (float(first["size"][1]) + float(second["size"][1])) * 0.5
