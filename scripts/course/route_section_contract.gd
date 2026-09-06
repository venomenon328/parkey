class_name RouteSectionContract
extends RefCounted

## Validates the small authoring contract used by the P2a reference sections.
## It intentionally validates authored ports and geometry; it never derives new
## runtime neighbours from the layout.


static func validate(course: CourseData, contracts: Array) -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for raw_contract in contracts:
		if not raw_contract is Dictionary:
			errors.append("Route section entries must be dictionaries.")
			continue
		var contract: Dictionary = raw_contract
		var section_id := str(contract.get("id", ""))
		if section_id.is_empty() or ids.has(section_id):
			errors.append("Route section id '%s' is missing or duplicated." % section_id)
			continue
		ids[section_id] = true
		errors.append_array(_validate_contract(course, contract))
	return errors


static func preview_anchor(course: CourseData, contracts: Array, decision_id: String) -> Variant:
	var total := Vector2.ZERO
	var count := 0
	for raw_contract in contracts:
		if not raw_contract is Dictionary or str(raw_contract.get("decision_id", "")) != decision_id:
			continue
		for field_id in raw_contract.get("camera_preview_field_ids", []):
			var layout: Dictionary = course.layouts.get(str(field_id), {})
			var anchor = layout.get("anchor", [])
			if anchor is Array and anchor.size() == 2:
				total += Vector2(float(anchor[0]), float(anchor[1]))
				count += 1
	return total / float(count) if count > 0 else null


static func _validate_contract(course: CourseData, contract: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var section_id := str(contract.get("id", ""))
	var decision_id := str(contract.get("decision_id", ""))
	var entry: Dictionary = contract.get("entry", {})
	var exit: Dictionary = contract.get("exit", {})
	var entry_from := str(entry.get("from", ""))
	var entry_to := str(entry.get("to", ""))
	var exit_from := str(exit.get("from", ""))
	var exit_to := str(exit.get("to", ""))
	if decision_id != entry_from:
		errors.append("Route section '%s' entry must begin at its decision field." % section_id)
	var field_ids: Array = contract.get("field_ids", [])
	if field_ids.is_empty():
		errors.append("Route section '%s' needs authored field_ids." % section_id)
		return errors
	if str(field_ids[0]) != entry_to or str(field_ids[-1]) != exit_from:
		errors.append("Route section '%s' ports must match its first and last field." % section_id)
	var seen := {}
	for raw_id in field_ids:
		var field_id := str(raw_id)
		if seen.has(field_id) or course.field_by_id(field_id).is_empty():
			errors.append("Route section '%s' references an unknown or repeated field '%s'." % [section_id, field_id])
		seen[field_id] = true
		var layout: Dictionary = course.layouts.get(field_id, {})
		if str(layout.get("shape", "")) != "rectangle":
			errors.append("Route section '%s' field '%s' must retain an authored rectangle footprint." % [section_id, field_id])
	if str(contract.get("input_sequence", "")) != _letters_for_fields(course, field_ids):
		errors.append("Route section '%s' input_sequence does not match its field letters." % section_id)
	var path: Array[String] = [entry_from]
	for field_id in field_ids:
		path.append(str(field_id))
	path.append(exit_to)
	for index in range(path.size() - 1):
		if not course.has_edge(path[index], path[index + 1]):
			errors.append("Route section '%s' path is missing explicit edge '%s|%s'." % [section_id, path[index], path[index + 1]])
		if _transition_between(course, path[index], path[index + 1]).is_empty():
			errors.append("Route section '%s' path is missing an authored transition '%s|%s'." % [section_id, path[index], path[index + 1]])
	var footprint: Dictionary = contract.get("spatial_footprint", {})
	if footprint.get("field_ids", []) != field_ids:
		errors.append("Route section '%s' footprint must name exactly its route fields." % section_id)
	if footprint.get("shapes", []) != ["rectangle"]:
		errors.append("Route section '%s' must declare its supported authored ground shape." % section_id)
	var max_gap := float(footprint.get("allowed_gap_max", -1.0))
	if max_gap < 0.0 or max_gap > CourseValidator.MAX_TRANSITION_GAP:
		errors.append("Route section '%s' has an unsupported transition-gap limit." % section_id)
	for index in range(path.size() - 1):
		var transition := _transition_between(course, path[index], path[index + 1])
		if not transition.is_empty() and _transition_gap(transition) > max_gap + CourseValidator.NUMERIC_EPSILON:
			errors.append("Route section '%s' transition '%s|%s' exceeds its authored gap limit." % [section_id, path[index], path[index + 1]])
	for preview_id in contract.get("camera_preview_field_ids", []):
		if not seen.has(str(preview_id)):
			errors.append("Route section '%s' camera preview leaves its authored footprint." % section_id)
	return errors


static func _letters_for_fields(course: CourseData, field_ids: Array) -> String:
	var letters := ""
	for raw_id in field_ids:
		letters += str(course.field_by_id(str(raw_id)).get("letter", ""))
	return letters


static func _transition_between(course: CourseData, first_id: String, second_id: String) -> Dictionary:
	var wanted := CourseData.edge_key(first_id, second_id)
	for raw_transition in course.transitions:
		if raw_transition is Dictionary and CourseData.edge_key(str(raw_transition.get("from", "")), str(raw_transition.get("to", ""))) == wanted:
			return raw_transition
	return {}


static func _transition_gap(transition: Dictionary) -> float:
	var first: Array = transition.get("from_edge", [])
	var second: Array = transition.get("to_edge", [])
	if first.size() != 2 or second.size() != 2:
		return INF
	var direct := maxf(_point_distance(first[0], second[0]), _point_distance(first[1], second[1]))
	var reverse := maxf(_point_distance(first[0], second[1]), _point_distance(first[1], second[0]))
	return minf(direct, reverse)


static func _point_distance(first: Array, second: Array) -> float:
	return Vector2(float(first[0]), float(first[1])).distance_to(Vector2(float(second[0]), float(second[1])))
