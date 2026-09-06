class_name KeycapVisual
extends Node3D

## Cosmetic vertical travel only. The parent transform and CourseData never move.
const PRESS_DEPTH := 0.13
const PRESS_SECONDS := 0.045
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
			_triangle(surface, rings[level][index], rings[level + 1][index], rings[level][next], size)
			_triangle(surface, rings[level][next], rings[level + 1][index], rings[level + 1][next], size)
	for index in rings[2].size():
		_triangle(surface, Vector3(0, height, 0), rings[2][index], rings[2][(index + 1) % rings[2].size()], size)
	surface.generate_normals()
	return surface.commit()


static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, size: Vector2) -> void:
	for point in [a, b, c]:
		surface.set_uv(Vector2(point.x / size.x, point.z / size.y) + Vector2.ONE * 0.5)
		surface.add_vertex(point)
