class_name IntegrationSuite
extends RefCounted

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const MonotonicClockScript = preload("res://scripts/core/monotonic_clock.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")
const PlayableCourseSceneScript = preload("res://scripts/playable_course_scene.gd")
const LocalResultStoreScript = preload("res://scripts/storage/local_result_store.gd")

static var _fixture_serial := 0


static func run(harness) -> void:
	print("Running suite: integration")
	_test_handcrafted_course(harness)
	_test_timer_format(harness)
	await _test_scene_input_ui_and_routes(harness)
	await _test_lock_restart_menu_and_focus(harness)
	await _test_fast_input_and_presentation_budget(harness)
	await _test_responsiveness_status_and_surface_labels(harness)
	await _test_local_result_scene_flow(harness)
	await _test_temporary_result_scene_status(harness)


static func _test_handcrafted_course(harness) -> void:
	var course := HandcraftedCourseScript.build()
	harness._assert_equal(course.fields.size(), 30, "The hand-authored P2a course contains two decisions and a shared finale.")
	harness._assert_true(CourseValidatorScript.validate_graph(course).is_empty(), "The actual hand course passes graph validation.")
	harness._assert_true(CourseValidatorScript.validate_layout(course).is_empty(), "The actual hand course passes layout validation.")
	harness._assert_true(CourseValidatorScript.validate(course).is_empty(), "The actual hand course is never partially released.")
	harness._assert_equal(course.neighbor_ids("decision_one").size(), 3, "The first visible decision has a returning edge and two route choices.")
	harness._assert_equal(course.neighbor_ids("decision_two").size(), 3, "The second visible decision has a returning edge and two route choices.")
	harness._assert_equal(course.neighbor_ids("merge_one").size(), 3, "The first route pair visibly merges before the next decision.")
	harness._assert_equal(course.neighbor_ids("merge_two").size(), 3, "The second route pair visibly merges before the finale.")
	harness._assert_equal(course.field_by_id("approach_z").get("letter"), "Z", "The approach contains a reachable Z passage.")
	harness._assert_equal(course.field_by_id("beta_long_1").get("letter"), "Q", "The second decision contains a QWERTZ test passage.")
	harness._assert_true(is_equal_approx(float(course.layouts["alpha_short_1"]["size"][0]), 3.0), "The short candidate includes a moderately wider field.")
	harness._assert_true(is_equal_approx(float(course.layouts["alpha_long_1"]["size"][0]), 1.45), "The longer candidate includes a moderately narrower field.")
	harness._assert_equal(course.layouts["decision_one"].get("rotation_deg"), 18.0, "The course includes a data-authored slanted orientation.")
	harness._assert_true(
		_branch_clearance(course, "alpha_short_2", "alpha_long_2") >= HandcraftedCourseScript.MIN_BRANCH_CLEARANCE - 0.001,
		"The first decision's representative alternatives have a clearly wider separator than a playable transition gap.",
	)
	for pair in [["alpha_short_1", "alpha_long_1"], ["alpha_short_2", "alpha_long_2"], ["beta_short_2", "beta_long_2"]]:
		harness._assert_false(course.has_edge(pair[0], pair[1]), "Separated branch fields %s/%s are explicitly non-neighbors." % pair)
		harness._assert_true(
			_branch_clearance(course, pair[0], pair[1]) >= HandcraftedCourseScript.MIN_BRANCH_CLEARANCE - 0.001,
			"Separated branch fields %s/%s retain the documented visible clearance." % pair,
		)
	for pair in [["decision_one", "alpha_short_1"], ["decision_one", "alpha_long_1"], ["alpha_short_3", "merge_one"], ["alpha_long_6", "merge_one"], ["decision_two", "beta_short_1"], ["decision_two", "beta_long_1"]]:
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
	harness._assert_equal(scene.field_nodes.size(), 30, "The renderer builds every field from CourseData.")
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
	for field_id in ["start", "approach_a"]:
		var surface_label: Label3D = scene.field_nodes[field_id].get_node("Letter")
		harness._assert_true(surface_label.visible, "The primary %s label remains on its own tile." % field_id)
		harness._assert_true(surface_label.position.y < scene.figure_head.position.y, "The primary %s label stays on the keycap instead of floating above the figure." % field_id)
		harness._assert_equal(surface_label.rotation_degrees.y, PlayableCourseSceneScript.SURFACE_LABEL_CLOCKWISE_ROTATION_DEG, "The primary %s label applies the requested clockwise 90-degree surface turn." % field_id)
		harness._assert_equal((scene.field_nodes[field_id] as Node3D).get_node_or_null("LetterCallout"), null, "The old large %s callout is removed." % field_id)
	var course_identity_before_states := scene.session.course_identity()
	var camera_to_start := scene.camera_target_for_field("start") - scene._anchor_world("start")
	harness._assert_true(camera_to_start.dot(scene.course_forward()) < -PlayableCourseSceneScript.CAMERA_DISTANCE + 0.01, "The camera starts behind the figure along the course direction.")
	harness._assert_true(absf(camera_to_start.dot(Vector3(-scene.course_forward().z, 0.0, scene.course_forward().x))) < 0.001, "The rear camera has no isometric side offset.")
	harness._assert_true(scene.camera.projection == Camera3D.PROJECTION_PERSPECTIVE, "The reproducible rear composition uses perspective projection.")
	var viewport_rect := scene.get_viewport().get_visible_rect()
	harness._assert_true(scene.profile_label.get_global_rect().end.x <= viewport_rect.end.x, "The renderer profile stays inside the responsive top bar.")
	harness._assert_true(scene.input_test.get_global_rect().end.y <= viewport_rect.end.y, "The bottom-anchored focus control stays inside the viewport.")
	harness._assert_true(scene.profile_label.clip_contents and scene.profile_label.autowrap_mode != TextServer.AUTOWRAP_OFF, "Long diagnostic profile text wraps and clips inside its assigned HUD region.")

	var decision_layout: Dictionary = scene.course.layouts["decision_one"]
	var decision_node: Node3D = scene.field_nodes["decision_one"]
	harness._assert_vector_close(decision_node.position, PlayableCourseSceneScript.layout_point_to_world(decision_layout["position"]), 0.0001, "Data [x,z] maps to Godot [x,y,z] without mirroring.")
	var expected_axis := Vector3(cos(deg_to_rad(18.0)), 0.0, sin(deg_to_rad(18.0)))
	harness._assert_vector_close(decision_node.basis.x.normalized(), expected_axis, 0.001, "Negative Godot yaw preserves the data profile's positive 2D rotation.")

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
	harness._assert_true(scene.visual_backlog_distance() <= 2.4, "A regular post-focus movement stays within the bounded presentation backlog.")
	harness._assert_equal(scene.session.course_identity(), course_identity_before_states, "Visited and reachable presentation state never mutates course identity.")
	clock.current_usec = 10000350
	await _push_key(scene, _key(KEY_K, 107))
	scene._update_camera(PlayableCourseSceneScript.CAMERA_CATCH_UP_SECONDS)
	var alpha_short_preview := scene._anchor_world("alpha_short_2")
	var alpha_long_preview := scene._anchor_world("alpha_long_3")
	var expected_alpha_preview := (alpha_short_preview + alpha_long_preview) * 0.5
	harness._assert_vector_close(scene._camera_focus, expected_alpha_preview, 0.0001, "The first decision camera focuses the authored midpoint of both options before the next choice.")
	for preview in [alpha_short_preview, alpha_long_preview]:
		harness._assert_false(scene.camera.is_position_behind(preview), "Both first-decision preview anchors remain in front of the automatic rear camera.")
	var beta_short_preview := scene._anchor_world("beta_short_2")
	var beta_long_preview := scene._anchor_world("beta_long_3")
	harness._assert_vector_close(scene.camera_focus_for_field("decision_two"), (beta_short_preview + beta_long_preview) * 0.5, 0.0001, "The second decision uses the same authored two-route preview instead of a hidden camera rule.")

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
	scene.get_viewport().push_input(_key(KEY_A, 97))
	clock.current_usec = 511000
	scene.get_viewport().push_input(_key(KEY_Z, 122))
	harness._assert_true(not scene.visual_waypoints.is_empty(), "Normal movement follows data transition waypoints.")
	scene._advance_visual(PlayableCourseSceneScript.MAX_CATCH_UP_SECONDS)
	harness._assert_true(scene.visual_waypoints.is_empty(), "Presentation catches up within the central bounded budget.")
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
	scene._update_camera(PlayableCourseSceneScript.CAMERA_CATCH_UP_SECONDS - 0.05)
	harness._assert_vector_close(scene.camera.position, scene.camera_target_for_field(scene.session.current_field_id), 0.0001, "The camera catches up within its central bounded budget.")
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
	harness._assert_true(scene.camera.position.distance_to(scene.camera_target_for_field(scene.course.target_id)) > 0.001, "The burst camera begins with a continuous partial catch-up step.")
	scene._update_camera(PlayableCourseSceneScript.CAMERA_CATCH_UP_SECONDS - 0.03)
	harness._assert_vector_close(scene.camera.position, scene.camera_target_for_field(scene.course.target_id), 0.0001, "The burst camera reaches its final position at the finite budget boundary.")
	harness._assert_vector_close(scene._camera_focus, scene.camera_focus_for_field(scene.course.target_id), 0.0001, "The burst look target reaches the same finite budget boundary.")

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


static func _test_responsiveness_status_and_surface_labels(harness) -> void:
	var fixture := await _scene_fixture(harness)
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]

	var standard_colors := scene.field_material_colors("approach_z")
	var start_colors := scene.field_material_colors("start")
	var reachable_colors := scene.field_material_colors("approach_a")
	harness._assert_true(
		(start_colors["surface"] as Color).is_equal_approx((start_colors["keycap"] as Color).darkened(PlayableCourseSceneScript.VISITED_DARKEN_AMOUNT)),
		"The actual visited start surface is a darker version of its own base color.",
	)
	harness._assert_true(
		(reachable_colors["surface"] as Color).is_equal_approx((reachable_colors["keycap"] as Color).lightened(PlayableCourseSceneScript.REACHABLE_LIGHTEN_AMOUNT)),
		"The actual reachable surface is a lighter version of its own base color.",
	)
	harness._assert_true(
		(standard_colors["surface"] as Color).is_equal_approx(standard_colors["keycap"] as Color),
		"An untouched field keeps its unmodified base material color.",
	)
	harness._assert_equal((scene.field_nodes["start"] as Node3D).get_node("StateMarker").text, "● ✓", "The current visited start uses its explicit marker instead of a status hue.")
	harness._assert_equal((scene.field_nodes["approach_a"] as Node3D).get_node("StateMarker").text, "◇", "A reachable unvisited field uses its explicit reachability marker.")

	clock.current_usec = 1000000
	await _push_key(scene, _key(KEY_A, 97))
	var visited_reachable_colors := scene.field_material_colors("start")
	harness._assert_true(
		(visited_reachable_colors["surface"] as Color).is_equal_approx((visited_reachable_colors["keycap"] as Color).lightened(PlayableCourseSceneScript.REACHABLE_LIGHTEN_AMOUNT)),
		"Visited plus reachable uses the lighter reachable base variant, not a third mixed palette.",
	)
	harness._assert_equal((scene.field_nodes["start"] as Node3D).get_node("StateMarker").text, "◇ ✓", "Visited plus reachable preserves the non-color visit signal.")
	var reachable_surface_label: Label3D = scene.field_nodes["approach_z"].get_node("Letter")
	harness._assert_true(reachable_surface_label.visible, "A newly directly reachable field keeps its primary tile-surface label visible.")
	harness._assert_equal((scene.field_nodes["approach_z"] as Node3D).get_node_or_null("LetterCallout"), null, "No large white near-field callout is recreated for a reachable field.")
	# A second authored base color proves that the actual material derivation is
	# relative, not a hidden fixed status palette.
	scene.visited_field_ids[scene.course.target_id] = true
	scene._update_markers()
	var target_colors := scene.field_material_colors(scene.course.target_id)
	harness._assert_true(
		(target_colors["surface"] as Color).is_equal_approx((target_colors["keycap"] as Color).darkened(PlayableCourseSceneScript.VISITED_DARKEN_AMOUNT)),
		"The target's distinct base color also produces its own darker visited material.",
	)

	clock.current_usec = 1200000
	await _push_key(scene, _key(KEY_BACKSPACE))
	var intervals := [0.5, 0.2, 0.125, 0.08, 0.5, 0.08, 0.2, 0.125]
	var letters := HandcraftedCourseScript.RETURN_SAMPLE
	var maximum_backlog := 0.0
	var total_backlog := 0.0
	var measured_frames := 0
	for index in letters.length():
		var interval: float = intervals[index % intervals.size()]
		clock.current_usec += int(interval * 1000000.0)
		var camera_before_input := scene.camera.global_transform
		scene.get_viewport().push_input(_key(letters.unicode_at(index), letters.unicode_at(index)))
		harness._assert_transform_close(scene.camera.global_transform, camera_before_input, 0.0001, "Timed input %d changes no camera transform inside its callback." % index)
		_advance_presentation(scene, 1.0 / 60.0)
		var backlog := scene.visual_backlog_distance()
		maximum_backlog = maxf(maximum_backlog, backlog)
		total_backlog += backlog
		measured_frames += 1
		_advance_presentation(scene, maxf(0.0, interval - 1.0 / 60.0))
		backlog = scene.visual_backlog_distance()
		maximum_backlog = maxf(maximum_backlog, backlog)
		total_backlog += backlog
		measured_frames += 1
	var rest_seconds := _advance_until_visual_caught_up(scene)
	var typical_backlog := total_backlog / float(measured_frames)
	print("P2a regular presentation metrics: max_backlog=%.3f, mean_backlog=%.3f, rest=%.3f, figure_snaps=%d" % [maximum_backlog, typical_backlog, rest_seconds, scene.visual_snap_count])
	harness._assert_true(scene.visual_snap_count == 0, "Timed 500/200/125/80 ms input does not use the burst-only figure correction.")
	harness._assert_true(maximum_backlog <= 3.0, "The controlled P2a sequence stays within its documented visual backlog limit despite moderate tile variation.")
	harness._assert_true(typical_backlog <= 0.7, "The controlled regular sequence keeps typical visual backlog small.")
	harness._assert_true(rest_seconds <= PlayableCourseSceneScript.MAX_CATCH_UP_SECONDS + 0.0001, "Stopping after regular input catches up within the short visual budget.")
	harness._assert_true(scene.visual_waypoints.is_empty(), "The regular timed sequence leaves no deferred movement queue after its bounded rest.")

	var camera_before_error := scene.camera.global_transform
	clock.current_usec += 1000
	scene.get_viewport().push_input(_key(KEY_X, 120))
	harness._assert_transform_close(scene.camera.global_transform, camera_before_error, 0.0001, "An error after timed movement preserves the continuous camera transform in its callback.")
	_scene_cleanup(scene)
	await harness.process_frame


static func _test_local_result_scene_flow(harness) -> void:
	var fixture := await _scene_fixture(harness, ["scene-run-0001", "scene-run-0002"])
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]
	var storage_path: String = fixture["storage_path"]
	var route := HandcraftedCourseScript.UPPER_ROUTE
	await _drive_route_with_duration(scene, clock, route, 1000000, 1234000, false)
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "The real scene creates the completion snapshot at logical target entry.")
	harness._assert_equal(scene._pending_result_snapshots.size(), 1, "A finished result is queued before file work, not written in the input callback.")
	var first_snapshot: Dictionary = scene._pending_result_snapshots[0].duplicate(true)
	clock.current_usec += 1
	scene.get_viewport().push_input(_key(KEY_BACKSPACE))
	clock.current_usec += 1
	scene.get_viewport().push_input(_key(KEY_A, 97))
	await harness.process_frame
	harness._assert_equal(scene.session.state, RunSessionScript.State.RUNNING, "Immediate result-to-restart-to-letter begins a fresh run without a render prerequisite.")
	harness._assert_equal(scene._pending_result_snapshots.size(), 1, "The old immutable save job survives the immediate restart.")
	harness._assert_true(scene.result_store.entries_for_identity(str(first_snapshot["course_identity"])).is_empty(), "No blocking file write is started in the next active run.")

	clock.current_usec += 1
	scene.get_viewport().push_input(_key(KEY_BACKSPACE))
	await _drive_route_with_duration(scene, clock, route, 3000000, 1234999)
	await harness.process_frame
	harness._assert_equal(scene.session.result_count, 2, "Two real scene completions produce two completion events.")
	harness._assert_equal(scene.completion_view_count, 2, "A delayed first save never reopens an old result screen over the newer run.")
	var entries: Array = scene.result_store.entries_for_identity(str(first_snapshot["course_identity"]))
	harness._assert_equal(entries.size(), 2, "Both queued real scene results are persisted after racing has ended.")
	harness._assert_true(entries[0]["run_id"] != entries[1]["run_id"], "Content-identical real scene runs retain distinct immutable IDs.")
	harness._assert_equal(entries[0]["duration_usec"], 1234000, "The faster real-scene run preserves its exact raw microseconds.")
	harness._assert_equal(entries[1]["duration_usec"], 1234999, "The slower real-scene run preserves its different exact raw microseconds.")
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(int(entries[0]["duration_usec"])), PlayableCourseSceneScript.format_duration_usec(int(entries[1]["duration_usec"])), "The differently ranked scene results intentionally share the displayed milliseconds.")
	harness._assert_true(scene.result_label.text.contains("1234999 us"), "The real result-detail UI reveals the current run's exact microseconds when milliseconds collide.")
	harness._assert_true(scene.result_label.text.contains("Rang: 2"), "The real result-detail UI shows the slower raw time's distinct rank.")
	harness._assert_true(scene.leaderboard_label.text.contains("1234000 us"), "The rendered leaderboard makes the faster colliding raw time auditable too.")
	harness._assert_true(scene.leaderboard_label.text.contains("Persoenliche Bestzeit: 00:01.234 (1234000 us)"), "The result panel explains the faster personal best next to a slower display-identical run.")
	harness._assert_true(scene.leaderboard_label.text.contains("Top 10"), "The result panel contains a compact local Top 10.")
	var reloaded := LocalResultStoreScript.new(storage_path, 1)
	var reloaded_report: Dictionary = reloaded.load()
	harness._assert_true(reloaded_report["ok"], "A new store instance reloads the scene's isolated durable results.")
	harness._assert_equal(reloaded.entries_for_identity(str(first_snapshot["course_identity"])).size(), 2, "Reloading does not duplicate scene results.")

	clock.current_usec += 1000
	await _push_key(scene, _key(KEY_ESCAPE))
	scene.simulate_focus_lost(clock.current_usec + 1)
	clock.current_usec += 2
	await _push_key(scene, _key(KEY_BACKSPACE))
	await harness.process_frame
	harness._assert_equal(scene.result_store.entries_for_identity(str(first_snapshot["course_identity"])).size(), 2, "Escape, focus loss and restart after a valid target retain but never duplicate saved results.")
	_scene_cleanup(scene)
	await harness.process_frame


static func _test_temporary_result_scene_status(harness) -> void:
	var fixture := await _scene_fixture(harness, ["scene-run-temporary"], 0)
	var scene: PlayableCourseScene = fixture["scene"]
	var clock: MonotonicClock = fixture["clock"]
	var storage_path: String = fixture["storage_path"]
	await _drive_letters_viewport(scene, clock, HandcraftedCourseScript.UPPER_ROUTE, 2000000, 1000)
	await harness.process_frame
	harness._assert_equal(scene.result_store.status, LocalResultStoreScript.Status.TEMPORARY, "The real result panel receives the restricted-storage state.")
	harness._assert_true(scene.storage_label.text.contains("temporaer"), "Restricted storage has an explicit temporary result-panel message.")
	harness._assert_false(FileAccess.file_exists(storage_path.path_join("results-v1.json")), "Temporary scene mode creates no deceptive durable result file.")
	_scene_cleanup(scene)
	await harness.process_frame


static func _scene_fixture(harness, scripted_run_ids: Array = [], persistent_override: int = 1) -> Dictionary:
	var packed := load("res://scenes/playable_course.tscn") as PackedScene
	harness._assert_not_null(packed, "The actual playable scene loads as a PackedScene.")
	var scene := packed.instantiate() as PlayableCourseScene
	var clock := MonotonicClockScript.Manual.new()
	_fixture_serial += 1
	var storage_path := "user://parkey-test-results/integration-%d" % _fixture_serial
	_remove_test_storage(storage_path)
	scene.configure_for_test(clock, storage_path, scripted_run_ids, persistent_override)
	harness.root.add_child(scene)
	await harness.process_frame
	harness._assert_true(scene.is_node_ready(), "The integration fixture waits for the real scene _ready lifecycle.")
	harness._assert_true(scene.session != null and scene.session.is_valid(), "The real scene releases only its fully validated course.")
	return {"scene": scene, "clock": clock, "storage_path": storage_path}


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


static func _drive_route_with_duration(scene: PlayableCourseScene, clock: MonotonicClock, letters: String, start_usec: int, duration_usec: int, process_final_input: bool = true) -> void:
	for index in letters.length():
		clock.current_usec = start_usec + (duration_usec if index == letters.length() - 1 else index * 1000)
		var letter := letters.substr(index, 1)
		var event := _key(letter.unicode_at(0), letter.unicode_at(0))
		if index == letters.length() - 1 and not process_final_input:
			scene.get_viewport().push_input(event)
		else:
			await _push_key(scene, event)


static func _drive_letters_direct(session: RunSession, letters: String, received_usec: int) -> void:
	for index in letters.length():
		session.handle_letter(letters.substr(index, 1), received_usec + index)


static func _advance_presentation(scene: PlayableCourseScene, seconds: float) -> void:
	var remaining := seconds
	while remaining > 0.000001:
		var step := minf(1.0 / 60.0, remaining)
		scene._advance_visual(step)
		scene._advance_head_shake(step)
		scene._update_camera(step)
		remaining -= step


static func _advance_until_visual_caught_up(scene: PlayableCourseScene) -> float:
	var elapsed := 0.0
	while not scene.visual_waypoints.is_empty() and elapsed <= PlayableCourseSceneScript.MAX_CATCH_UP_SECONDS + 0.02:
		_advance_presentation(scene, 1.0 / 600.0)
		elapsed += 1.0 / 600.0
	return elapsed


static func _scene_cleanup(scene: Node) -> void:
	var storage_path := ""
	if scene is PlayableCourseScene:
		storage_path = scene._storage_base_path
	scene.queue_free()
	if not storage_path.is_empty():
		_remove_test_storage(storage_path)


static func _remove_test_storage(storage_path: String) -> void:
	if not storage_path.begins_with("user://parkey-test-results/"):
		return
	var absolute := ProjectSettings.globalize_path(storage_path)
	for file_name in ["results-v1.json", "results-v1.json.tmp", "results-v1.json.bak"]:
		DirAccess.remove_absolute(absolute.path_join(file_name))
	DirAccess.remove_absolute(absolute)


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
