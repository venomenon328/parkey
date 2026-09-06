class_name CourseData
extends RefCounted

## Data only: graph and spatial layout are intentionally separate. Positions
## are relative [x, z] pairs; they are not renderer or physics coordinates.

const FORMAT_VERSION := "course-data-v1"

var fields: Array = []
var layouts: Dictionary = {}
var transitions: Array = []
var start_id := ""
var target_id := ""


func _init(
		new_fields: Array = [],
		new_layouts: Dictionary = {},
		new_transitions: Array = [],
		new_start_id: String = "",
		new_target_id: String = "",
) -> void:
	for field in new_fields:
		fields.append(field.duplicate(true) if field is Dictionary else field)
	layouts = new_layouts.duplicate(true)
	for transition in new_transitions:
		transitions.append(transition.duplicate(true) if transition is Dictionary else transition)
	start_id = new_start_id
	target_id = new_target_id


func field_by_id(field_id: String) -> Dictionary:
	for field in fields:
		if field is Dictionary and str(field.get("id", "")) == field_id:
			return field
	return {}


func field_ids() -> Array[String]:
	var ids: Array[String] = []
	for field in fields:
		if field is Dictionary:
			ids.append(str(field.get("id", "")))
	return ids


func neighbor_ids(field_id: String) -> Array[String]:
	var field := field_by_id(field_id)
	var ids: Array[String] = []
	if field.is_empty() or not field.get("neighbors", []) is Array:
		return ids
	for neighbor_id in field.get("neighbors", []):
		ids.append(str(neighbor_id))
	return ids


func neighbor_for_letter(field_id: String, letter: String) -> String:
	for neighbor_id in neighbor_ids(field_id):
		var neighbor := field_by_id(neighbor_id)
		if not neighbor.is_empty() and str(neighbor.get("letter", "")) == letter:
			return neighbor_id
	return ""


func has_edge(first_id: String, second_id: String) -> bool:
	return neighbor_ids(first_id).has(second_id)


func undirected_edge_keys() -> Array[String]:
	var edge_keys: Array[String] = []
	for field_id in field_ids():
		for neighbor_id in neighbor_ids(field_id):
			var key := edge_key(field_id, neighbor_id)
			if not edge_keys.has(key):
				edge_keys.append(key)
	edge_keys.sort()
	return edge_keys


static func edge_key(first_id: String, second_id: String) -> String:
	return "%s|%s" % [first_id, second_id] if first_id < second_id else "%s|%s" % [second_id, first_id]


func canonical_graph_data() -> Dictionary:
	var ordered_fields: Array = []
	for field_id in field_ids():
		var field := field_by_id(field_id)
		var neighbors := neighbor_ids(field_id)
		neighbors.sort()
		ordered_fields.append({
			"id": field_id,
			"letter": str(field.get("letter", "")),
			"neighbors": neighbors,
		})
	ordered_fields.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return left["id"] < right["id"])
	return {
		"format": FORMAT_VERSION,
		"start_id": start_id,
		"target_id": target_id,
		"fields": ordered_fields,
	}


func canonical_layout_data() -> Dictionary:
	var ordered_layouts := {}
	var ids: Array[String] = []
	for raw_id in layouts.keys():
		ids.append(str(raw_id))
	ids.sort()
	for field_id in ids:
		var layout: Dictionary = layouts.get(field_id, {})
		ordered_layouts[field_id] = _without_cosmetics(layout)

	var ordered_transitions: Array = []
	for transition in transitions:
		if transition is Dictionary:
			ordered_transitions.append(_canonical_transition(transition))
	ordered_transitions.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return "%s|%s" % [left.get("from", ""), left.get("to", "")] < "%s|%s" % [right.get("from", ""), right.get("to", "")]
	)
	return {
		"format": "p1-layout-v1",
		"layouts": ordered_layouts,
		"transitions": ordered_transitions,
	}


static func _without_cosmetics(source: Dictionary) -> Dictionary:
	var result := {}
	for raw_key in source.keys():
		var key := str(raw_key)
		if key in ["material", "surface", "decoration", "display_name", "presentation", "camera"]:
			continue
		var value = source[raw_key]
		if value is Dictionary:
			result[key] = _without_cosmetics(value)
		elif value is Array:
			var copied: Array = []
			for item in value:
				copied.append(_without_cosmetics(item) if item is Dictionary else item)
			result[key] = copied
		else:
			result[key] = value
	return result


static func _canonical_transition(source: Dictionary) -> Dictionary:
	var result := _without_cosmetics(source)
	var first_id := str(result.get("from", ""))
	var second_id := str(result.get("to", ""))
	if second_id < first_id:
		var first_edge = result.get("from_edge", [])
		result["from"] = second_id
		result["to"] = first_id
		result["from_edge"] = result.get("to_edge", [])
		result["to_edge"] = first_edge
	else:
		result["from"] = first_id
		result["to"] = second_id
	result["from_edge"] = _canonical_segment(result.get("from_edge", []))
	result["to_edge"] = _canonical_segment(result.get("to_edge", []))
	return result


static func _canonical_segment(value) -> Array:
	if not value is Array or value.size() != 2:
		return value if value is Array else []
	var first = value[0]
	var second = value[1]
	if JSON.stringify(second) < JSON.stringify(first):
		return [second, first]
	return [first, second]
