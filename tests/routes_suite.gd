class_name RoutesSuite
extends RefCounted

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const RouteSectionContractScript = preload("res://scripts/course/route_section_contract.gd")
const QwertzTypingHypothesesScript = preload("res://scripts/course/qwertz_typing_hypotheses.gd")
const RouteMeasurementScript = preload("res://scripts/course/route_measurement.gd")
const CourseDataScript = preload("res://scripts/core/course_data.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const CourseIdentityScript = preload("res://scripts/core/course_identity.gd")
const MonotonicClockScript = preload("res://scripts/core/monotonic_clock.gd")
const RuleProfileScript = preload("res://scripts/core/rule_profile.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")


static func run(harness) -> void:
	print("Running suite: routes")
	_test_authored_sections_and_geometry(harness)
	_test_reference_routes_and_identity(harness)
	_test_typing_hypotheses(harness)
	_test_in_memory_section_measurement(harness)
	await _test_scene_measurement_lifecycle(harness)


static func _test_authored_sections_and_geometry(harness) -> void:
	var course := HandcraftedCourseScript.build()
	var contracts := HandcraftedCourseScript.section_contracts()
	harness._assert_equal(course.fields.size(), 30, "The P2a reference course contains two authored decisions and a shared finale.")
	harness._assert_equal(contracts.size(), 4, "Each alternative route has one small explicit authoring contract.")
	harness._assert_true(CourseValidatorScript.validate(course).is_empty(), "The complete P2a reference course passes graph and layout validation together.")
	harness._assert_true(RouteSectionContractScript.validate(course, contracts).is_empty(), "Every authored section port, footprint and transition is valid.")
	harness._assert_equal(course.neighbor_ids("decision_one").size(), 3, "The first decision keeps one return and two explicit choices.")
	harness._assert_equal(course.neighbor_ids("decision_two").size(), 3, "The second decision keeps one return and two explicit choices.")
	harness._assert_equal(course.neighbor_ids("merge_one").size(), 3, "The first pair visibly reconverges before the next decision.")
	harness._assert_equal(course.neighbor_ids("merge_two").size(), 3, "The second pair visibly reconverges before the shared finale.")
	harness._assert_equal(course.layouts["decision_one"].get("rotation_deg"), 18.0, "The first decision is authored at a non-axis-aligned world orientation.")
	harness._assert_equal(course.layouts["decision_two"].get("rotation_deg"), 18.0, "The second decision retains the same readable slanted course orientation.")
	for pair in [["alpha_short_2", "alpha_long_2"], ["beta_short_2", "beta_long_2"]]:
		harness._assert_false(course.has_edge(pair[0], pair[1]), "Parallel alternatives %s/%s are never inferred as neighbors." % pair)
		harness._assert_true(_branch_clearance(course, pair[0], pair[1]) >= HandcraftedCourseScript.MIN_BRANCH_CLEARANCE - 0.001, "Parallel alternatives %s/%s keep their authored visible clearance." % pair)
	for pair in [["decision_one", "alpha_short_1"], ["decision_one", "alpha_long_1"], ["alpha_short_3", "merge_one"], ["alpha_long_6", "merge_one"], ["decision_two", "beta_short_1"], ["decision_two", "beta_long_1"], ["beta_short_3", "merge_two"], ["beta_long_5", "merge_two"]]:
		harness._assert_true(course.has_edge(pair[0], pair[1]), "Authored port %s/%s has its explicit graph edge." % pair)
		harness._assert_true(_has_transition(course, pair[0], pair[1]), "Authored port %s/%s has matching validated geometry." % pair)

	var missing_port := CourseDataScript.new(course.fields, course.layouts, course.transitions, course.start_id, course.target_id)
	missing_port.transitions.remove_at(3)
	harness._assert_false(RouteSectionContractScript.validate(missing_port, contracts).is_empty(), "A missing authored section transition cannot pass as a raster-only connection.")
	var unsupported_footprint: Array = contracts.duplicate(true)
	unsupported_footprint[0]["spatial_footprint"]["shapes"] = ["circle"]
	harness._assert_false(RouteSectionContractScript.validate(course, unsupported_footprint).is_empty(), "A section cannot silently change its declared authored ground footprint.")


static func _test_reference_routes_and_identity(harness) -> void:
	var course := HandcraftedCourseScript.build()
	var routes := [
		"AZK" + HandcraftedCourseScript.ALPHA_SHORT_SEQUENCE + "MVB" + HandcraftedCourseScript.BETA_SHORT_SEQUENCE + "GYUION",
		"AZK" + HandcraftedCourseScript.ALPHA_SHORT_SEQUENCE + "MVB" + HandcraftedCourseScript.BETA_LONG_SEQUENCE + "GYUION",
		"AZK" + HandcraftedCourseScript.ALPHA_LONG_SEQUENCE + "MVB" + HandcraftedCourseScript.BETA_SHORT_SEQUENCE + "GYUION",
		"AZK" + HandcraftedCourseScript.ALPHA_LONG_SEQUENCE + "MVB" + HandcraftedCourseScript.BETA_LONG_SEQUENCE + "GYUION",
	]
	for letters in routes:
		var session := RunSessionScript.new(course)
		_drive_letters(session, letters, 1000)
		harness._assert_equal(session.state, RunSessionScript.State.FINISHED, "Every combination of the two authored decisions reaches the shared target.")

	var original_identity := CourseIdentityScript.build(course, RuleProfileScript.new())
	var presentation_only := CourseDataScript.new(course.fields, course.layouts, course.transitions, course.start_id, course.target_id)
	presentation_only.layouts["decision_one"]["presentation"] = {"surface_label_rotation_deg": -90.0, "camera_preview": "two_routes"}
	harness._assert_equal(CourseIdentityScript.build(presentation_only, RuleProfileScript.new()), original_identity, "Camera and surface-label presentation metadata never changes a ranked course identity.")
	var changed_layout := CourseDataScript.new(course.fields, course.layouts, course.transitions, course.start_id, course.target_id)
	changed_layout.layouts["alpha_short_2"]["size"][0] = 2.799
	harness._assert_true(CourseIdentityScript.build(changed_layout, RuleProfileScript.new()) != original_identity, "A relevant field-ground change changes the course identity.")


static func _test_typing_hypotheses(harness) -> void:
	var alpha_short := QwertzTypingHypothesesScript.describe(HandcraftedCourseScript.ALPHA_SHORT_SEQUENCE)
	var alpha_long := QwertzTypingHypothesesScript.describe(HandcraftedCourseScript.ALPHA_LONG_SEQUENCE)
	var beta_short := QwertzTypingHypothesesScript.describe(HandcraftedCourseScript.BETA_SHORT_SEQUENCE)
	var beta_long := QwertzTypingHypothesesScript.describe(HandcraftedCourseScript.BETA_LONG_SEQUENCE)
	harness._assert_true(alpha_short["valid"] and alpha_long["valid"] and beta_short["valid"] and beta_long["valid"], "Every displayed P2a candidate is explicitly described for QWERTZ labels.")
	harness._assert_true(int(alpha_short["input_steps"]) < int(alpha_long["input_steps"]), "The first decision distinguishes input-step count, not merely spatial distance.")
	harness._assert_true(int(beta_short["input_steps"]) < int(beta_long["input_steps"]), "The second decision also distinguishes input-step count.")
	harness._assert_true(bool(alpha_long["familiar_sequence_hypothesis"]) and bool(beta_long["familiar_sequence_hypothesis"]), "The longer candidate annotations retain their explicitly tentative familiar-sequence hypothesis.")
	harness._assert_true(int(beta_short["row_changes"]) > int(beta_long["row_changes"]), "The second comparison makes row changes transparent without converting them into a speed claim.")

	var alphabet := QwertzTypingHypothesesScript.describe("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	harness._assert_true(alphabet["valid"], "The transparent QWERTZ lookup covers every A-Z gameplay letter.")
	harness._assert_equal(alphabet["input_steps"], 26, "The complete A-Z QWERTZ description keeps every gameplay letter.")
	var z_key := QwertzTypingHypothesesScript.key_description("Z")
	harness._assert_equal(z_key.get("row"), "top", "QWERTZ Z uses the physical upper-row Y position.")
	harness._assert_equal(z_key.get("hand"), "right", "QWERTZ Z is assigned to the right hand.")
	harness._assert_equal(z_key.get("finger"), "index", "QWERTZ Z is assigned to the right index finger.")
	var y_key := QwertzTypingHypothesesScript.key_description("Y")
	harness._assert_equal(y_key.get("row"), "bottom", "QWERTZ Y uses the physical lower-row Z position.")
	harness._assert_equal(y_key.get("hand"), "left", "QWERTZ Y is assigned to the left hand.")
	harness._assert_equal(y_key.get("finger"), "little", "QWERTZ Y is assigned to the left little finger.")
	var x_key := QwertzTypingHypothesesScript.key_description("X")
	harness._assert_equal(x_key.get("row"), "bottom", "QWERTZ X is present on the lower row.")
	harness._assert_equal(x_key.get("hand"), "left", "QWERTZ X is assigned to the left hand.")
	harness._assert_equal(x_key.get("finger"), "ring", "QWERTZ X is assigned to the left ring finger.")
	var c_key := QwertzTypingHypothesesScript.key_description("C")
	harness._assert_equal(c_key.get("row"), "bottom", "QWERTZ C is present on the lower row.")
	harness._assert_equal(c_key.get("hand"), "left", "QWERTZ C is assigned to the left hand.")
	harness._assert_equal(c_key.get("finger"), "middle", "QWERTZ C is assigned to the left middle finger.")


static func _test_in_memory_section_measurement(harness) -> void:
	var course := HandcraftedCourseScript.build()
	var session := RunSessionScript.new(course)
	var measurement := RouteMeasurementScript.new(HandcraftedCourseScript.section_contracts())
	var received_usec := 1000
	for letter in "AZKF":
		_record_letter(session, measurement, letter, received_usec)
		received_usec += 100
	_record_letter(session, measurement, "X", received_usec)
	received_usec += 200000
	for letter in "JKMVBQWERTGYUION":
		_record_letter(session, measurement, letter, received_usec)
		received_usec += 100
	harness._assert_equal(session.state, RunSessionScript.State.FINISHED, "Measured route observations do not alter the normal completion path.")
	harness._assert_equal(measurement.completed_sections.size(), 2, "One completed section record is retained for each authored decision in this attempt.")
	var alpha: Dictionary = measurement.completed_sections[0]
	var beta: Dictionary = measurement.completed_sections[1]
	harness._assert_equal(alpha["section_id"], "alpha_short_fjk", "The first section record identifies the chosen route.")
	harness._assert_equal(alpha["duration_usec"], 200300, "The first section uses the same received monotonic timestamps, including the actual lock interval.")
	harness._assert_equal(alpha["error_count"], 1, "The first section separates its actual typing error from timing.")
	harness._assert_equal(beta["section_id"], "beta_long_qwert", "The second section record identifies the independently chosen route.")
	harness._assert_equal(beta["error_count"], 0, "The second section keeps its own local error count.")
	harness._assert_true(not measurement.summary_lines().is_empty(), "Route observations remain available to the local result view without persistence.")

	var finished_sections := measurement.completed_sections.duplicate(true)
	var finished_menu := session.request_menu(received_usec)
	measurement.record_session_event(finished_menu, session.current_field_id, session.current_field_id, received_usec)
	harness._assert_equal(session.state, RunSessionScript.State.FINISHED, "Escape after a valid finish does not invalidate the completed run.")
	harness._assert_equal(measurement.completed_sections, finished_sections, "Post-finish Escape preserves the completed route measurements.")

	var interrupted_session := RunSessionScript.new(course)
	var interrupted_measurement := RouteMeasurementScript.new(HandcraftedCourseScript.section_contracts())
	var interrupted_usec := 500000
	for letter in "AZKFJKM":
		_record_letter(interrupted_session, interrupted_measurement, letter, interrupted_usec)
		interrupted_usec += 100
	harness._assert_equal(interrupted_measurement.completed_sections.size(), 1, "A completed section is retained while its overall attempt is still valid.")
	var interrupted_previous := interrupted_session.current_field_id
	var interrupted_event := interrupted_session.request_menu(interrupted_usec)
	interrupted_measurement.record_session_event(interrupted_event, interrupted_previous, interrupted_session.current_field_id, interrupted_usec)
	harness._assert_equal(interrupted_session.state, RunSessionScript.State.INTERRUPTED, "Escape during a running attempt invalidates that attempt.")
	harness._assert_true(interrupted_measurement.completed_sections.is_empty(), "An invalidating Escape discards all section measurements from that attempt.")

	var aborted_session := RunSessionScript.new(course)
	var aborted_measurement := RouteMeasurementScript.new(HandcraftedCourseScript.section_contracts())
	var aborted_usec := 700000
	for letter in "AZKFJKM":
		_record_letter(aborted_session, aborted_measurement, letter, aborted_usec)
		aborted_usec += 100
	harness._assert_equal(aborted_measurement.completed_sections.size(), 1, "A completed section exists before focus invalidation.")
	var aborted_previous := aborted_session.current_field_id
	var aborted_event := aborted_session.handle_focus_lost(aborted_usec)
	aborted_measurement.record_session_event(aborted_event, aborted_previous, aborted_session.current_field_id, aborted_usec)
	harness._assert_equal(aborted_session.state, RunSessionScript.State.ABORTED, "Focus loss invalidates a running attempt.")
	harness._assert_true(aborted_measurement.completed_sections.is_empty(), "Focus invalidation discards all section measurements from that attempt.")


static func _test_scene_measurement_lifecycle(harness) -> void:
	var packed := load("res://scenes/playable_course.tscn") as PackedScene
	harness._assert_not_null(packed, "The route lifecycle regression loads the actual playable scene.")
	if packed == null:
		return
	var scene := packed.instantiate() as PlayableCourseScene
	var clock := MonotonicClockScript.Manual.new()
	scene.configure_for_test(clock, "user://parkey-test-results/routes-measurement-lifecycle", ["routes-lifecycle-finished"], 0)
	harness.root.add_child(scene)
	await harness.process_frame
	harness._assert_not_null(scene.route_measurement, "The actual scene wires its per-attempt route measurement.")

	var received_usec := 1000000
	for letter in "AZKFJKM":
		_record_scene_letter(scene, letter, received_usec)
		received_usec += 100
	harness._assert_equal(scene.route_measurement.completed_sections.size(), 1, "The actual scene records a completed first section before focus loss.")
	scene.simulate_focus_lost(received_usec)
	harness._assert_equal(scene.session.state, RunSessionScript.State.ABORTED, "The actual scene forwards focus loss into the run state.")
	harness._assert_true(scene.route_measurement.completed_sections.is_empty(), "The actual scene forwards focus invalidation into route-measurement cleanup.")
	scene.simulate_focus_gained()

	var previous_field_id := scene.session.current_field_id
	var restart_event := scene.session.quick_restart()
	scene._apply_session_event(restart_event, previous_field_id, received_usec + 100)
	received_usec += 200
	for letter in HandcraftedCourseScript.UPPER_ROUTE:
		_record_scene_letter(scene, letter, received_usec)
		received_usec += 100
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "The actual scene reaches a valid finish after the focus-aborted attempt is restarted.")
	harness._assert_equal(scene.route_measurement.completed_sections.size(), 2, "The finished scene result retains both completed route sections.")
	var completed_before_menu := scene.route_measurement.completed_sections.duplicate(true)
	previous_field_id = scene.session.current_field_id
	var menu_event := scene.session.request_menu(received_usec)
	scene._apply_session_event(menu_event, previous_field_id, received_usec)
	harness._assert_equal(scene.session.state, RunSessionScript.State.FINISHED, "Post-finish Escape in the actual scene preserves the finished state.")
	harness._assert_equal(scene.route_measurement.completed_sections, completed_before_menu, "Post-finish Escape in the actual scene preserves route measurements.")
	harness._assert_true(scene.workshop_hud.route_details.text.contains("Routenmessung (nur dieser Lauf):"), "The developer view retains finished route measurements after Escape.")
	previous_field_id = scene.session.current_field_id
	restart_event = scene.session.quick_restart()
	scene._apply_session_event(restart_event, previous_field_id, received_usec + 100)
	harness._assert_true(scene.route_measurement.completed_sections.is_empty(), "Quick Restart starts the actual scene with fresh route measurements.")

	scene.queue_free()
	await harness.process_frame


static func _record_letter(session: RunSession, measurement: RouteMeasurement, letter: String, received_usec: int) -> void:
	var previous := session.current_field_id
	var event := session.handle_letter(letter, received_usec)
	measurement.record_session_event(event, previous, session.current_field_id, received_usec)


static func _record_scene_letter(scene: PlayableCourseScene, letter: String, received_usec: int) -> void:
	var previous := scene.session.current_field_id
	var event := scene.session.handle_letter(letter, received_usec)
	scene._apply_session_event(event, previous, received_usec)


static func _drive_letters(session: RunSession, letters: String, start_usec: int) -> void:
	for index in letters.length():
		session.handle_letter(letters.substr(index, 1), start_usec + index)


static func _has_transition(course: CourseData, first_id: String, second_id: String) -> bool:
	var wanted := CourseData.edge_key(first_id, second_id)
	for transition in course.transitions:
		if CourseData.edge_key(str(transition.get("from", "")), str(transition.get("to", ""))) == wanted:
			return true
	return false


static func _branch_clearance(course: CourseData, first_id: String, second_id: String) -> float:
	var first: Dictionary = course.layouts[first_id]
	var second: Dictionary = course.layouts[second_id]
	var first_position := Vector2(float(first["position"][0]), float(first["position"][1]))
	var second_position := Vector2(float(second["position"][0]), float(second["position"][1]))
	var delta := (second_position - first_position).rotated(deg_to_rad(-float(first["rotation_deg"])))
	return absf(delta.y) - (float(first["size"][1]) + float(second["size"][1])) * 0.5
