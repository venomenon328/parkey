class_name KeycapVisual
extends Node3D

## Cosmetic vertical travel only. The parent transform and CourseData never move.
const PRESS_DEPTH := 0.13
const PRESS_SECONDS := 0.045
const TOP_INSET := 0.20
const TOP_HEIGHT := 0.475
var pressed := false
var press_offset := 0.0
var _rest_heights := {}


func capture_rest_heights() -> void:
	for child in get_children():
		if child is Node3D and child.name != "Socket":
			_rest_heights[child.name] = child.position.y


func advance(delta: float) -> void:
	press_offset = move_toward(press_offset, -PRESS_DEPTH if pressed else 0.0, PRESS_DEPTH * maxf(delta, 0.0) / PRESS_SECONDS)
	for child_name in _rest_heights:
		get_node(NodePath(child_name)).position.y = float(_rest_heights[child_name]) + press_offset


func reset_press(is_current: bool) -> void:
	pressed = is_current
	press_offset = -PRESS_DEPTH if pressed else 0.0
	advance(0.0)


static func rounded_mesh(size: Vector2, height: float, inset: float = 0.06) -> ArrayMesh:
	# Three rings: exact outer extents, sloped shoulder, rounded top edge.
	# This small rectangle surface builder is not a gameplay polygon generator.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var rings: Array[PackedVector3Array] = []
	for level in 3:
		var shrink := 0.0 if level == 0 else inset * 0.6 if level == 1 else inset
		var half := size * 0.5 - Vector2.ONE * shrink
		var radius := minf(0.10, minf(half.x, half.y) * 0.15)
		var y := 0.0 if level == 0 else height * 0.76 if level == 1 else height
		var ring := PackedVector3Array()
		for corner in 4:
			var angle := float(corner) * PI * 0.5
			var center := Vector2(half.x - radius, half.y - radius)
			center *= Vector2(1.0 if corner == 0 or corner == 3 else -1.0, 1.0 if corner < 2 else -1.0)
			for step in 5:
				var point := center + Vector2(cos(angle + step * PI / 8.0), sin(angle + step * PI / 8.0)) * radius
				ring.append(Vector3(point.x, y, point.y))
		rings.append(ring)
	for level in 2:
		for index in rings[level].size():
			var next := (index + 1) % rings[level].size()
			_triangle(surface, rings[level][index], rings[level][next], rings[level + 1][index], size)
			_triangle(surface, rings[level][next], rings[level + 1][next], rings[level + 1][index], size)
	for index in rings[2].size():
		_triangle(surface, Vector3(0, height, 0), rings[2][index], rings[2][(index + 1) % rings[2].size()], size)
	surface.generate_normals()
	return surface.commit()


static func cap_mesh(size: Vector2, top: bool) -> ArrayMesh:
	# A continuous molded shell: tapered skirt, rounded shoulder and a shallow dish.
	# Both meshes share their seam; there is no stacked plate above the key.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	var profiles: Array[Vector3] = [
		Vector3(0.025, 0.02, 0.12), Vector3(0.0, 0.06, 0.14),
		Vector3(0.07, 0.33, 0.17), Vector3(0.12, 0.425, 0.18),
		Vector3(0.16, 0.465, 0.18), Vector3(TOP_INSET, 0.49, 0.18),
		Vector3(TOP_INSET + 0.09, TOP_HEIGHT, 0.12),
	]
	var rings: Array[PackedVector3Array] = []
	for profile in profiles:
		rings.append(_ring(size - Vector2.ONE * profile.x * 2.0, profile.y, profile.z))
	var first := 3 if top else 0
	var last := profiles.size() - 1 if top else 3
	for level in range(first, last):
		for index in rings[level].size():
			var next := (index + 1) % rings[level].size()
			_triangle(surface, rings[level][index], rings[level][next], rings[level + 1][index], size)
			_triangle(surface, rings[level][next], rings[level + 1][next], rings[level + 1][index], size)
	if top:
		for index in rings[-1].size():
			_triangle(surface, Vector3(0, TOP_HEIGHT, 0), rings[-1][index], rings[-1][(index + 1) % rings[-1].size()], size)
	surface.generate_normals()
	return surface.commit()


static func legend_region(size: Vector2) -> Rect2:
	# Stay inside the flat dish, including its rounded corners; reserve the middle
	# for the runner and the opposite side for state symbols. Local Z is text X.
	var half := size * 0.5 - Vector2.ONE * (TOP_INSET + 0.16)
	return Rect2(Vector2(-half.x + 0.30, -half.y), Vector2(half.x * 2.0 - 0.30, half.y - 0.16))


static func _ring(size: Vector2, height: float, radius: float) -> PackedVector3Array:
	var half := size * 0.5
	var ring := PackedVector3Array()
	for corner in 4:
		var angle := float(corner) * PI * 0.5
		var center := (half - Vector2.ONE * radius) * Vector2(1.0 if corner == 0 or corner == 3 else -1.0, 1.0 if corner < 2 else -1.0)
		for step in 5:
			var point := center + Vector2(cos(angle + step * PI / 8.0), sin(angle + step * PI / 8.0)) * radius
			ring.append(Vector3(point.x, height, point.y))
	return ring


static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, size: Vector2) -> void:
	for point in [a, b, c]:
		surface.set_uv(Vector2(point.x / size.x, point.z / size.y) + Vector2.ONE * 0.5)
		surface.add_vertex(point)
