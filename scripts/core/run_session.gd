class_name RunSession
extends RefCounted

const CourseValidator = preload("res://scripts/core/course_validator.gd")
const CourseIdentity = preload("res://scripts/core/course_identity.gd")

enum State { INVALID, READY, RUNNING, LOCKED, INTERRUPTED, ABORTED, FINISHED }

var course: CourseData
var profile: RuleProfile
var clock: MonotonicClock
var validation_errors: Array[String] = []
var state := State.INVALID
var current_field_id := ""
var start_usec := 0
var lock_until_usec := 0
var error_count := 0
var last_received_usec := -1
var menu_open := false
var attempt_ranked := false
var last_result: Dictionary = {}
var result_count := 0
var interruption_elapsed_usec := 0


func _init(new_course: CourseData, new_profile: RuleProfile = null, new_clock: MonotonicClock = null) -> void:
	course = new_course
	profile = new_profile if new_profile != null else RuleProfile.new()
	clock = new_clock if new_clock != null else MonotonicClock.new()
	validation_errors = CourseValidator.validate(course)
	if validation_errors.is_empty():
		_prepare_ready()


func is_valid() -> bool:
	return validation_errors.is_empty()


func course_identity() -> String:
	return CourseIdentity.build(course, profile)


func elapsed_usec(received_usec: int = -1) -> int:
	var now_usec := _resolve_time(received_usec)
	if state == State.RUNNING or state == State.LOCKED:
		return max(0, now_usec - start_usec)
	if state == State.FINISHED:
		return int(last_result.get("duration_usec", 0))
	if state == State.INTERRUPTED or state == State.ABORTED:
		return interruption_elapsed_usec
	return 0


func process_action(action: Dictionary, received_usec: int = -1) -> Dictionary:
	var kind := str(action.get("action", "ignored"))
	if kind == "letter":
		return handle_letter(str(action.get("letter", "")), received_usec)
	if kind == "quick_restart":
		return quick_restart()
	if kind == "menu_request":
		return request_menu(received_usec)
	return _event("ignored", received_usec)


func handle_letter(raw_letter: String, received_usec: int = -1) -> Dictionary:
	var now_usec := _resolve_time(received_usec)
	if not _accept_time(now_usec):
		return _event("non_monotonic_time", now_usec)
	if menu_open:
		return _event("menu_open", now_usec)
	if state == State.INVALID:
		return _event("invalid_course", now_usec)
	if state == State.INTERRUPTED or state == State.ABORTED or state == State.FINISHED:
		return _event("terminal_state", now_usec)
	if state == State.LOCKED:
		if now_usec < lock_until_usec:
			return _event("error_locked", now_usec)
		state = State.RUNNING
		lock_until_usec = 0
	var letter := raw_letter.to_upper()
	if not _is_letter(letter):
		return _event("ignored", now_usec)
	if state == State.READY:
		start_usec = now_usec
		state = State.RUNNING
		attempt_ranked = true
	var next_field_id := course.neighbor_for_letter(current_field_id, letter)
	if next_field_id.is_empty():
		error_count += 1
		lock_until_usec = now_usec + profile.error_lock_usec
		state = State.LOCKED
		return _event("error", now_usec)
	current_field_id = next_field_id
	if current_field_id == course.target_id:
		state = State.FINISHED
		lock_until_usec = 0
		var result := {
			"course_identity": course_identity(),
			"rule_profile_id": profile.profile_id,
			"duration_usec": max(0, now_usec - start_usec),
			"error_count": error_count,
			"ranked": attempt_ranked,
		}
		last_result = result
		result_count += 1
		return _event("finished", now_usec)
	return _event("moved", now_usec)


func quick_restart() -> Dictionary:
	if state == State.INVALID:
		return _event("invalid_course")
	_prepare_ready()
	return _event("restarted")


func request_menu(received_usec: int = -1) -> Dictionary:
	var now_usec := _resolve_time(received_usec)
	if not _accept_time(now_usec):
		return _event("non_monotonic_time", now_usec)
	menu_open = true
	if state == State.RUNNING or state == State.LOCKED:
		interruption_elapsed_usec = max(0, now_usec - start_usec)
		state = State.INTERRUPTED
		lock_until_usec = 0
		attempt_ranked = false
	return _event("menu_requested", now_usec)


func close_menu() -> Dictionary:
	menu_open = false
	return _event("menu_closed")


func handle_focus_lost(received_usec: int = -1) -> Dictionary:
	var now_usec := _resolve_time(received_usec)
	if not _accept_time(now_usec):
		return _event("non_monotonic_time", now_usec)
	if state == State.RUNNING or state == State.LOCKED:
		interruption_elapsed_usec = max(0, now_usec - start_usec)
		state = State.ABORTED
		lock_until_usec = 0
		attempt_ranked = false
	return _event("focus_lost", now_usec)


func _prepare_ready() -> void:
	state = State.READY
	current_field_id = course.start_id
	start_usec = 0
	lock_until_usec = 0
	error_count = 0
	last_received_usec = -1
	menu_open = false
	attempt_ranked = false
	interruption_elapsed_usec = 0


func _resolve_time(received_usec: int) -> int:
	return clock.now_usec() if received_usec < 0 else received_usec


func _accept_time(now_usec: int) -> bool:
	if now_usec < last_received_usec:
		return false
	last_received_usec = now_usec
	return true


func _event(kind: String, received_usec: int = -1) -> Dictionary:
	var now_usec := _resolve_time(received_usec)
	return {
		"kind": kind,
		"state": state,
		"field_id": current_field_id,
		"elapsed_usec": elapsed_usec(now_usec),
		"error_count": error_count,
		"lock_until_usec": lock_until_usec,
		"menu_open": menu_open,
	}


static func _is_letter(letter: String) -> bool:
	return letter.length() == 1 and letter.unicode_at(0) >= 65 and letter.unicode_at(0) <= 90
