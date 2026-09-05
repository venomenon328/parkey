class_name CourseValidator
extends RefCounted

## The small P1 layout profile intentionally validates only rectangles and
## circles on one plane. It is not a general polygon or collision framework.

const QUANTUM := 0.001
# GDScript layout values are 32-bit floats. At larger valid coordinates a
# decimal snapped to 0.001 can differ by a few millionths when snapped again.
const NUMERIC_EPSILON := 0.00001
const ANCHOR_TOLERANCE := 0.001
const EDGE_TOLERANCE := 0.01
const MIN_FIELD_EXTENT := 0.5
const MAX_FIELD_EXTENT := 12.0
const MIN_TRANSITION_SPAN := 0.2
const MAX_TRANSITION_GAP := 0.15
# Co-oriented rectangle sides with a readable overlap must either be linked or
# leave this much empty space. This is a deliberately small P1 profile rule,
# not runtime neighbor discovery and not a general polygon clearance test.
const MIN_UNCONNECTED_RECTANGLE_GAP := 0.4


static func validate(course: CourseData) -> Array[String]:
	var errors := validate_graph(course)
	errors.append_array(validate_layout(course))
	return errors


static func validate_graph(course: CourseData) -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for field in course.fields:
		if not field is Dictionary:
			errors.append("Field entries must be dictionaries.")
			continue
		var field_id := str(field.get("id", ""))
		if not _is_stable_id(field_id):
			errors.append("Field id '%s' is empty or contains unsupported characters." % field_id)
			continue
		if ids.has(field_id):
			errors.append("Field id '%s' is duplicated." % field_id)
			continue
		ids[field_id] = field
		var letter := str(field.get("letter", ""))
		if letter.length() != 1 or letter.unicode_at(0) < 65 or letter.unicode_at(0) > 90:
			errors.append("Field '%s' must use one uppercase A-Z letter." % field_id)
		if not field.get("neighbors", []) is Array:
			errors.append("Field '%s' must have a neighbors array." % field_id)

	if ids.is_empty():
		errors.append("A course needs at least one field.")
		return errors
	if course.start_id == course.target_id:
		errors.append("Start and target ids must differ.")
	if not ids.has(course.start_id):
		errors.append("Start id '%s' does not exist." % course.start_id)
	if not ids.has(course.target_id):
		errors.append("Target id '%s' does not exist." % course.target_id)

	for field_id in ids.keys():
		var field: Dictionary = ids[field_id]
		var seen_neighbors := {}
		var seen_letters := {}
		var neighbors := _field_neighbors(field)
		for raw_neighbor_id in neighbors:
			var neighbor_id := str(raw_neighbor_id)
			if neighbor_id == field_id:
				errors.append("Field '%s' has a self edge." % field_id)
			if seen_neighbors.has(neighbor_id):
				errors.append("Field '%s' repeats neighbor '%s'." % [field_id, neighbor_id])
				continue
			seen_neighbors[neighbor_id] = true
			if not ids.has(neighbor_id):
				errors.append("Field '%s' references missing neighbor '%s'." % [field_id, neighbor_id])
				continue
			var neighbor: Dictionary = ids[neighbor_id]
			if not _field_neighbors(neighbor).has(field_id):
				errors.append("Edge '%s' -> '%s' is not symmetric." % [field_id, neighbor_id])
			var letter := str(neighbor.get("letter", ""))
			if seen_letters.has(letter):
				errors.append("Field '%s' has duplicate reachable letter '%s'." % [field_id, letter])
			seen_letters[letter] = true

	if errors.is_empty() and ids.has(course.start_id):
		var reachable := _reachable_ids(course, course.start_id)
		for field_id in ids.keys():
			if not reachable.has(field_id):
				errors.append("Field '%s' is not reachable from start '%s'." % [field_id, course.start_id])
	return errors


static func validate_layout(course: CourseData) -> Array[String]:
	var errors: Array[String] = []
	var known_ids := {}
	for field_id in course.field_ids():
		known_ids[field_id] = true
		if not course.layouts.has(field_id):
			errors.append("Layout for field '%s' is missing." % field_id)
			continue
		var layout = course.layouts[field_id]
		if not layout is Dictionary:
			errors.append("Layout for field '%s' must be a dictionary." % field_id)
			continue
		errors.append_array(_validate_shape(field_id, layout))
	for raw_layout_id in course.layouts.keys():
		if not known_ids.has(str(raw_layout_id)):
			errors.append("Layout references unknown field '%s'." % str(raw_layout_id))

	var valid_shapes := errors.is_empty()
	if valid_shapes:
		var ids := course.field_ids()
		for first_index in range(ids.size()):
			for second_index in range(first_index + 1, ids.size()):
				var first_id: String = ids[first_index]
				var second_id: String = ids[second_index]
				var first_layout: Dictionary = course.layouts[first_id]
				var second_layout: Dictionary = course.layouts[second_id]
				if _shapes_overlap(first_layout, second_layout):
					errors.append("Layouts '%s' and '%s' overlap." % [first_id, second_id])
				elif (
						not course.has_edge(first_id, second_id)
						and not course.has_edge(second_id, first_id)
						and _has_ambiguous_unconnected_rectangle_gap(first_layout, second_layout)
				):
					errors.append(
						"Layouts '%s' and '%s' form a readable side gap without an explicit graph edge."
						% [first_id, second_id]
					)

	var transition_keys := {}
	for transition in course.transitions:
		if not transition is Dictionary:
			errors.append("Transition entries must be dictionaries.")
			continue
		var first_id := str(transition.get("from", ""))
		var second_id := str(transition.get("to", ""))
		if not known_ids.has(first_id) or not known_ids.has(second_id):
			errors.append("Transition '%s' -> '%s' references an unknown field." % [first_id, second_id])
			continue
		if first_id == second_id:
			errors.append("Transition '%s' is a self transition." % first_id)
			continue
		var key := CourseData.edge_key(first_id, second_id)
		if transition_keys.has(key):
			errors.append("Transition '%s' is duplicated." % key)
			continue
		transition_keys[key] = true
		if not course.has_edge(first_id, second_id) or not course.has_edge(second_id, first_id):
			errors.append("Transition '%s' has no explicit graph edge." % key)
			continue
		if valid_shapes:
			errors.append_array(_validate_transition(transition, course.layouts[first_id], course.layouts[second_id], key))

	for edge_key in course.undirected_edge_keys():
		if not transition_keys.has(edge_key):
			errors.append("Graph edge '%s' has no readable layout transition." % edge_key)
	return errors


static func _field_neighbors(field: Dictionary) -> Array:
	var neighbors = field.get("neighbors", [])
	return neighbors if neighbors is Array else []


static func _is_stable_id(field_id: String) -> bool:
	if field_id.is_empty():
		return false
	for index in field_id.length():
		var codepoint := field_id.unicode_at(index)
		var is_letter := (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122)
		var is_digit := codepoint >= 48 and codepoint <= 57
		if not is_letter and not is_digit and codepoint != 45 and codepoint != 95:
			return false
	return true


static func _reachable_ids(course: CourseData, start_id: String) -> Dictionary:
	var reached := {start_id: true}
	var pending: Array[String] = [start_id]
	while not pending.is_empty():
		var current_id: String = pending.pop_front()
		for neighbor_id in course.neighbor_ids(current_id):
			if not reached.has(neighbor_id):
				reached[neighbor_id] = true
				pending.append(neighbor_id)
	return reached


static func _validate_shape(field_id: String, layout: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var shape := str(layout.get("shape", ""))
	var position = _point(layout.get("position", null))
	var anchor = _point(layout.get("anchor", null))
	if position == null:
		errors.append("Layout '%s' needs a numeric [x, z] position." % field_id)
	if anchor == null:
		errors.append("Layout '%s' needs a numeric [x, z] anchor." % field_id)
	if position != null and (not _is_quantized(position.x) or not _is_quantized(position.y)):
		errors.append("Layout '%s' position must use %.3f precision." % [field_id, QUANTUM])
	if anchor != null and (not _is_quantized(anchor.x) or not _is_quantized(anchor.y)):
		errors.append("Layout '%s' anchor must use %.3f precision." % [field_id, QUANTUM])
	if shape == "rectangle":
		var size = _point(layout.get("size", null))
		if size == null or size.x < MIN_FIELD_EXTENT or size.y < MIN_FIELD_EXTENT or size.x > MAX_FIELD_EXTENT or size.y > MAX_FIELD_EXTENT:
			errors.append("Rectangle '%s' size must be between %.1f and %.1f." % [field_id, MIN_FIELD_EXTENT, MAX_FIELD_EXTENT])
		elif not _is_quantized(size.x) or not _is_quantized(size.y):
			errors.append("Rectangle '%s' size must use %.3f precision." % [field_id, QUANTUM])
		var rotation = layout.get("rotation_deg", null)
		if not _is_number(rotation) or not _is_quantized(float(rotation)):
			errors.append("Rectangle '%s' needs a quantized rotation_deg." % field_id)
		elif position != null and anchor != null and size != null and not _rectangle_contains(position, size, float(rotation), anchor, ANCHOR_TOLERANCE):
			errors.append("Rectangle '%s' anchor is outside its ground area." % field_id)
	elif shape == "circle":
		var radius = layout.get("radius", null)
		if not _is_number(radius) or float(radius) < MIN_FIELD_EXTENT * 0.5 or float(radius) > MAX_FIELD_EXTENT * 0.5:
			errors.append("Circle '%s' radius is outside the moderate P1 range." % field_id)
		elif not _is_quantized(float(radius)):
			errors.append("Circle '%s' radius must use %.3f precision." % [field_id, QUANTUM])
		elif position != null and anchor != null and anchor.distance_to(position) > float(radius) + ANCHOR_TOLERANCE:
			errors.append("Circle '%s' anchor is outside its ground area." % field_id)
	else:
		errors.append("Layout '%s' uses unsupported shape '%s'." % [field_id, shape])
	return errors


static func _validate_transition(transition: Dictionary, first_layout: Dictionary, second_layout: Dictionary, key: String) -> Array[String]:
	var errors: Array[String] = []
	var first_edge = _segment(transition.get("from_edge", null))
	var second_edge = _segment(transition.get("to_edge", null))
	if first_edge.is_empty() or second_edge.is_empty():
		return ["Transition '%s' needs two [x, z] boundary segments." % key]
	if first_edge[0].distance_to(first_edge[1]) < MIN_TRANSITION_SPAN:
		errors.append("Transition '%s' from_edge is shorter than %.1f." % [key, MIN_TRANSITION_SPAN])
	if second_edge[0].distance_to(second_edge[1]) < MIN_TRANSITION_SPAN:
		errors.append("Transition '%s' to_edge is shorter than %.1f." % [key, MIN_TRANSITION_SPAN])
	for point in first_edge:
		if not _is_quantized(point.x) or not _is_quantized(point.y):
			errors.append("Transition '%s' from_edge must use %.3f precision." % [key, QUANTUM])
			break
		if not _point_on_boundary(first_layout, point):
			errors.append("Transition '%s' from_edge is not on its field boundary." % key)
			break
	for point in second_edge:
		if not _is_quantized(point.x) or not _is_quantized(point.y):
			errors.append("Transition '%s' to_edge must use %.3f precision." % [key, QUANTUM])
			break
		if not _point_on_boundary(second_layout, point):
			errors.append("Transition '%s' to_edge is not on its field boundary." % key)
			break
	var first_start: Vector2 = first_edge[0]
	var first_end: Vector2 = first_edge[1]
	var second_start: Vector2 = second_edge[0]
	var second_end: Vector2 = second_edge[1]
	var direct_gap: float = maxf(first_start.distance_to(second_start), first_end.distance_to(second_end))
	var reverse_gap: float = maxf(first_start.distance_to(second_end), first_end.distance_to(second_start))
	if min(direct_gap, reverse_gap) > MAX_TRANSITION_GAP + NUMERIC_EPSILON:
		errors.append("Transition '%s' gap exceeds %.2f." % [key, MAX_TRANSITION_GAP])
	return errors


static func _point(value) -> Variant:
	if value is Vector2:
		return value
	if value is Array and value.size() == 2 and _is_number(value[0]) and _is_number(value[1]):
		return Vector2(float(value[0]), float(value[1]))
	return null


static func _segment(value) -> Array:
	if not value is Array or value.size() != 2:
		return []
	var first = _point(value[0])
	var second = _point(value[1])
	if first == null or second == null:
		return []
	return [first, second]


static func _is_number(value) -> bool:
	return value is int or value is float


static func _is_quantized(value: float) -> bool:
	return absf(value - snappedf(value, QUANTUM)) <= NUMERIC_EPSILON


static func _rectangle_contains(position: Vector2, size: Vector2, rotation_deg: float, point: Vector2, tolerance: float) -> bool:
	var local := (point - position).rotated(deg_to_rad(-rotation_deg))
	return absf(local.x) <= size.x * 0.5 + tolerance and absf(local.y) <= size.y * 0.5 + tolerance


static func _point_on_boundary(layout: Dictionary, point: Vector2) -> bool:
	if str(layout.get("shape", "")) == "circle":
		var center = _point(layout.get("position", null))
		return center != null and absf(point.distance_to(center) - float(layout.get("radius", 0.0))) <= EDGE_TOLERANCE
	if str(layout.get("shape", "")) != "rectangle":
		return false
	var raw_position: Variant = _point(layout.get("position", null))
	var raw_size: Variant = _point(layout.get("size", null))
	if raw_position == null or raw_size == null:
		return false
	var position: Vector2 = raw_position
	var size: Vector2 = raw_size
	var local: Vector2 = (point - position).rotated(deg_to_rad(-float(layout.get("rotation_deg", 0.0))))
	var on_vertical: bool = absf(absf(local.x) - size.x * 0.5) <= EDGE_TOLERANCE and absf(local.y) <= size.y * 0.5 + EDGE_TOLERANCE
	var on_horizontal: bool = absf(absf(local.y) - size.y * 0.5) <= EDGE_TOLERANCE and absf(local.x) <= size.x * 0.5 + EDGE_TOLERANCE
	return on_vertical or on_horizontal


static func _shapes_overlap(first_layout: Dictionary, second_layout: Dictionary) -> bool:
	var first_shape := str(first_layout.get("shape", ""))
	var second_shape := str(second_layout.get("shape", ""))
	if first_shape == "circle" and second_shape == "circle":
		var first_center: Vector2 = _point(first_layout["position"])
		var second_center: Vector2 = _point(second_layout["position"])
		return first_center.distance_to(second_center) < float(first_layout["radius"]) + float(second_layout["radius"]) - NUMERIC_EPSILON
	if first_shape == "rectangle" and second_shape == "rectangle":
		return _rectangles_overlap(first_layout, second_layout)
	var rectangle: Dictionary = first_layout if first_shape == "rectangle" else second_layout
	var circle: Dictionary = second_layout if first_shape == "rectangle" else first_layout
	var center: Vector2 = _point(circle["position"])
	var rect_position: Vector2 = _point(rectangle["position"])
	var rect_size: Vector2 = _point(rectangle["size"])
	var local: Vector2 = (center - rect_position).rotated(deg_to_rad(-float(rectangle.get("rotation_deg", 0.0))))
	var closest: Vector2 = Vector2(clampf(local.x, -rect_size.x * 0.5, rect_size.x * 0.5), clampf(local.y, -rect_size.y * 0.5, rect_size.y * 0.5))
	return local.distance_to(closest) < float(circle["radius"]) - NUMERIC_EPSILON


static func _has_ambiguous_unconnected_rectangle_gap(first_layout: Dictionary, second_layout: Dictionary) -> bool:
	if str(first_layout.get("shape", "")) != "rectangle" or str(second_layout.get("shape", "")) != "rectangle":
		return false
	var first_rotation := float(first_layout.get("rotation_deg", 0.0))
	var second_rotation := float(second_layout.get("rotation_deg", 0.0))
	var rotation_delta := fposmod(absf(first_rotation - second_rotation), 180.0)
	if minf(rotation_delta, 180.0 - rotation_delta) > QUANTUM:
		return false
	var first_position: Vector2 = _point(first_layout["position"])
	var second_position: Vector2 = _point(second_layout["position"])
	var first_size: Vector2 = _point(first_layout["size"])
	var second_size: Vector2 = _point(second_layout["size"])
	var local_delta := (second_position - first_position).rotated(deg_to_rad(-first_rotation))
	return (
			_axis_gap_is_ambiguous(local_delta.x, (first_size.x + second_size.x) * 0.5, (first_size.y + second_size.y) * 0.5 - absf(local_delta.y))
			or _axis_gap_is_ambiguous(local_delta.y, (first_size.y + second_size.y) * 0.5, (first_size.x + second_size.x) * 0.5 - absf(local_delta.x))
	)


static func _axis_gap_is_ambiguous(separation: float, combined_half_extent: float, overlap_span: float) -> bool:
	var gap := absf(separation) - combined_half_extent
	return (
			gap >= -NUMERIC_EPSILON
			and gap < MIN_UNCONNECTED_RECTANGLE_GAP - NUMERIC_EPSILON
			and overlap_span >= MIN_TRANSITION_SPAN - NUMERIC_EPSILON
	)


static func _rectangles_overlap(first_layout: Dictionary, second_layout: Dictionary) -> bool:
	var first_corners := _rectangle_corners(first_layout)
	var second_corners := _rectangle_corners(second_layout)
	var axes: Array = []
	for layout in [first_layout, second_layout]:
		var rotation := deg_to_rad(float(layout.get("rotation_deg", 0.0)))
		axes.append(Vector2(cos(rotation), sin(rotation)))
		axes.append(Vector2(-sin(rotation), cos(rotation)))
	for axis in axes:
		var first_range: Array[float] = _project(first_corners, axis)
		var second_range: Array[float] = _project(second_corners, axis)
		if first_range[1] <= second_range[0] + NUMERIC_EPSILON or second_range[1] <= first_range[0] + NUMERIC_EPSILON:
			return false
	return true


static func _rectangle_corners(layout: Dictionary) -> Array:
	var position: Vector2 = _point(layout["position"])
	var size: Vector2 = _point(layout["size"])
	var rotation := deg_to_rad(float(layout.get("rotation_deg", 0.0)))
	var local_corners := [
		Vector2(-size.x * 0.5, -size.y * 0.5), Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5), Vector2(-size.x * 0.5, size.y * 0.5),
	]
	var corners: Array = []
	for corner in local_corners:
		corners.append(position + corner.rotated(rotation))
	return corners


static func _project(points: Array, axis: Vector2) -> Array[float]:
	var first_point: Vector2 = points[0]
	var minimum: float = first_point.dot(axis)
	var maximum: float = minimum
	for point in points.slice(1):
		var typed_point: Vector2 = point
		var projection: float = typed_point.dot(axis)
		minimum = minf(minimum, projection)
		maximum = maxf(maximum, projection)
	return [minimum, maximum]
