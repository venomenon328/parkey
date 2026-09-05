class_name CoreSuite
extends RefCounted

const CourseDataScript = preload("res://scripts/core/course_data.gd")
const CourseValidatorScript = preload("res://scripts/core/course_validator.gd")
const CourseIdentityScript = preload("res://scripts/core/course_identity.gd")
const RuleProfileScript = preload("res://scripts/core/rule_profile.gd")
const MonotonicClockScript = preload("res://scripts/core/monotonic_clock.gd")
const RunSessionScript = preload("res://scripts/core/run_session.gd")
const RunInputAdapterScript = preload("res://scripts/input/run_input_adapter.gd")


static func run(harness) -> void:
	print("Running suite: core")
	_test_course_validation(harness)
	_test_layout_validation_and_identity(harness)
	_test_start_errors_and_boundaries(harness)
	_test_fast_ordered_steps(harness)
	_test_restart_menu_focus_and_result(harness)
	_test_input_adapter_and_clock(harness)


static func _test_course_validation(harness) -> void:
	var valid := _basic_course()
	harness._assert_true(CourseValidatorScript.validate_graph(valid).is_empty(), "A valid explicit graph passes graph validation.")
	harness._assert_true(CourseValidatorScript.validate_layout(valid).is_empty(), "A valid separated layout passes layout validation.")
	harness._assert_true(CourseValidatorScript.validate(valid).is_empty(), "Both validators must pass before a session is ready.")

	var duplicate_neighbors := _basic_course()
	duplicate_neighbors.fields[0]["neighbors"] = ["middle", "middle"]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_graph(duplicate_neighbors), "repeats neighbor"), "Duplicate edges are rejected.")
	var malformed_neighbors := _basic_course()
	malformed_neighbors.fields[0]["neighbors"] = 42
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_graph(malformed_neighbors), "must have a neighbors array"), "Malformed neighbor data returns a validation error instead of raising a runtime error.")

	var asymmetric := _basic_course()
	asymmetric.fields[1]["neighbors"] = ["target"]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_graph(asymmetric), "not symmetric"), "P1 edges must be symmetric.")

	var aba := CourseDataScript.new([
		{"id": "first", "letter": "A", "neighbors": ["middle"]},
		{"id": "middle", "letter": "B", "neighbors": ["first", "last"]},
		{"id": "last", "letter": "A", "neighbors": ["middle"]},
	], {}, [], "first", "last")
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_graph(aba), "duplicate reachable letter 'A'"), "A-B-A is rejected at the middle field.")

	var five_neighbors := _five_neighbor_graph()
	harness._assert_true(CourseValidatorScript.validate_graph(five_neighbors).is_empty(), "Five uniquely labelled neighbors and variable degree are accepted.")
	harness._assert_equal(five_neighbors.neighbor_ids("hub").size(), 5, "The core has no four-neighbor limit.")


static func _test_layout_validation_and_identity(harness) -> void:
	var valid := _basic_course()
	var corner_contact := _corner_contact_course()
	harness._assert_true(CourseValidatorScript.validate(corner_contact).is_empty(), "Corner contact without an explicit edge is not an automatic connection.")
	var angled_split := _angled_split_connection_course()
	harness._assert_true(CourseValidatorScript.validate(angled_split).is_empty(), "A larger rotated field can have readable slanted transitions to multiple smaller neighbors.")

	var missing_transition := _basic_course()
	missing_transition.transitions.clear()
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(missing_transition), "has no readable layout transition"), "Every graph edge needs an explicit layout transition.")

	var visible_without_edge := _basic_course()
	visible_without_edge.transitions.append({
		"from": "start", "to": "target",
		"from_edge": [[-1.0, -0.5], [-1.0, 0.5]],
		"to_edge": [[3.1, -0.5], [3.1, 0.5]],
	})
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(visible_without_edge), "has no explicit graph edge"), "A visible transition without a data edge is rejected.")

	var overlap := _basic_course()
	overlap.layouts["middle"]["position"] = [0.0, 0.0]
	overlap.layouts["middle"]["anchor"] = [0.0, 0.0]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(overlap), "overlap"), "Unintended field overlap is rejected.")

	var bad_anchor := _basic_course()
	bad_anchor.layouts["middle"]["anchor"] = [20.0, 0.0]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(bad_anchor), "anchor is outside"), "A stand or landing anchor must be on its field.")
	var unquantized := _basic_course()
	unquantized.transitions[0]["to_edge"] = [[1.1005, -0.5], [1.1005, 0.5]]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(unquantized), "must use 0.001 precision"), "Layout transition data has a documented canonical precision.")

	var wide_gap := _basic_course()
	wide_gap.layouts["middle"]["position"] = [2.3, 0.0]
	wide_gap.layouts["middle"]["anchor"] = [2.3, 0.0]
	wide_gap.layouts["target"]["position"] = [4.6, 0.0]
	wide_gap.layouts["target"]["anchor"] = [4.6, 0.0]
	wide_gap.transitions[0]["to_edge"] = [[1.3, -0.5], [1.3, 0.5]]
	wide_gap.transitions[1]["from_edge"] = [[3.3, -0.5], [3.3, 0.5]]
	wide_gap.transitions[1]["to_edge"] = [[3.6, -0.5], [3.6, 0.5]]
	harness._assert_true(_errors_contain(CourseValidatorScript.validate_layout(wide_gap), "gap exceeds"), "A graph edge with an unreadably large gap is rejected.")

	var profile := RuleProfileScript.new()
	var original_id := CourseIdentityScript.build(valid, profile)
	var material_variant := _basic_course()
	material_variant.layouts["middle"]["material"] = "warm-oak"
	harness._assert_equal(CourseIdentityScript.build(material_variant, profile), original_id, "Material changes are cosmetic and keep the course identity.")
	var relevant_variant := _basic_course()
	relevant_variant.layouts["middle"]["size"] = [2.2, 2.0]
	relevant_variant.transitions[0]["to_edge"] = [[1.0, -0.5], [1.0, 0.5]]
	relevant_variant.transitions[1]["from_edge"] = [[3.2, -0.5], [3.2, 0.5]]
	relevant_variant.transitions[1]["to_edge"] = [[3.2, -0.5], [3.2, 0.5]]
	harness._assert_true(CourseValidatorScript.validate(relevant_variant).is_empty(), "A different moderate, valid layout stays playable.")
	harness._assert_false(CourseIdentityScript.build(relevant_variant, profile) == original_id, "Relevant layout data changes the course identity.")
	var original_session := RunSessionScript.new(valid)
	var varied_session := RunSessionScript.new(relevant_variant)
	original_session.handle_letter("A", 100)
	varied_session.handle_letter("A", 100)
	original_session.handle_letter("T", 300)
	varied_session.handle_letter("T", 300)
	harness._assert_equal(varied_session.last_result.get("duration_usec"), original_session.last_result.get("duration_usec"), "Different valid layouts keep the same input/time result.")
	var changed_profile := RuleProfileScript.new("p1-input-start-v2", 2, 250000)
	harness._assert_false(CourseIdentityScript.build(valid, changed_profile) == original_id, "Rule profile changes separate identities.")


static func _test_start_errors_and_boundaries(harness) -> void:
	var waiting := RunSessionScript.new(_basic_course())
	harness._assert_equal(waiting.elapsed_usec(9999999), 0, "Readiness never starts the timer by waiting.")
	harness._assert_equal(waiting.current_field_id, "start", "A validated session starts at the configured start field.")

	var first_valid := RunSessionScript.new(_basic_course())
	var move := first_valid.handle_letter("A", 1000)
	harness._assert_equal(move.get("kind"), "moved", "The first valid letter starts and moves in the same event.")
	harness._assert_equal(first_valid.start_usec, 1000, "The first letter receipt time is the start time.")
	harness._assert_equal(first_valid.current_field_id, "middle", "The first letter reaches its neighbor immediately.")

	var one_step := RunSessionScript.new(_one_step_course())
	var finished := one_step.handle_letter("T", 5000)
	harness._assert_equal(finished.get("kind"), "finished", "A first-letter target is processed immediately.")
	harness._assert_equal(one_step.last_result.get("duration_usec"), 0, "A controlled one-step target may take zero microseconds.")

	var first_error := RunSessionScript.new(_basic_course())
	var error_event := first_error.handle_letter("X", 1000)
	harness._assert_equal(error_event.get("kind"), "error", "A wrong first letter starts and fails in the same event.")
	harness._assert_equal(first_error.start_usec, 1000, "A wrong first letter also starts the clock.")
	harness._assert_equal(first_error.error_count, 1, "A wrong first letter adds exactly one error.")
	harness._assert_equal(first_error.lock_until_usec, 201000, "The P1 lock lasts exactly 200000 microseconds.")
	harness._assert_equal(first_error.handle_letter("A", 200999).get("kind"), "error_locked", "Input at 199999 microseconds is discarded.")
	harness._assert_equal(first_error.error_count, 1, "Discarded locked input does not add errors.")
	harness._assert_equal(first_error.handle_letter("A", 201000).get("kind"), "moved", "Input at exactly the deadline is accepted.")
	harness._assert_equal(first_error.current_field_id, "middle", "The deadline input is not buffered before release.")
	harness._assert_equal(first_error.handle_letter("X", 201001).get("kind"), "error", "A new error just after release starts a new lock.")
	harness._assert_equal(first_error.error_count, 2, "A post-deadline error is counted normally.")
	harness._assert_equal(first_error.elapsed_usec(250000), 249000, "The timer runs through the error pause without added penalty.")


static func _test_fast_ordered_steps(harness) -> void:
	var session := RunSessionScript.new(_basic_course())
	var next_letter := "A"
	for index in 50:
		var event := session.handle_letter(next_letter, 7000)
		harness._assert_equal(event.get("kind"), "moved", "Ordered valid input %d is processed without a render wait." % (index + 1))
		next_letter = "S" if next_letter == "A" else "A"
	harness._assert_equal(session.current_field_id, "start", "Fifty same-timestamp inputs retain receipt order.")
	harness._assert_equal(session.elapsed_usec(7000), 0, "Same receipt timestamps add no artificial time.")
	harness._assert_equal(session.handle_letter("A", 6999).get("kind"), "non_monotonic_time", "The injected clock rejects decreasing timestamps.")


static func _test_restart_menu_focus_and_result(harness) -> void:
	var session := RunSessionScript.new(_basic_course())
	session.handle_letter("A", 100)
	session.handle_letter("X", 200)
	harness._assert_equal(session.quick_restart().get("kind"), "restarted", "Quick Restart is a separate explicit action.")
	harness._assert_equal(session.state, RunSessionScript.State.READY, "Restart returns to readiness, not a countdown.")
	harness._assert_equal(session.current_field_id, "start", "Restart returns to start.")
	harness._assert_equal(session.error_count, 0, "Restart clears errors.")
	harness._assert_equal(session.lock_until_usec, 0, "Restart clears the old lock.")
	harness._assert_equal(session.elapsed_usec(9999), 0, "Restart resets elapsed time.")

	var menu_ready := RunSessionScript.new(_basic_course())
	menu_ready.request_menu(10)
	harness._assert_equal(menu_ready.state, RunSessionScript.State.READY, "Opening a menu before a run does not start or reset a run.")
	harness._assert_equal(menu_ready.handle_letter("A", 11).get("kind"), "menu_open", "An accepted menu interruption blocks movement.")
	menu_ready.close_menu()
	harness._assert_equal(menu_ready.handle_letter("A", 12).get("kind"), "moved", "Closing a pre-run menu returns to readiness.")

	var menu_running := RunSessionScript.new(_basic_course())
	menu_running.handle_letter("A", 100)
	menu_running.request_menu(150)
	harness._assert_equal(menu_running.state, RunSessionScript.State.INTERRUPTED, "Menu interruption is not Quick Restart.")
	harness._assert_equal(menu_running.current_field_id, "middle", "Menu interruption preserves position instead of resetting it.")
	menu_running.close_menu()
	harness._assert_equal(menu_running.handle_letter("T", 151).get("kind"), "terminal_state", "An interrupted attempt cannot resume as a ranked run.")
	harness._assert_equal(menu_running.quick_restart().get("kind"), "restarted", "A new ranked attempt requires Quick Restart.")

	var focus := RunSessionScript.new(_basic_course())
	focus.handle_focus_lost(1)
	harness._assert_equal(focus.state, RunSessionScript.State.READY, "Focus loss before a first letter creates no attempt.")
	focus.handle_letter("A", 10)
	focus.handle_focus_lost(11)
	harness._assert_equal(focus.state, RunSessionScript.State.ABORTED, "Focus loss during a run aborts it.")
	harness._assert_equal(focus.handle_letter("T", 12).get("kind"), "terminal_state", "Focus return does not auto-resume an aborted run.")

	var completed := RunSessionScript.new(_one_step_course())
	completed.handle_letter("T", 123)
	var preserved_result: Dictionary = completed.last_result.duplicate(true)
	completed.handle_focus_lost(124)
	completed.request_menu(125)
	completed.quick_restart()
	completed.handle_letter("T", 126)
	harness._assert_equal(completed.result_count, 2, "Only distinct completed attempts create results.")
	harness._assert_equal(preserved_result.get("duration_usec"), 0, "Later focus, menu and restart do not mutate a completed result.")


static func _test_input_adapter_and_clock(harness) -> void:
	var qwertz_z := _key(KEY_Z, 122)
	qwertz_z.physical_keycode = KEY_Y
	var normalized := RunInputAdapterScript.normalize(qwertz_z)
	harness._assert_equal(normalized.get("action"), "letter", "The P1 adapter uses the existing Unicode normalizer.")
	harness._assert_equal(normalized.get("letter"), "Z", "QWERTZ physical Y still produces visible Z.")

	var shifted := _key(KEY_A, 65)
	shifted.shift_pressed = true
	harness._assert_equal(RunInputAdapterScript.normalize(shifted).get("letter"), "A", "Shift only changes case, not the movement letter.")
	var echo := _key(KEY_A, 65)
	echo.echo = true
	harness._assert_equal(RunInputAdapterScript.normalize(echo).get("reason"), "echo", "Echoes cannot create movement or control cascades.")
	var key_up := _key(KEY_A, 65, false)
	harness._assert_equal(RunInputAdapterScript.normalize(key_up).get("reason"), "key_up", "Key-up is ignored.")
	var shortcut := _key(KEY_A, 65)
	shortcut.ctrl_pressed = true
	harness._assert_equal(RunInputAdapterScript.normalize(shortcut).get("reason"), "shortcut_modifier", "Shortcuts stay outside gameplay.")
	harness._assert_equal(RunInputAdapterScript.normalize(_key(KEY_BACKSPACE), true, true).get("reason"), "ui_text_input", "UI text input keeps Backspace.")
	harness._assert_equal(RunInputAdapterScript.normalize(_key(KEY_ESCAPE), false).get("reason"), "outside_game_context", "Non-game contexts suppress menu requests.")
	harness._assert_equal(RunInputAdapterScript.normalize(_key(KEY_BACKSPACE)).get("action"), "quick_restart", "Backspace maps to Quick Restart.")
	harness._assert_equal(RunInputAdapterScript.normalize(_key(KEY_ESCAPE)).get("action"), "menu_request", "Escape maps to the separate menu request.")
	var dispatched := RunSessionScript.new(_basic_course())
	harness._assert_equal(RunInputAdapterScript.dispatch(dispatched, _key(KEY_A, 65), 20).get("kind"), "moved", "The real adapter forwards a movement event to the session.")
	harness._assert_equal(RunInputAdapterScript.dispatch(dispatched, _key(KEY_BACKSPACE), 21).get("kind"), "restarted", "The real adapter forwards Backspace only as Quick Restart.")
	var repeated_backspace := _key(KEY_BACKSPACE)
	repeated_backspace.echo = true
	harness._assert_equal(RunInputAdapterScript.dispatch(dispatched, repeated_backspace, 22).get("kind"), "ignored", "A held Backspace cannot restart repeatedly.")
	harness._assert_equal(RunInputAdapterScript.dispatch(dispatched, _key(KEY_ESCAPE), 23).get("kind"), "menu_requested", "The real adapter forwards Escape only as a menu request.")

	var clock := MonotonicClockScript.Manual.new()
	clock.current_usec = 400
	var clocked := RunSessionScript.new(_one_step_course(), RuleProfileScript.new(), clock)
	harness._assert_equal(clocked.handle_letter("T").get("kind"), "finished", "The session can use an injected monotonic clock.")
	harness._assert_equal(clocked.last_result.get("duration_usec"), 0, "Clock injection uses one value for start and first step.")


static func _basic_course() -> CourseData:
	return CourseDataScript.new(
		[
			{"id": "start", "letter": "S", "neighbors": ["middle"]},
			{"id": "middle", "letter": "A", "neighbors": ["start", "target"]},
			{"id": "target", "letter": "T", "neighbors": ["middle"]},
		],
		{
			"start": _rectangle([0.0, 0.0], [2.0, 2.0]),
			"middle": _rectangle([2.1, 0.0], [2.0, 2.0]),
			"target": _rectangle([4.2, 0.0], [2.0, 2.0]),
		},
		[
			_transition("start", "middle", [[1.0, -0.5], [1.0, 0.5]], [[1.1, -0.5], [1.1, 0.5]]),
			_transition("middle", "target", [[3.1, -0.5], [3.1, 0.5]], [[3.2, -0.5], [3.2, 0.5]]),
		],
		"start", "target",
	)


static func _one_step_course() -> CourseData:
	return CourseDataScript.new(
		[
			{"id": "start", "letter": "S", "neighbors": ["target"]},
			{"id": "target", "letter": "T", "neighbors": ["start"]},
		],
		{"start": _rectangle([0.0, 0.0], [2.0, 2.0]), "target": _rectangle([2.1, 0.0], [2.0, 2.0])},
		[_transition("start", "target", [[1.0, -0.5], [1.0, 0.5]], [[1.1, -0.5], [1.1, 0.5]])],
		"start", "target",
	)


static func _five_neighbor_graph() -> CourseData:
	return CourseDataScript.new([
		{"id": "hub", "letter": "H", "neighbors": ["a", "b", "c", "d", "e"]},
		{"id": "a", "letter": "A", "neighbors": ["hub"]},
		{"id": "b", "letter": "B", "neighbors": ["hub"]},
		{"id": "c", "letter": "C", "neighbors": ["hub"]},
		{"id": "d", "letter": "D", "neighbors": ["hub"]},
		{"id": "e", "letter": "E", "neighbors": ["hub"]},
	], {}, [], "hub", "a")


static func _corner_contact_course() -> CourseData:
	return CourseDataScript.new(
		[
			{"id": "start", "letter": "S", "neighbors": ["east", "north"]},
			{"id": "east", "letter": "E", "neighbors": ["start"]},
			{"id": "north", "letter": "N", "neighbors": ["start"]},
		],
		{
			"start": _rectangle([0.0, 0.0], [2.0, 2.0]),
			"east": _rectangle([2.0, 0.0], [2.0, 2.0]),
			"north": _rectangle([0.0, 2.0], [2.0, 2.0]),
		},
		[
			_transition("start", "east", [[1.0, -0.5], [1.0, 0.5]], [[1.0, -0.5], [1.0, 0.5]]),
			_transition("start", "north", [[-0.5, 1.0], [0.5, 1.0]], [[-0.5, 1.0], [0.5, 1.0]]),
		],
		"start", "east",
	)


static func _angled_split_connection_course() -> CourseData:
	return CourseDataScript.new(
		[
			{"id": "hub", "letter": "H", "neighbors": ["lower", "upper"]},
			{"id": "lower", "letter": "A", "neighbors": ["hub"]},
			{"id": "upper", "letter": "B", "neighbors": ["hub"]},
		],
		{
			"hub": _rectangle([0.0, 0.0], [4.0, 4.0], 30.0),
			"lower": _rectangle([2.708, 0.409], [1.0, 1.5], 30.0),
			"upper": _rectangle([1.708, 2.141], [1.0, 1.5], 30.0),
		},
		[
			_transition("hub", "lower", [[2.607, -0.516], [1.857, 0.783]], [[2.650, -0.491], [1.900, 0.808]]),
			_transition("hub", "upper", [[1.607, 1.217], [0.857, 2.516]], [[1.650, 1.242], [0.900, 2.541]]),
		],
		"lower", "upper",
	)


static func _rectangle(position: Array, size: Array, rotation_deg: float = 0.0) -> Dictionary:
	return {"shape": "rectangle", "position": position, "size": size, "rotation_deg": rotation_deg, "anchor": position.duplicate()}


static func _transition(first_id: String, second_id: String, first_edge: Array, second_edge: Array) -> Dictionary:
	return {"from": first_id, "to": second_id, "from_edge": first_edge, "to_edge": second_edge}


static func _key(keycode: Key, unicode: int = 0, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.unicode = unicode
	event.pressed = pressed
	return event


static func _errors_contain(errors: Array, needle: String) -> bool:
	for error in errors:
		if str(error).contains(needle):
			return true
	return false
