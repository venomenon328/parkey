class_name KeycapStatus
extends Node3D

## Printed geometric symbols avoid platform-dependent font fallback glyphs.
var text := ""
var _dot: MeshInstance3D
var _check: Node3D
var _diamond: Node3D
var _ink := StandardMaterial3D.new()


func build() -> void:
	_ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_dot = MeshInstance3D.new()
	_dot.name = "CurrentDot"
	var disc := CylinderMesh.new()
	disc.top_radius = 0.055
	disc.bottom_radius = 0.055
	disc.height = 0.006
	disc.radial_segments = 16
	_dot.mesh = disc
	_dot.material_override = _ink
	_dot.position.x = -0.16
	add_child(_dot)
	_check = Node3D.new()
	_check.name = "VisitedCheck"
	add_child(_check)
	_stroke(_check, Vector2(-0.08, 0.0), Vector2(-0.02, 0.065))
	_stroke(_check, Vector2(-0.02, 0.065), Vector2(0.10, -0.105))
	_diamond = Node3D.new()
	_diamond.name = "ReachableDiamond"
	add_child(_diamond)
	var points := [Vector2(-0.095, 0), Vector2(0, -0.095), Vector2(0.095, 0), Vector2(0, 0.095)]
	for index in 4:
		_stroke(_diamond, points[index], points[(index + 1) % 4])


func set_state(current: bool, reachable: bool, visited: bool, color: Color) -> void:
	text = "● ✓" if current else "✓" if visited else "◇" if reachable else ""
	visible = current or visited or reachable
	_dot.visible = current
	_check.visible = visited
	_check.position.x = 0.025 if current else 0.0
	_diamond.visible = reachable and not visited and not current
	_ink.albedo_color = color


func _stroke(parent: Node3D, first: Vector2, second: Vector2) -> void:
	var node := MeshInstance3D.new()
	var delta := second - first
	var mesh := BoxMesh.new()
	mesh.size = Vector3(delta.length(), 0.006, 0.027)
	node.mesh = mesh
	node.material_override = _ink
	var midpoint := (first + second) * 0.5
	node.position = Vector3(midpoint.x, 0, midpoint.y)
	node.rotation.y = -delta.angle()
	parent.add_child(node)
