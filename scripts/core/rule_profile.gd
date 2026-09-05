class_name RuleProfile
extends RefCounted

## Versioned, score-relevant P1 rules. Presentation and persistence deliberately
## do not belong here.

const DEFAULT_PROFILE_ID := "p1-input-start-v1"
const FORMAT_VERSION := 1
const DEFAULT_ERROR_LOCK_USEC := 200000

var profile_id: String
var format_version: int
var error_lock_usec: int


func _init(
		new_profile_id: String = DEFAULT_PROFILE_ID,
		new_format_version: int = FORMAT_VERSION,
		new_error_lock_usec: int = DEFAULT_ERROR_LOCK_USEC,
) -> void:
	profile_id = new_profile_id
	format_version = new_format_version
	error_lock_usec = new_error_lock_usec


func identity_data() -> Dictionary:
	return {
		"profile_id": profile_id,
		"format_version": format_version,
		"error_lock_usec": error_lock_usec,
		"start": "first_a_to_z_key_down",
		"restart": "backspace_to_ready",
		"menu": "escape_request_invalidates_started_attempt",
		"connections": "explicit_bidirectional",
		"input_order": "receipt_order",
	}
