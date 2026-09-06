class_name HandcraftedCourse
extends RefCounted

## P2a's single authored reference course. It deliberately contains two
## decisions so that route hypotheses, geometry and camera framing can be
## exercised before any generator is introduced.

const CourseDataScript = preload("res://scripts/core/course_data.gd")

const COURSE_ROTATION_DEG := 18.0
const TRANSITION_GAP := 0.1
const MIN_BRANCH_CLEARANCE := 2.3

const ALPHA_SHORT_SEQUENCE := "FJK"
const ALPHA_LONG_SEQUENCE := "ASDFGH"
const BETA_SHORT_SEQUENCE := "PLM"
const BETA_LONG_SEQUENCE := "QWERT"
const UPPER_ROUTE := "AZK" + ALPHA_SHORT_SEQUENCE + "MVB" + BETA_SHORT_SEQUENCE + "GYUION"
const LOWER_ROUTE := "AZK" + ALPHA_LONG_SEQUENCE + "MVB" + BETA_LONG_SEQUENCE + "GYUION"
const RETURN_SAMPLE := "AZKFJKJFKZAS"


static func build() -> CourseData:
	var field_specs: Array[Dictionary] = []
	_add_field(field_specs, "start", "S", Vector2(0.0, 0.0), Vector2(2.0, 2.0))
	_add_field(field_specs, "approach_a", "A", Vector2(2.1, 0.0), Vector2(2.0, 2.0))
	_add_field(field_specs, "approach_z", "Z", Vector2(4.2, 0.0), Vector2(2.0, 2.0))
	_add_field(field_specs, "decision_one", "K", Vector2(6.3, 0.0), Vector2(2.0, 6.8))

	_add_branch(field_specs, "alpha_short", ALPHA_SHORT_SEQUENCE, Vector2(7.4, -2.3), [3.0, 2.8, 3.2], 1.5)
	_add_branch(field_specs, "alpha_long", ALPHA_LONG_SEQUENCE, Vector2(7.4, 2.3), [1.45, 1.45, 1.45, 1.45, 1.45, 1.45], 1.9)
	_add_field(field_specs, "merge_one", "M", Vector2(17.7, 0.0), Vector2(2.0, 6.8))
	_add_field(field_specs, "connector_v", "V", Vector2(19.8, 0.0), Vector2(2.0, 2.0))
	_add_field(field_specs, "decision_two", "B", Vector2(21.9, 0.0), Vector2(2.0, 7.4))

	_add_branch(field_specs, "beta_short", BETA_SHORT_SEQUENCE, Vector2(23.0, -2.65), [3.0, 2.8, 3.2], 1.5)
	_add_branch(field_specs, "beta_long", BETA_LONG_SEQUENCE, Vector2(23.0, 2.35), [1.76, 1.76, 1.76, 1.76, 1.76], 1.7)
	_add_field(field_specs, "merge_two", "G", Vector2(33.3, 0.0), Vector2(2.0, 7.4))

	var final_letters := ["Y", "U", "I", "O", "N"]
	for index in final_letters.size():
		_add_field(field_specs, "final_%d" % (index + 1), final_letters[index], Vector2(35.4 + index * 2.1, 0.0), Vector2(2.0, 2.0))

	var edges: Array[Array] = [
		["start", "approach_a"], ["approach_a", "approach_z"], ["approach_z", "decision_one"],
		["decision_one", "alpha_short_1"], ["decision_one", "alpha_long_1"],
	]
	_append_branch_edges("alpha_short", ALPHA_SHORT_SEQUENCE.length(), edges)
	_append_branch_edges("alpha_long", ALPHA_LONG_SEQUENCE.length(), edges)
	edges.append(["alpha_short_3", "merge_one"])
	edges.append(["alpha_long_6", "merge_one"])
	edges.append(["merge_one", "connector_v"])
	edges.append(["connector_v", "decision_two"])
	edges.append(["decision_two", "beta_short_1"])
	edges.append(["decision_two", "beta_long_1"])
	_append_branch_edges("beta_short", BETA_SHORT_SEQUENCE.length(), edges)
	_append_branch_edges("beta_long", BETA_LONG_SEQUENCE.length(), edges)
	edges.append(["beta_short_3", "merge_two"])
	edges.append(["beta_long_5", "merge_two"])
	edges.append(["merge_two", "final_1"])
	for index in range(1, final_letters.size()):
		edges.append(["final_%d" % index, "final_%d" % (index + 1)])

	var fields: Array = []
	var by_id := {}
	var layouts := {}
	for spec in field_specs:
		var field := {"id": spec["id"], "letter": spec["letter"], "neighbors": []}
		fields.append(field)
		by_id[spec["id"]] = field
		var world_position := _rotate_and_quantize(spec["position"])
		var size: Vector2 = spec["size"]
		layouts[spec["id"]] = {
			"shape": "rectangle",
			"position": [world_position.x, world_position.y],
			"size": [size.x, size.y],
			"rotation_deg": COURSE_ROTATION_DEG,
			"anchor": [world_position.x, world_position.y],
			"display_name": spec["id"],
		}
	for edge in edges:
		by_id[edge[0]]["neighbors"].append(edge[1])
		by_id[edge[1]]["neighbors"].append(edge[0])

	var spec_by_id := {}
	for spec in field_specs:
		spec_by_id[spec["id"]] = spec
	var transitions: Array = []
	for edge in edges:
		transitions.append(_build_transition(spec_by_id[edge[0]], spec_by_id[edge[1]]))
	return CourseDataScript.new(fields, layouts, transitions, "start", "final_5")


static func section_contracts() -> Array[Dictionary]:
	return [
		_section_contract(
			"alpha_short_fjk", "decision_one", "alpha_short_1", "alpha_short_3", "merge_one",
			["alpha_short_1", "alpha_short_2", "alpha_short_3"], ALPHA_SHORT_SEQUENCE,
			["alpha_short_2"],
			"Kurze Folge mit Handwechseln; nur eine zu pruefende Tippbarkeitsannahme.",
		),
		_section_contract(
			"alpha_long_asdfgh", "decision_one", "alpha_long_1", "alpha_long_6", "merge_one",
			["alpha_long_1", "alpha_long_2", "alpha_long_3", "alpha_long_4", "alpha_long_5", "alpha_long_6"], ALPHA_LONG_SEQUENCE,
			["alpha_long_3"],
			"Laengere bekannte Tastenfolge; nur eine zu pruefende Tippbarkeitsannahme.",
		),
		_section_contract(
			"beta_short_plm", "decision_two", "beta_short_1", "beta_short_3", "merge_two",
			["beta_short_1", "beta_short_2", "beta_short_3"], BETA_SHORT_SEQUENCE,
			["beta_short_2"],
			"Kurze Reihenwechsel-Folge; nur eine zu pruefende Tippbarkeitsannahme.",
		),
		_section_contract(
			"beta_long_qwert", "decision_two", "beta_long_1", "beta_long_5", "merge_two",
			["beta_long_1", "beta_long_2", "beta_long_3", "beta_long_4", "beta_long_5"], BETA_LONG_SEQUENCE,
			["beta_long_3"],
			"Laengere bekannte obere Reihe; nur eine zu pruefende Tippbarkeitsannahme.",
		),
	]


static func _section_contract(
		section_id: String,
		decision_id: String,
		entry_id: String,
		exit_id: String,
		merge_id: String,
		field_ids: Array[String],
		input_sequence: String,
		preview_field_ids: Array[String],
		hypothesis: String,
) -> Dictionary:
	return {
		"id": section_id,
		"decision_id": decision_id,
		"entry": {"from": decision_id, "to": entry_id},
		"exit": {"from": exit_id, "to": merge_id},
		"field_ids": field_ids,
		"spatial_footprint": {
			"field_ids": field_ids,
			"shapes": ["rectangle"],
			"allowed_gap_max": 0.15,
		},
		"input_sequence": input_sequence,
		"camera_preview_field_ids": preview_field_ids,
		"typing_hypothesis": hypothesis,
	}


static func _add_field(specs: Array[Dictionary], field_id: String, letter: String, position: Vector2, size: Vector2) -> void:
	specs.append({"id": field_id, "letter": letter, "position": position, "size": size})


static func _add_branch(
		specs: Array[Dictionary],
		prefix: String,
		letters: String,
		first_left: Vector2,
		widths: Array,
		depth: float,
) -> void:
	var left := first_left.x
	for index in letters.length():
		var width := float(widths[index])
		_add_field(specs, "%s_%d" % [prefix, index + 1], letters.substr(index, 1), Vector2(left + width * 0.5, first_left.y), Vector2(width, depth))
		left += width + TRANSITION_GAP


static func _append_branch_edges(prefix: String, field_count: int, edges: Array[Array]) -> void:
	for index in range(1, field_count):
		edges.append(["%s_%d" % [prefix, index], "%s_%d" % [prefix, index + 1]])


static func _build_transition(first: Dictionary, second: Dictionary) -> Dictionary:
	var first_position: Vector2 = first["position"]
	var second_position: Vector2 = second["position"]
	var first_size: Vector2 = first["size"]
	var second_size: Vector2 = second["size"]
	var first_x := first_position.x + first_size.x * 0.5
	var second_x := second_position.x - second_size.x * 0.5
	var overlap_min := maxf(first_position.y - first_size.y * 0.5, second_position.y - second_size.y * 0.5)
	var overlap_max := minf(first_position.y + first_size.y * 0.5, second_position.y + second_size.y * 0.5)
	var center_z := (overlap_min + overlap_max) * 0.5
	var half_span := minf(0.5, (overlap_max - overlap_min) * 0.4)
	return {
		"from": first["id"],
		"to": second["id"],
		"from_edge": [_point_array(Vector2(first_x, center_z - half_span)), _point_array(Vector2(first_x, center_z + half_span))],
		"to_edge": [_point_array(Vector2(second_x, center_z - half_span)), _point_array(Vector2(second_x, center_z + half_span))],
	}


static func _point_array(local_point: Vector2) -> Array:
	var point := _rotate_and_quantize(local_point)
	return [point.x, point.y]


static func _rotate_and_quantize(local_point: Vector2) -> Vector2:
	var rotated := local_point.rotated(deg_to_rad(COURSE_ROTATION_DEG))
	return Vector2(snappedf(rotated.x, 0.001), snappedf(rotated.y, 0.001))
