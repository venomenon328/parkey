class_name AtelierMesh
extends RefCounted

static var _rounded_boxes := {}

## Small cosmetic modeling tools. No course layout or collision generation.
static func instance(parent: Node3D, node_name: String, mesh: Mesh, at: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = at
	node.material_override = material
	parent.add_child(node)
	return node


static func rounded_box(size: Vector3, bevel: float) -> ArrayMesh:
	var key := Vector4(size.x, size.y, size.z, bevel)
	if _rounded_boxes.has(key):
		return _rounded_boxes[key]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := size * 0.5
	var radius := minf(bevel, minf(half.x, minf(half.y, half.z)) * 0.95)
	var inner := half - Vector3.ONE * radius
	for axis in 3:
		var u := (axis + 1) % 3
		var v := (axis + 2) % 3
		var us := [-half[u], -inner[u] - radius * 0.5, -inner[u], inner[u], inner[u] + radius * 0.5, half[u]]
		var vs := [-half[v], -inner[v] - radius * 0.5, -inner[v], inner[v], inner[v] + radius * 0.5, half[v]]
		for sign_value in [-1.0, 1.0]:
			for row in 5:
				for column in 5:
					var corners: Array[Vector3] = []
					for offset in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
						var p := Vector3.ZERO
						p[axis] = half[axis] * sign_value
						p[u] = us[column + offset.x]
						p[v] = vs[row + offset.y]
						corners.append(p)
					for index in ([0, 2, 1, 1, 2, 3] if sign_value > 0 else [0, 1, 2, 1, 3, 2]):
						var p := corners[index]
						var nearest := p.clamp(-inner, inner)
						var normal := (p - nearest).normalized()
						surface.set_normal(normal)
						surface.set_uv(Vector2(p[u] / size[u], p[v] / size[v]) + Vector2.ONE * 0.5)
						surface.add_vertex(nearest + normal * radius)
	surface.generate_tangents()
	surface.index()
	var mesh := surface.commit()
	_rounded_boxes[key] = mesh
	return mesh


static func lathe(profile: Array[Vector3], segments: int = 24) -> ArrayMesh:
	# Profile components: horizontal radius, height, depth radius.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for row in range(profile.size() - 1):
		for column in segments:
			for offset in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				var p := profile[row + offset.y]
				var angle := TAU * float(column + offset.x) / segments
				surface.set_uv(Vector2(float(column + offset.x) / segments, float(row + offset.y) / (profile.size() - 1)))
				surface.add_vertex(Vector3(cos(angle) * p.x, p.y, sin(angle) * p.z))
	surface.generate_normals()
	surface.generate_tangents()
	surface.index()
	return surface.commit()


static func tube(points: Array[Vector3], radius: float, segments: int = 8) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(points.size() - 1):
		for column in segments:
			for offset in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				var i: int = row + offset.y
				var direction := (points[mini(i + 1, points.size() - 1)] - points[maxi(0, i - 1)]).normalized()
				var side := direction.cross(Vector3.UP if absf(direction.y) < 0.95 else Vector3.RIGHT).normalized()
				var up := side.cross(direction).normalized()
				var angle := TAU * float(column + offset.x) / segments
				var normal := side * cos(angle) + up * sin(angle)
				surface.set_normal(normal)
				surface.set_uv(Vector2(float(column + offset.x) / segments, float(i) / (points.size() - 1)))
				surface.add_vertex(points[i] + normal * radius)
	surface.generate_tangents()
	surface.index()
	return surface.commit()
