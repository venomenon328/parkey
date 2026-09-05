class_name HandcraftedCourse
extends RefCounted

## P1b's single, versioned source for graph and spatial layout. The layout is
## authored in a local course plane and rotated as one readable composition.

const CourseDataScript = preload("res://scripts/core/course_data.gd")

const COURSE_ROTATION_DEG := 18.0
const BRANCH_OFFSET := 2.15
const BRANCH_SEPARATOR_WIDTH := 2.3
const UPPER_ROUTE := "AZKQWERTYUIMOPLXN"
const LOWER_ROUTE := "AZKDFGHJCVBMOPLXN"
const RETURN_SAMPLE := "AZKQKZAS"


static func build() -> CourseData:
	var letters := {
		"start": "S", "approach_a": "A", "approach_z": "Z", "fork": "K",
		"upper_1": "Q", "upper_2": "W", "upper_3": "E", "upper_4": "R",
		"upper_5": "T", "upper_6": "Y", "upper_7": "U", "upper_8": "I",
		"lower_1": "D", "lower_2": "F", "lower_3": "G", "lower_4": "H",
		"lower_5": "J", "lower_6": "C", "lower_7": "V", "lower_8": "B",
		"merge": "M", "final_1": "O", "final_2": "P", "final_3": "L",
		"final_4": "X", "target": "N",
	}
	var local_positions := {
		"start": Vector2(0.0, 0.0),
		"approach_a": Vector2(2.1, 0.0),
		"approach_z": Vector2(4.2, 0.0),
		"fork": Vector2(6.3, 0.0),
	}
	var sizes := {
		"start": Vector2(2.0, 2.0),
		"approach_a": Vector2(2.0, 2.0),
		"approach_z": Vector2(2.0, 2.0),
		"fork": Vector2(2.0, 6.3),
	}

	var upper_ids: Array[String] = []
	var lower_ids: Array[String] = []
	var upper_widths := [2.0, 2.0, 2.0, 2.6, 1.4, 2.0, 2.0, 2.0]
	var lower_widths := [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]
	_add_branch("upper", -BRANCH_OFFSET, upper_widths, upper_ids, local_positions, sizes)
	_add_branch("lower", BRANCH_OFFSET, lower_widths, lower_ids, local_positions, sizes)
	local_positions["merge"] = Vector2(25.2, 0.0)
	sizes["merge"] = Vector2(2.0, 6.3)

	var final_ids := ["final_1", "final_2", "final_3", "final_4", "target"]
	for index in final_ids.size():
		var field_id: String = final_ids[index]
		local_positions[field_id] = Vector2(27.3 + 2.1 * index, 0.0)
		sizes[field_id] = Vector2(2.0, 2.0)

	var edges: Array[Array] = [
		["start", "approach_a"], ["approach_a", "approach_z"], ["approach_z", "fork"],
		["fork", upper_ids[0]], ["fork", lower_ids[0]],
	]
	_append_chain_edges(upper_ids, edges)
	_append_chain_edges(lower_ids, edges)
	edges.append([upper_ids[-1], "merge"])
	edges.append([lower_ids[-1], "merge"])
	edges.append(["merge", final_ids[0]])
	_append_chain_edges(final_ids, edges)

	var fields: Array = []
	var by_id := {}
	for field_id in letters.keys():
		var field := {"id": field_id, "letter": letters[field_id], "neighbors": []}
		fields.append(field)
		by_id[field_id] = field
	for edge in edges:
		by_id[edge[0]]["neighbors"].append(edge[1])
		by_id[edge[1]]["neighbors"].append(edge[0])

	var layouts := {}
	for field_id in letters.keys():
		var world_position := _rotate_and_quantize(local_positions[field_id])
		var field_size: Vector2 = sizes[field_id]
		layouts[field_id] = {
			"shape": "rectangle",
			"position": [world_position.x, world_position.y],
			"size": [field_size.x, field_size.y],
			"rotation_deg": COURSE_ROTATION_DEG,
			"anchor": [world_position.x, world_position.y],
			"display_name": field_id,
		}

	var transitions: Array = []
	for edge in edges:
		transitions.append(_build_transition(
			edge[0], edge[1], local_positions[edge[0]], local_positions[edge[1]], sizes[edge[0]], sizes[edge[1]],
		))
	return CourseDataScript.new(fields, layouts, transitions, "start", "target")


static func _add_branch(
		prefix: String,
		local_z: float,
		widths: Array,
		ids: Array[String],
		positions: Dictionary,
		sizes: Dictionary,
) -> void:
	var left_edge := 7.4
	for index in widths.size():
		var field_id := "%s_%d" % [prefix, index + 1]
		var width: float = widths[index]
		ids.append(field_id)
		positions[field_id] = Vector2(left_edge + width * 0.5, local_z)
		sizes[field_id] = Vector2(width, 2.0)
		left_edge += width + 0.1


static func _append_chain_edges(ids: Array, edges: Array[Array]) -> void:
	for index in range(ids.size() - 1):
		edges.append([ids[index], ids[index + 1]])


static func _build_transition(
		first_id: String,
		second_id: String,
		first_position: Vector2,
		second_position: Vector2,
		first_size: Vector2,
		second_size: Vector2,
) -> Dictionary:
	var first_x := first_position.x + first_size.x * 0.5
	var second_x := second_position.x - second_size.x * 0.5
	var overlap_min := maxf(first_position.y - first_size.y * 0.5, second_position.y - second_size.y * 0.5)
	var overlap_max := minf(first_position.y + first_size.y * 0.5, second_position.y + second_size.y * 0.5)
	var center_z := (overlap_min + overlap_max) * 0.5
	var half_span := minf(0.5, (overlap_max - overlap_min) * 0.4)
	return {
		"from": first_id,
		"to": second_id,
		"from_edge": [_point_array(Vector2(first_x, center_z - half_span)), _point_array(Vector2(first_x, center_z + half_span))],
		"to_edge": [_point_array(Vector2(second_x, center_z - half_span)), _point_array(Vector2(second_x, center_z + half_span))],
	}


static func _point_array(local_point: Vector2) -> Array:
	var point := _rotate_and_quantize(local_point)
	return [point.x, point.y]


static func _rotate_and_quantize(local_point: Vector2) -> Vector2:
	var rotated := local_point.rotated(deg_to_rad(COURSE_ROTATION_DEG))
	return Vector2(snappedf(rotated.x, 0.001), snappedf(rotated.y, 0.001))
