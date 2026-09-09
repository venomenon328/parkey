class_name KeycapVisual
extends Node3D

## Cosmetic vertical travel only. The parent transform and CourseData never move.
const PRESS_DEPTH := 0.13
const PRESS_SECONDS := 0.045
const TOP_INSET := 0.37
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
	surface.generate_tangents()
	return surface.commit()


static func cap_mesh(size: Vector2, top: bool) -> ArrayMesh:
	# Sample one continuous molding profile. Normals are generated on the whole
	# shell before splitting materials at the low skirt, so no shading ring appears.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	var profiles: Array[Vector3] = [Vector3(0.018, 0.018, 0.16), Vector3(0.0, 0.048, 0.17), Vector3(0.005, 0.085, 0.175)]
	# Cubic shoulder: rising tapered walls turn smoothly into a gently dished top.
	for index in range(1, 17):
		var t := float(index) / 16.0
		var point := Vector2(0.005, 0.085).bezier_interpolate(Vector2(0.07, 0.40), Vector2(0.12, 0.56), Vector2(0.25, 0.505), t)
		profiles.append(Vector3(point.x, point.y, lerpf(0.175, 0.22, t)))
	for index in range(1, 7):
		var t := float(index) / 6.0
		profiles.append(Vector3(lerpf(0.25, TOP_INSET, t), lerpf(0.505, TOP_HEIGHT, sin(t * PI * 0.5)), lerpf(0.22, 0.10, t)))
	var rings: Array[PackedVector3Array] = []
	for profile in profiles:
		rings.append(_ring(size - Vector2.ONE * profile.x * 2.0, profile.y, profile.z))
	for level in range(profiles.size() - 1):
		for index in rings[level].size():
			var next := (index + 1) % rings[level].size()
			_triangle(surface, rings[level][index], rings[level][next], rings[level + 1][index], size)
			_triangle(surface, rings[level][next], rings[level + 1][next], rings[level + 1][index], size)
	for index in rings[-1].size():
		_triangle(surface, Vector3(0, TOP_HEIGHT, 0), rings[-1][index], rings[-1][(index + 1) % rings[-1].size()], size)
	surface.generate_normals()
	surface.generate_tangents()
	var arrays := surface.commit_to_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var result := SurfaceTool.new()
	result.begin(Mesh.PRIMITIVE_TRIANGLES)
	var skirt_vertices := rings[0].size() * 6 * 2
	for index in range(skirt_vertices if top else 0, vertices.size() if top else skirt_vertices):
		result.set_normal(normals[index])
		result.set_uv(uv[index])
		result.add_vertex(vertices[index])
	result.generate_tangents()
	return result.commit()


static func legend_region(size: Vector2) -> Rect2:
	# Stay inside the flat dish, including its rounded corners; reserve the middle
	# for the runner. Local Z is text X; long keys keep the same print scale.
	var half := size * 0.5 - Vector2.ONE * (TOP_INSET + 0.01)
	return Rect2(Vector2(-half.x + 0.30, -half.y), Vector2(half.x * 2.0 - 0.30, half.y - 0.22))


static func _ring(size: Vector2, height: float, radius: float) -> PackedVector3Array:
	var half := size * 0.5
	var ring := PackedVector3Array()
	for corner in 4:
		var angle := float(corner) * PI * 0.5
		var center := (half - Vector2.ONE * radius) * Vector2(1.0 if corner == 0 or corner == 3 else -1.0, 1.0 if corner < 2 else -1.0)
		for step in 9:
			var point := center + Vector2(cos(angle + step * PI / 16.0), sin(angle + step * PI / 16.0)) * radius
			ring.append(Vector3(point.x, height, point.y))
	return ring


static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, size: Vector2) -> void:
	for point in [a, b, c]:
		surface.set_uv(Vector2(point.x / size.x, point.z / size.y) + Vector2.ONE * 0.5)
		surface.add_vertex(point)
