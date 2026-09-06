class_name RouteMeasurement
extends RefCounted

## Per-attempt, in-memory route observations. This class has no file, network
## or timing authority and is deliberately called only after RunSession has
## processed an input event.

var contracts: Array[Dictionary] = []
var completed_sections: Array[Dictionary] = []
var _active_by_decision := {}


func _init(new_contracts: Array = []) -> void:
	for contract in new_contracts:
		if contract is Dictionary:
			contracts.append(contract.duplicate(true))


func reset() -> void:
	completed_sections.clear()
	_active_by_decision.clear()


func record_session_event(event: Dictionary, previous_field_id: String, current_field_id: String, received_usec: int) -> void:
	var kind := str(event.get("kind", ""))
	if kind == "restarted" or kind == "menu_requested" or kind == "focus_lost":
		reset()
		return
	if kind != "moved" and kind != "finished":
		return
	for contract in contracts:
		var decision_id := str(contract.get("decision_id", ""))
		var entry: Dictionary = contract.get("entry", {})
		var exit: Dictionary = contract.get("exit", {})
		if previous_field_id == str(entry.get("from", "")) and current_field_id == str(entry.get("to", "")):
			_active_by_decision[decision_id] = {"contract": contract, "started_usec": received_usec, "start_error_count": int(event.get("error_count", 0))}
			continue
		if not _active_by_decision.has(decision_id):
			continue
		if previous_field_id == str(exit.get("from", "")) and current_field_id == str(exit.get("to", "")):
			var active: Dictionary = _active_by_decision[decision_id]
			completed_sections.append({"section_id": str(contract.get("id", "")), "decision_id": decision_id, "duration_usec": maxi(0, received_usec - int(active["started_usec"])), "error_count": maxi(0, int(event.get("error_count", 0)) - int(active["start_error_count"]))})
			_active_by_decision.erase(decision_id)
		elif current_field_id == decision_id:
			_active_by_decision.erase(decision_id)


func summary_lines() -> Array[String]:
	var lines: Array[String] = []
	for record in completed_sections:
		lines.append("%s: %d us | Fehler: %d" % [record["section_id"], record["duration_usec"], record["error_count"]])
	return lines
