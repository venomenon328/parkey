class_name StorageSuite
extends RefCounted

const HandcraftedCourseScript = preload("res://scripts/course/handcrafted_course.gd")
const CourseIdentityScript = preload("res://scripts/core/course_identity.gd")
const LocalResultStoreScript = preload("res://scripts/storage/local_result_store.gd")
const PlayableCourseSceneScript = preload("res://scripts/playable_course_scene.gd")
const RuleProfileScript = preload("res://scripts/core/rule_profile.gd")

static var _serial := 0


static func run(harness) -> void:
	print("Running suite: storage")
	_test_round_trip_and_idempotence(harness)
	_test_ranking_identity_and_retention(harness)
	_test_corruption_and_io_failures(harness)
	_test_temporary_mode(harness)


static func _test_round_trip_and_idempotence(harness) -> void:
	var path := _new_path("round-trip")
	var identity := _identity()
	var store = LocalResultStoreScript.new(path, 1)
	var opened: Dictionary = store.load()
	harness._assert_true(opened["ok"], "A genuinely missing result file is a normal empty first start.")
	harness._assert_equal(store.status, LocalResultStoreScript.Status.EMPTY, "Missing local storage is distinct from a load failure.")
	var first := _entry(identity, "run-v1-first", 60000999, 2)
	var offered: Dictionary = store.offer_result(first)
	harness._assert_true(offered["accepted"], "A valid immutable completion is accepted once.")
	harness._assert_equal(offered["best_kind"], "first", "The first stored run establishes the personal best.")
	var saved: Dictionary = store.save()
	harness._assert_true(saved["ok"], "A complete first result document is written through the temporary replacement path.")
	var raw_file := FileAccess.open(path.path_join("results-v1.json"), FileAccess.READ)
	harness._assert_not_null(raw_file, "The durable v1 result document exists after a successful save.")
	if raw_file != null:
		var raw_document = JSON.parse_string(raw_file.get_as_text())
		raw_file.close()
		harness._assert_true(raw_document["entries"][0]["duration_usec"] is String, "Microseconds use lossless decimal strings in JSON.")
		harness._assert_equal(raw_document["entries"][0]["duration_usec"], "60000999", "The original unrounded microseconds survive serialization.")

	var reloaded = LocalResultStoreScript.new(path, 1)
	harness._assert_true(reloaded.load()["ok"], "A fresh store object reloads a valid durable document.")
	var loaded_entries := reloaded.entries_for_identity(identity)
	harness._assert_equal(loaded_entries.size(), 1, "Reload keeps exactly the original result.")
	harness._assert_equal(loaded_entries[0]["duration_usec"], 60000999, "Reload returns the exact numeric microseconds.")
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(60000999), "01:00.000", "Minutes carry visually without mutating the stored raw value.")
	var duplicate: Dictionary = reloaded.offer_result(first)
	harness._assert_true(duplicate["duplicate"], "Offering the same run ID after reload is idempotent.")
	harness._assert_true(reloaded.save()["ok"], "Saving an idempotent retry remains safe.")
	var conflict := first.duplicate(true)
	conflict["duration_usec"] = 42
	harness._assert_false(reloaded.offer_result(conflict)["ok"], "Conflicting content for an existing run ID is never silently replaced.")
	var second := first.duplicate(true)
	second["run_id"] = "run-v1-second"
	var second_outcome: Dictionary = reloaded.offer_result(second)
	harness._assert_true(second_outcome["accepted"], "A separate equal-content real run keeps its own ID.")
	harness._assert_equal(second_outcome["best_kind"], "tied", "An exact personal-best tie is reported without inventing a faster time.")
	harness._assert_true(reloaded.save()["ok"], "Two distinct IDs are saved together.")
	var final_store = LocalResultStoreScript.new(path, 1)
	final_store.load()
	harness._assert_equal(final_store.entries_for_identity(identity).size(), 2, "Repeated save and reload do not duplicate equal-content IDs.")
	_cleanup(path)


static func _test_ranking_identity_and_retention(harness) -> void:
	var path := _new_path("ranking")
	var course = HandcraftedCourseScript.build()
	var profile = RuleProfileScript.new()
	var identity := CourseIdentityScript.build(course, profile)
	var store = LocalResultStoreScript.new(path, 1)
	store.load()
	var tie_a: Dictionary = store.offer_result(_entry(identity, "run-v1-tie-a", 0, 0))
	var tie_b: Dictionary = store.offer_result(_entry(identity, "run-v1-tie-b", 0, 1))
	var third: Dictionary = store.offer_result(_entry(identity, "run-v1-third", 1, 0))
	harness._assert_equal(tie_a["rank"], 1, "Zero is a valid synthetic time and receives the first rank.")
	harness._assert_equal(tie_b["rank"], 1, "Exact original-time ties share the same rank.")
	harness._assert_equal(third["rank"], 3, "Ranks after a tie use competition ranking 1, 1, 3.")
	harness._assert_equal(store.personal_best_usec(identity), 0, "Personal best selection uses numeric original time, including zero.")
	var visual_one := store.offer_result(_entry(identity, "run-v1-ms-one", 1234000, 0))
	var visual_two := store.offer_result(_entry(identity, "run-v1-ms-two", 1234999, 0))
	harness._assert_equal(PlayableCourseSceneScript.format_duration_usec(1234000), PlayableCourseSceneScript.format_duration_usec(1234999), "Different raw times may intentionally share a truncated millisecond display.")
	harness._assert_true(visual_one["rank"] != visual_two["rank"], "Visually equal milliseconds still retain numeric order and distinct ranks.")

	var cosmetic_course = HandcraftedCourseScript.build()
	cosmetic_course.layouts["upper_4"]["material"] = "other-material"
	harness._assert_equal(CourseIdentityScript.build(cosmetic_course, profile), identity, "Pure layout cosmetics stay in the same leaderboard identity.")
	var layout_course = HandcraftedCourseScript.build()
	layout_course.layouts["upper_4"]["size"][0] = 2.7
	var layout_identity := CourseIdentityScript.build(layout_course, profile)
	harness._assert_true(layout_identity != identity, "Relevant spatial layout changes create a separate stored leaderboard.")
	var changed_lock_profile = RuleProfileScript.new(RuleProfileScript.DEFAULT_PROFILE_ID, RuleProfileScript.FORMAT_VERSION, 250000)
	var lock_identity := CourseIdentityScript.build(course, changed_lock_profile)
	harness._assert_true(lock_identity != identity, "A changed error pause separates results even with the same profile ID.")
	store.offer_result(_entry(layout_identity, "run-v1-layout", 99, 0))
	store.offer_result(_entry(lock_identity, "run-v1-lock", 98, 0, changed_lock_profile.profile_id))
	harness._assert_equal(store.entries_for_identity(identity).size(), 5, "The original identity keeps only its own rankings.")
	harness._assert_equal(store.entries_for_identity(layout_identity).size(), 1, "Relevant layout data is persisted in a separate list.")
	harness._assert_equal(store.entries_for_identity(lock_identity).size(), 1, "Changed score-rule data is persisted in a separate list.")

	var cap_path := _new_path("cap")
	var cap_store = LocalResultStoreScript.new(cap_path, 1)
	cap_store.load()
	var cap_identity := _identity(RuleProfileScript.new("p1-input-start-v1", 1, 200001))
	for index in 99:
		cap_store.offer_result(_entry(cap_identity, "run-v1-cap-%03d" % index, index + 1, 0))
	var boundary_a: Dictionary = cap_store.offer_result(_entry(cap_identity, "run-v1-boundary-a", 100, 0))
	var boundary_z: Dictionary = cap_store.offer_result(_entry(cap_identity, "run-v1-boundary-z", 100, 0))
	harness._assert_true(boundary_a["retained"], "The lexically first exact tie at the Top-100 boundary is retained deterministically.")
	harness._assert_false(boundary_z["retained"], "A boundary tie does not expand Top 100 beyond the configured limit.")
	var before_retry := cap_store.entries_for_identity(cap_identity)
	cap_store.offer_result(_entry(cap_identity, "run-v1-boundary-z", 100, 0))
	harness._assert_equal(cap_store.entries_for_identity(cap_identity), before_retry, "Reoffering an evicted result changes no retained list without a tombstone registry.")
	harness._assert_equal(cap_store.entries_for_identity(cap_identity).size(), 100, "Retention keeps at most 100 entries per complete identity.")
	harness._assert_true(cap_store.save()["ok"], "The retained Top-100 set persists safely.")
	_cleanup(path)
	_cleanup(cap_path)


static func _test_corruption_and_io_failures(harness) -> void:
	var identity := _identity()
	var malformed_path := _new_path("malformed")
	_write_raw(malformed_path, "{")
	var malformed = LocalResultStoreScript.new(malformed_path, 1)
	harness._assert_false(malformed.load()["ok"], "Truncated JSON is a load error, never an empty successful store.")
	harness._assert_equal(malformed.status, LocalResultStoreScript.Status.READ_ERROR, "Malformed data exposes a distinct read-error status.")
	var malformed_before := _read_raw(malformed_path)
	malformed.offer_result(_entry(identity, "run-v1-temporary", 10, 0))
	harness._assert_false(malformed.save()["ok"], "A malformed existing document is not overwritten by a new result.")
	harness._assert_equal(_read_raw(malformed_path), malformed_before, "The malformed original file is preserved for recovery.")
	_cleanup(malformed_path)

	var unsupported_path := _new_path("unsupported")
	_write_raw(unsupported_path, JSON.stringify({"format_version": 2, "entries": []}))
	var unsupported = LocalResultStoreScript.new(unsupported_path, 1)
	harness._assert_false(unsupported.load()["ok"], "An unknown newer schema is rejected rather than downgraded.")
	harness._assert_equal(unsupported.status, LocalResultStoreScript.Status.UNSUPPORTED, "Unknown versions report their own unsupported status.")
	harness._assert_equal(_read_raw(unsupported_path), JSON.stringify({"format_version": 2, "entries": []}), "An unknown schema remains untouched.")
	_cleanup(unsupported_path)

	var type_path := _new_path("types")
	var bad_entry := {
		"run_id": "run-v1-bad-type",
		"course_identity": identity,
		"rule_profile_id": RuleProfileScript.DEFAULT_PROFILE_ID,
		"duration_usec": 10,
		"error_count": "0",
	}
	_write_raw(type_path, JSON.stringify({"format_version": 1, "entries": [bad_entry, bad_entry.duplicate(true)]}))
	var typed = LocalResultStoreScript.new(type_path, 1)
	harness._assert_false(typed.load()["ok"], "Numeric JSON substitutions and duplicate IDs fail strict schema validation.")
	_cleanup(type_path)

	var safe_path := _new_path("replace")
	var seeded = LocalResultStoreScript.new(safe_path, 1)
	seeded.load()
	seeded.offer_result(_entry(identity, "run-v1-seeded", 100, 0))
	harness._assert_true(seeded.save()["ok"], "A known-valid predecessor is written before replacement failure testing.")
	var replace_failed = LocalResultStoreScript.new(safe_path, 1, {"replace": ERR_CANT_CREATE})
	replace_failed.load()
	replace_failed.offer_result(_entry(identity, "run-v1-not-written", 50, 0))
	harness._assert_false(replace_failed.save()["ok"], "An injected replacement error fails the save explicitly.")
	var reopened = LocalResultStoreScript.new(safe_path, 1)
	harness._assert_true(reopened.load()["ok"], "After a failed replacement, the prior valid primary file remains readable.")
	harness._assert_equal(reopened.entries_for_identity(identity).size(), 1, "A failed replacement never partially commits the new result.")
	var recovery_path := _new_path("recovery-replace")
	var recovery_seed = LocalResultStoreScript.new(recovery_path, 1)
	recovery_seed.load()
	var recovered_entry := _entry(identity, "run-v1-recovered", 100, 0)
	recovery_seed.offer_result(recovered_entry)
	harness._assert_true(recovery_seed.save()["ok"], "A known-valid result is available for backup-only recovery.")
	var recovery_directory := DirAccess.open(recovery_path)
	harness._assert_not_null(recovery_directory, "The isolated recovery directory can prepare an interrupted replacement state.")
	if recovery_directory != null:
		harness._assert_equal(recovery_directory.rename("results-v1.json", "results-v1.json.bak"), OK, "The interrupted state retains only the valid backup.")
	harness._assert_false(FileAccess.file_exists(recovery_path.path_join("results-v1.json")), "Recovery setup has no primary result file.")
	var recovered_with_failed_replace = LocalResultStoreScript.new(recovery_path, 1, {"replace": ERR_CANT_CREATE})
	harness._assert_true(recovered_with_failed_replace.load()["ok"], "A backup-only store recovers its last valid result.")
	harness._assert_equal(recovered_with_failed_replace.status, LocalResultStoreScript.Status.RECOVERED, "Backup-only loading reports recovered storage.")
	recovered_with_failed_replace.offer_result(_entry(identity, "run-v1-not-recovered", 50, 0))
	harness._assert_false(recovered_with_failed_replace.save()["ok"], "A replacement failure after backup recovery is reported explicitly.")
	var reopened_recovery = LocalResultStoreScript.new(recovery_path, 1)
	harness._assert_true(reopened_recovery.load()["ok"], "A fresh store still recovers after the post-recovery replacement failure.")
	harness._assert_equal(reopened_recovery.status, LocalResultStoreScript.Status.RECOVERED, "The fresh store loads the preserved backup after replacement failure.")
	harness._assert_equal(reopened_recovery.entries_for_identity(identity), [recovered_entry], "The fresh recovery contains exactly the old durable result, never the failed replacement.")
	var read_failed = LocalResultStoreScript.new(safe_path, 1, {"read": ERR_FILE_CANT_READ})
	harness._assert_false(read_failed.load()["ok"], "An injected access failure differs from a genuinely missing file.")
	harness._assert_equal(read_failed.status, LocalResultStoreScript.Status.READ_ERROR, "Read access failure is exposed as a read error.")
	var write_path := _new_path("write")
	var write_failed = LocalResultStoreScript.new(write_path, 1, {"write": ERR_FILE_CANT_WRITE})
	write_failed.load()
	write_failed.offer_result(_entry(identity, "run-v1-write-fail", 1, 0))
	harness._assert_false(write_failed.save()["ok"], "An injected write failure is never reported as durable success.")
	harness._assert_equal(LocalResultStoreScript.new(write_path, 1).load()["kind"], "missing", "A failed initial write leaves no deceptive primary file.")
	_cleanup(safe_path)
	_cleanup(recovery_path)
	_cleanup(write_path)


static func _test_temporary_mode(harness) -> void:
	var path := _new_path("temporary")
	var identity := _identity()
	var temporary = LocalResultStoreScript.new(path, 0)
	var opened: Dictionary = temporary.load()
	harness._assert_true(opened["ok"], "Restricted persistent storage still permits temporary play results.")
	harness._assert_equal(temporary.status, LocalResultStoreScript.Status.TEMPORARY, "Restricted storage is labelled temporary rather than successful durable storage.")
	temporary.offer_result(_entry(identity, "run-v1-volatile", 77, 0))
	var saved: Dictionary = temporary.save()
	harness._assert_true(saved["ok"] and saved["kind"] == "temporary", "Temporary results never claim a disk write.")
	harness._assert_true(temporary.status_message().contains("temporaer"), "The user-facing restricted-storage status is explicit.")
	harness._assert_equal(LocalResultStoreScript.new(path, 1).load()["kind"], "missing", "A temporary-only run leaves no durable file behind.")
	_cleanup(path)


static func _identity(profile = null) -> String:
	return CourseIdentityScript.build(HandcraftedCourseScript.build(), profile if profile != null else RuleProfileScript.new())


static func _entry(identity: String, run_id: String, duration_usec: int, error_count: int, profile_id: String = RuleProfileScript.DEFAULT_PROFILE_ID) -> Dictionary:
	return {
		"run_id": run_id,
		"course_identity": identity,
		"rule_profile_id": profile_id,
		"duration_usec": duration_usec,
		"error_count": error_count,
	}


static func _new_path(label: String) -> String:
	_serial += 1
	var path := "user://parkey-test-results/storage-%s-%d" % [label, _serial]
	_cleanup(path)
	return path


static func _write_raw(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	var file := FileAccess.open(path.path_join("results-v1.json"), FileAccess.WRITE)
	file.store_string(text)
	file.close()


static func _read_raw(path: String) -> String:
	var file := FileAccess.open(path.path_join("results-v1.json"), FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


static func _cleanup(path: String) -> void:
	if not path.begins_with("user://parkey-test-results/"):
		return
	var absolute := ProjectSettings.globalize_path(path)
	for file_name in ["results-v1.json", "results-v1.json.tmp", "results-v1.json.bak"]:
		DirAccess.remove_absolute(absolute.path_join(file_name))
	DirAccess.remove_absolute(absolute)
