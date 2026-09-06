class_name LocalResultStore
extends RefCounted

## P1c's deliberately small local JSON store. Integers are serialized as
## decimal strings, so JSON parsing on native and web targets cannot silently
## lose microsecond precision.

const FORMAT_VERSION := 1
const FILE_NAME := "results-v1.json"
const TEMP_FILE_NAME := "results-v1.json.tmp"
const BACKUP_FILE_NAME := "results-v1.json.bak"
const MAX_ENTRIES_PER_IDENTITY := 100
const DISPLAY_LIMIT := 10
const MAX_INT_TEXT := "9223372036854775807"

enum Status { UNOPENED, EMPTY, READY, RECOVERED, TEMPORARY, READ_ERROR, UNSUPPORTED, WRITE_ERROR }

var base_path: String
var status := Status.UNOPENED
var status_detail := ""
var _entries: Array[Dictionary] = []
var _persistent_override := -1
var _faults: Dictionary = {}


func _init(
		new_base_path: String = "user://parkey-results",
		persistent_override: int = -1,
		faults: Dictionary = {},
) -> void:
	base_path = new_base_path
	_persistent_override = persistent_override
	_faults = faults.duplicate(true)


func load() -> Dictionary:
	_entries.clear()
	status_detail = ""
	if not _persistence_available():
		status = Status.TEMPORARY
		status_detail = "Dauerhafter Speicher ist in dieser Laufzeit nicht verfuegbar."
		return _report(true, "temporary")
	var primary := _file_path(FILE_NAME)
	if not FileAccess.file_exists(primary):
		var backup := _file_path(BACKUP_FILE_NAME)
		if FileAccess.file_exists(backup):
			return _load_backup_recovery(backup)
		status = Status.EMPTY
		return _report(true, "missing")
	return _load_file(primary, false)


func offer_result(snapshot: Dictionary) -> Dictionary:
	var checked := _validate_runtime_entry(snapshot)
	if not checked.get("ok", false):
		return _report(false, str(checked.get("error", "invalid_result")))
	var entry: Dictionary = checked["entry"]
	var run_id: String = entry["run_id"]
	var identity: String = entry["course_identity"]
	for existing in _entries:
		if existing["run_id"] != run_id:
			continue
		if existing == entry:
			return _outcome(existing, false, true, "duplicate", true, _rank_for_run(entries_for_identity(identity), run_id))
		return _report(false, "conflicting_run_id")

	var before: Array[Dictionary] = entries_for_identity(identity)
	var best_before := _best_duration(before)
	var combined := before.duplicate(true)
	combined.append(entry)
	_sort_entries(combined)
	var rank := _rank_for_run(combined, run_id)
	var retained := combined.slice(0, mini(MAX_ENTRIES_PER_IDENTITY, combined.size()))
	var is_retained := false
	for candidate in retained:
		if candidate["run_id"] == run_id:
			is_retained = true
			break
	_entries = _entries.filter(func(candidate: Dictionary) -> bool: return candidate["course_identity"] != identity)
	_entries.append_array(retained)
	_sort_entries(_entries)
	var best_kind := ""
	if best_before < 0:
		best_kind = "first"
	elif entry["duration_usec"] < best_before:
		best_kind = "improved"
	elif entry["duration_usec"] == best_before:
		best_kind = "tied"
	return _outcome(entry, true, false, best_kind, is_retained, rank)


func save() -> Dictionary:
	if status == Status.READ_ERROR or status == Status.UNSUPPORTED:
		return _report(false, "unsafe_store")
	if not _persistence_available():
		status = Status.TEMPORARY
		status_detail = "Dauerhafter Speicher ist in dieser Laufzeit nicht verfuegbar."
		return _report(true, "temporary")
	var directory_error := _ensure_directory()
	if directory_error != OK:
		return _write_failure("directory", directory_error)
	var serialized := JSON.stringify(_serialize_document())
	var temporary := _file_path(TEMP_FILE_NAME)
	var write_error := _write_complete_file(temporary, serialized)
	if write_error != OK:
		return _write_failure("write", write_error)
	var verification := _read_document(temporary)
	if not verification.get("ok", false):
		return _write_failure("verify", int(verification.get("error_code", ERR_FILE_CORRUPT)))
	var replace_error := _replace_with_temporary(temporary)
	if replace_error != OK:
		return _write_failure("replace", replace_error)
	status = Status.READY
	status_detail = ""
	return _report(true, "saved")


func entries_for_identity(course_identity: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in _entries:
		if entry["course_identity"] == course_identity:
			result.append(entry.duplicate(true))
	_sort_entries(result)
	return result


func top_entries(course_identity: String, limit: int = DISPLAY_LIMIT) -> Array[Dictionary]:
	var result := entries_for_identity(course_identity)
	return result.slice(0, mini(maxi(0, limit), result.size()))


func personal_best_usec(course_identity: String) -> int:
	return _best_duration(entries_for_identity(course_identity))


func rank_for_run(course_identity: String, run_id: String) -> int:
	return _rank_for_run(entries_for_identity(course_identity), run_id)


func is_persistent() -> bool:
	return _persistence_available() and status != Status.TEMPORARY and status != Status.READ_ERROR and status != Status.UNSUPPORTED


func status_message() -> String:
	match status:
		Status.EMPTY:
			return "Speicher bereit (noch keine Ergebnisse)."
		Status.READY, Status.RECOVERED:
			return "Lokal gespeichert."
		Status.TEMPORARY:
			return "Nur temporaer: dauerhafter Speicher nicht verfuegbar."
		Status.READ_ERROR:
			return "Speicherfehler beim Laden: Ergebnisse bleiben temporaer."
		Status.UNSUPPORTED:
			return "Unbekanntes Speicherformat: vorhandene Datei wird nicht ersetzt."
		Status.WRITE_ERROR:
			return "Speichern fehlgeschlagen: vorhandene Bestzeiten bleiben erhalten."
		_:
			return "Speicher wird vorbereitet."


func _load_backup_recovery(backup: String) -> Dictionary:
	var loaded := _load_file(backup, true)
	if loaded.get("ok", false):
		status = Status.RECOVERED
		status_detail = "Nach unterbrochenem Ersetzen aus der Sicherung gelesen."
	return loaded


func _load_file(path: String, is_backup: bool) -> Dictionary:
	var document := _read_document(path)
	if not document.get("ok", false):
		var kind := str(document.get("kind", "read"))
		if kind == "unsupported":
			status = Status.UNSUPPORTED
		else:
			status = Status.READ_ERROR
		status_detail = str(document.get("detail", ""))
		return _report(false, kind)
	_entries = document["entries"]
	status = Status.RECOVERED if is_backup else Status.READY
	return _report(true, "recovered" if is_backup else "loaded")


func _read_document(path: String) -> Dictionary:
	var injected := _fault("read")
	if injected != OK:
		return {"ok": false, "kind": "read", "detail": "injected read failure", "error_code": injected}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "kind": "read", "detail": "could not open result file", "error_code": FileAccess.get_open_error()}
	var text := file.get_as_text()
	var read_error := file.get_error()
	file.close()
	if read_error != OK:
		return {"ok": false, "kind": "read", "detail": "could not read result file", "error_code": read_error}
	var json := JSON.new()
	if json.parse(text) != OK:
		return {"ok": false, "kind": "invalid", "detail": "result JSON is malformed", "error_code": ERR_FILE_CORRUPT}
	var parsed = json.data
	var checked := _validate_document(parsed)
	if not checked.get("ok", false):
		return checked
	return {"ok": true, "entries": checked["entries"]}


func _write_complete_file(path: String, text: String) -> int:
	var injected := _fault("write")
	if injected != OK:
		return injected
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	return write_error


func _replace_with_temporary(temporary: String) -> int:
	var directory := DirAccess.open(base_path)
	if directory == null:
		return DirAccess.get_open_error()
	var primary_exists := FileAccess.file_exists(_file_path(FILE_NAME))
	var backup_exists := FileAccess.file_exists(_file_path(BACKUP_FILE_NAME))
	if backup_exists:
		var stale_backup_error := directory.remove(BACKUP_FILE_NAME)
		if stale_backup_error != OK:
			return stale_backup_error
	if primary_exists:
		var backup_error := directory.rename(FILE_NAME, BACKUP_FILE_NAME)
		if backup_error != OK:
			return backup_error
	var injected := _fault("replace")
	var replace_error := injected if injected != OK else directory.rename(TEMP_FILE_NAME, FILE_NAME)
	if replace_error != OK:
		if primary_exists and not FileAccess.file_exists(_file_path(FILE_NAME)):
			directory.rename(BACKUP_FILE_NAME, FILE_NAME)
		return replace_error
	if primary_exists:
		var cleanup_error := directory.remove(BACKUP_FILE_NAME)
		if cleanup_error != OK:
			# The new primary is already valid. A leftover recovery copy is safe.
			push_warning("Could not remove old local-results backup.")
	return OK


func _serialize_document() -> Dictionary:
	var encoded: Array = []
	for entry in _entries:
		encoded.append({
			"run_id": entry["run_id"],
			"course_identity": entry["course_identity"],
			"rule_profile_id": entry["rule_profile_id"],
			"duration_usec": str(entry["duration_usec"]),
			"error_count": str(entry["error_count"]),
		})
	return {"format_version": FORMAT_VERSION, "entries": encoded}


func _validate_document(document) -> Dictionary:
	if not document is Dictionary:
		return _invalid_document("root must be an object")
	var version := _parse_schema_version(document.get("format_version", null))
	if version < 0:
		return _invalid_document("format_version must be an integer")
	if version != FORMAT_VERSION:
		return {"ok": false, "kind": "unsupported", "detail": "unsupported format version", "error_code": ERR_UNAVAILABLE}
	if not document.get("entries", null) is Array:
		return _invalid_document("entries must be an array")
	var result: Array[Dictionary] = []
	var known_ids := {}
	for raw_entry in document["entries"]:
		if not raw_entry is Dictionary:
			return _invalid_document("entry must be an object")
		var checked := _validate_disk_entry(raw_entry)
		if not checked.get("ok", false):
			return _invalid_document(str(checked.get("error", "invalid entry")))
		var entry: Dictionary = checked["entry"]
		if known_ids.has(entry["run_id"]):
			return _invalid_document("duplicate run_id")
		known_ids[entry["run_id"]] = true
		result.append(entry)
	var per_identity := {}
	for entry in result:
		var identity: String = entry["course_identity"]
		per_identity[identity] = int(per_identity.get(identity, 0)) + 1
		if int(per_identity[identity]) > MAX_ENTRIES_PER_IDENTITY:
			return _invalid_document("too many entries for an identity")
	_sort_entries(result)
	return {"ok": true, "entries": result}


func _validate_disk_entry(raw: Dictionary) -> Dictionary:
	for field in ["run_id", "course_identity", "rule_profile_id", "duration_usec", "error_count"]:
		if not raw.has(field):
			return {"ok": false, "error": "missing %s" % field}
	if not raw["run_id"] is String or not _is_run_id(str(raw["run_id"])):
		return {"ok": false, "error": "invalid run_id"}
	if not raw["course_identity"] is String or not _is_course_identity(str(raw["course_identity"])):
		return {"ok": false, "error": "invalid course_identity"}
	if not raw["rule_profile_id"] is String or str(raw["rule_profile_id"]).is_empty():
		return {"ok": false, "error": "invalid rule_profile_id"}
	var duration := _parse_decimal_integer(raw["duration_usec"])
	var errors := _parse_decimal_integer(raw["error_count"])
	if duration < 0 or errors < 0:
		return {"ok": false, "error": "invalid numeric field"}
	return {"ok": true, "entry": {
		"run_id": str(raw["run_id"]),
		"course_identity": str(raw["course_identity"]),
		"rule_profile_id": str(raw["rule_profile_id"]),
		"duration_usec": duration,
		"error_count": errors,
	}}


func _validate_runtime_entry(raw: Dictionary) -> Dictionary:
	for field in ["run_id", "course_identity", "rule_profile_id", "duration_usec", "error_count"]:
		if not raw.has(field):
			return {"ok": false, "error": "missing %s" % field}
	if not raw["run_id"] is String or not _is_run_id(str(raw["run_id"])):
		return {"ok": false, "error": "invalid run_id"}
	if not raw["course_identity"] is String or not _is_course_identity(str(raw["course_identity"])):
		return {"ok": false, "error": "invalid course_identity"}
	if not raw["rule_profile_id"] is String or str(raw["rule_profile_id"]).is_empty():
		return {"ok": false, "error": "invalid rule_profile_id"}
	if typeof(raw["duration_usec"]) != TYPE_INT or int(raw["duration_usec"]) < 0:
		return {"ok": false, "error": "invalid duration_usec"}
	if typeof(raw["error_count"]) != TYPE_INT or int(raw["error_count"]) < 0:
		return {"ok": false, "error": "invalid error_count"}
	return {"ok": true, "entry": {
		"run_id": str(raw["run_id"]),
		"course_identity": str(raw["course_identity"]),
		"rule_profile_id": str(raw["rule_profile_id"]),
		"duration_usec": int(raw["duration_usec"]),
		"error_count": int(raw["error_count"]),
	}}


func _parse_decimal_integer(value) -> int:
	if not value is String:
		return -1
	var text: String = value
	if text.is_empty() or (text.length() > 1 and text.begins_with("0")) or text.length() > MAX_INT_TEXT.length():
		return -1
	for index in text.length():
		var codepoint := text.unicode_at(index)
		if codepoint < 48 or codepoint > 57:
			return -1
	if text.length() == MAX_INT_TEXT.length() and text > MAX_INT_TEXT:
		return -1
	return int(text)


func _parse_schema_version(value) -> int:
	if typeof(value) == TYPE_INT:
		return int(value) if int(value) >= 0 else -1
	if typeof(value) == TYPE_FLOAT and is_finite(float(value)) and floorf(float(value)) == float(value) and float(value) >= 0.0 and float(value) <= float(MAX_INT_TEXT.to_int()):
		return int(value)
	return -1


func _is_run_id(value: String) -> bool:
	if value.length() < 8 or value.length() > 160:
		return false
	for index in value.length():
		var codepoint := value.unicode_at(index)
		var is_letter := (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122)
		var is_digit := codepoint >= 48 and codepoint <= 57
		if not is_letter and not is_digit and codepoint != 45 and codepoint != 95:
			return false
	return true


func _is_course_identity(value: String) -> bool:
	if not value.begins_with("course-identity-v1:") or value.length() != 83:
		return false
	for index in range(19, value.length()):
		var codepoint := value.unicode_at(index)
		var digit := codepoint >= 48 and codepoint <= 57
		var lower_hex := codepoint >= 97 and codepoint <= 102
		if not digit and not lower_hex:
			return false
	return true


func _sort_entries(entries: Array) -> void:
	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if left["duration_usec"] != right["duration_usec"]:
			return left["duration_usec"] < right["duration_usec"]
		return left["run_id"] < right["run_id"]
	)


func _best_duration(entries: Array[Dictionary]) -> int:
	if entries.is_empty():
		return -1
	return int(entries[0]["duration_usec"])


func _rank_for_run(entries: Array, run_id: String) -> int:
	var previous_duration := -1
	var rank := 0
	for index in entries.size():
		var entry: Dictionary = entries[index]
		if index == 0 or entry["duration_usec"] != previous_duration:
			rank = index + 1
		previous_duration = entry["duration_usec"]
		if entry["run_id"] == run_id:
			return rank
	return 0


func _ensure_directory() -> int:
	var injected := _fault("directory")
	if injected != OK:
		return injected
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_path))


func _file_path(name: String) -> String:
	return base_path.path_join(name)


func _persistence_available() -> bool:
	return bool(_persistent_override) if _persistent_override >= 0 else OS.is_userfs_persistent()


func _fault(operation: String) -> int:
	return int(_faults.get(operation, OK))


func _invalid_document(detail: String) -> Dictionary:
	return {"ok": false, "kind": "invalid", "detail": detail, "error_code": ERR_FILE_CORRUPT}


func _write_failure(kind: String, error_code: int) -> Dictionary:
	status = Status.WRITE_ERROR
	status_detail = kind
	return _report(false, kind, error_code)


func _outcome(entry: Dictionary, accepted: bool, duplicate: bool, best_kind: String, retained: bool, rank: int = 0) -> Dictionary:
	return {
		"ok": true,
		"entry": entry.duplicate(true),
		"accepted": accepted,
		"duplicate": duplicate,
		"best_kind": best_kind,
		"retained": retained,
		"rank": rank,
		"personal_best_usec": personal_best_usec(entry["course_identity"]),
	}


func _report(ok: bool, kind: String, error_code: int = OK) -> Dictionary:
	return {"ok": ok, "kind": kind, "status": status, "detail": status_detail, "error_code": error_code}
