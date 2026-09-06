class_name RunnerVisual
extends RefCounted

const Shapes = preload("res://scripts/presentation/atelier_mesh.gd")
static var _unit_sphere: SphereMesh
var phase := 0.0
var movement_blend := 0.0
var reaction_blend := 0.0
var state := "idle"
var root: Node3D
var head: Node3D
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var body: MeshInstance3D


func build(figure: Node3D, head_pivot: Node3D) -> void:
	root = figure
	head = head_pivot
	head.position = Vector3(0, 1.32, -0.012)
	var suit := _material("498f91", 0.79)
	var trousers := _material("30494e", 0.88)
	var skin := _material("d6a184", 0.68)
	var cream := _material("e9d9bb", 0.76)
	var leather := _material("80513a", 0.62)
	var brass := _material("c8a771", 0.34)
	brass.metallic = 0.7
	var hair_material := _material("50342a", 0.63)
	var hair_light := _material("684532", 0.67)
	var dark := _material("253034", 0.72)
	_fabric(suit)
	_fabric(trousers)
	# Tailored shoulders, waist and rolled hem instead of a capsule torso.
	body = Shapes.instance(root, "Body", Shapes.lathe([
		Vector3(0.01, 0.63, 0.01), Vector3(0.20, 0.63, 0.145),
		Vector3(0.225, 0.66, 0.163), Vector3(0.218, 0.71, 0.16),
		Vector3(0.202, 0.79, 0.15), Vector3(0.216, 0.96, 0.17),
		Vector3(0.245, 1.065, 0.16), Vector3(0.222, 1.115, 0.143),
		Vector3(0.115, 1.17, 0.095), Vector3(0.085, 1.18, 0.075)
	], 32), Vector3.ZERO, suit)
	_ellipsoid(root, "Neck", Vector3(0, 1.20, 0), Vector3(0.085, 0.13, 0.08), skin)
	_ellipsoid(head, "Head", Vector3.ZERO, Vector3(0.208, 0.235, 0.185), skin)
	_ellipsoid(head, "Jaw", Vector3(0, -0.10, -0.037), Vector3(0.161, 0.115, 0.151), skin)
	_ellipsoid(head, "Nose", Vector3(0, -0.015, -0.183), Vector3(0.035, 0.06, 0.038), skin)
	_build_hair(hair_material, hair_light)
	for side in [-1.0, 1.0]:
		var suffix := "Left" if side < 0 else "Right"
		_ellipsoid(head, suffix + "Ear", Vector3(side * 0.202, -0.035, 0), Vector3(0.043, 0.073, 0.036), skin)
		_ellipsoid(head, suffix + "EarFold", Vector3(side * 0.228, -0.033, -0.008), Vector3(0.014, 0.042, 0.021), _material("b87f65", 0.83))
		_ellipsoid(head, suffix + "Eye", Vector3(side * 0.077, 0.009, -0.174), Vector3(0.023, 0.032, 0.012), dark)
		_ellipsoid(head, suffix + "Brow", Vector3(side * 0.078, 0.061, -0.172), Vector3(0.038, 0.011, 0.012), hair_material)
		var arm := Node3D.new()
		arm.name = suffix + "Arm"
		arm.position = Vector3(side * 0.245, 1.055, 0)
		root.add_child(arm)
		arms.append(arm)
		_ellipsoid(arm, "Sleeve", Vector3(side * 0.033, -0.135, 0), Vector3(0.098, 0.195, 0.09), suit).rotation.z = side * 0.10
		_ellipsoid(arm, "ElbowFold", Vector3(side * 0.04, -0.235, 0.013), Vector3(0.082, 0.037, 0.09), suit)
		_ellipsoid(arm, "Cuff", Vector3(side * 0.043, -0.292, -0.015), Vector3(0.083, 0.055, 0.083), cream)
		_ellipsoid(arm, "Forearm", Vector3(side * 0.039, -0.36, -0.027), Vector3(0.057, 0.092, 0.06), skin)
		_ellipsoid(arm, "Hand", Vector3(side * 0.038, -0.435, -0.031), Vector3(0.061, 0.08, 0.05), skin)
		_ellipsoid(arm, "Thumb", Vector3(-side * 0.008, -0.416, -0.06), Vector3(0.024, 0.044, 0.026), skin).rotation.z = side * 0.35
		for finger in 3:
			_ellipsoid(arm, "Finger", Vector3(side * (0.006 + finger * 0.022), -0.487, -0.034), Vector3(0.018, 0.026, 0.023), skin)
		var leg := Node3D.new()
		leg.name = suffix + "Leg"
		leg.position = Vector3(side * 0.112, 0.66, 0)
		root.add_child(leg)
		legs.append(leg)
		_ellipsoid(leg, "Thigh", Vector3(0, -0.14, 0.008), Vector3(0.107, 0.21, 0.098), trousers)
		_ellipsoid(leg, "Shin", Vector3(0, -0.375, 0), Vector3(0.083, 0.17, 0.077), trousers)
		_ellipsoid(leg, "TrouserCuff", Vector3(0, -0.49, 0), Vector3(0.087, 0.035, 0.079), suit)
		_box(leg, "Sole", Vector3(0, -0.605, -0.045), Vector3(0.19, 0.045, 0.32), dark, 0.019)
		_box(leg, "Shoe", Vector3(0, -0.545, -0.049), Vector3(0.186, 0.115, 0.305), leather, 0.045)
		_box(leg, "Welt", Vector3(0, -0.577, -0.047), Vector3(0.192, 0.025, 0.313), cream, 0.011)
		_ellipsoid(leg, "Tongue", Vector3(0, -0.49, -0.076), Vector3(0.06, 0.04, 0.085), leather)
		for lace in 3:
			_detail(leg, "Lace", [Vector3(-0.052, -0.477, -0.04 - lace * 0.029), Vector3(0.052, -0.477, -0.052 - lace * 0.029)], 0.006, cream)
		_box(leg, "HeelTab", Vector3(0, -0.503, 0.102), Vector3(0.045, 0.07, 0.022), suit, 0.009)
		_detail(root, "ShoulderSeam", [Vector3(side * 0.09, 1.14, 0.086), Vector3(side * 0.17, 1.08, 0.138), Vector3(side * 0.22, 1.055, 0.123)], 0.006, cream)
		_box(root, suffix + "Pocket", Vector3(side * 0.125, 0.767, 0.147), Vector3(0.12, 0.13, 0.023), suit, 0.010).rotation.z = -side * 0.06
		_detail(root, "PocketStitch", [Vector3(side * 0.18, 0.82, 0.165), Vector3(side * 0.075, 0.815, 0.177)], 0.004, cream)
		_ellipsoid(root, "PocketRivet", Vector3(side * 0.17, 0.812, 0.174), Vector3.ONE * 0.008, brass)
	Shapes.instance(root, "Collar", Shapes.lathe([Vector3(0.09, 1.135, 0.08), Vector3(0.123, 1.16, 0.102), Vector3(0.117, 1.20, 0.095), Vector3(0.088, 1.21, 0.074)], 24), Vector3.ZERO, cream)
	_box(root, "BackYoke", Vector3(0, 1.026, 0.168), Vector3(0.24, 0.10, 0.024), cream, 0.011)
	_box(root, "ToolRoll", Vector3(0, 0.687, 0.169), Vector3(0.24, 0.09, 0.12), leather, 0.033)
	for side in [-1.0, 1.0]:
		_box(root, "ToolRollStrap", Vector3(side * 0.069, 0.687, 0.17), Vector3(0.025, 0.093, 0.125), dark, 0.01)
	_detail(root, "FrontZip", [Vector3(0, 0.69, -0.165), Vector3(0, 0.95, -0.173), Vector3(0, 1.14, -0.10)], 0.008, brass)
	_detail(head, "Mouth", [Vector3(-0.033, -0.095, -0.182), Vector3(0, -0.104, -0.19), Vector3(0.033, -0.095, -0.182)], 0.007, _material("a66c59", 0.82))


func _build_hair(base: Material, highlight: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for row in 12:
		for column in 40:
			for offset in [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
				var angle := TAU * float(column + offset.x) / 40
				var t := float(row + offset.y) / 12
				var end := 1.47 + maxf(0, sin(angle)) * 0.58
				var polar := 0.01 + t * end
				var groove := sin(angle * 18.0 + polar * 2.5) * 0.003 * sin(polar)
				surface.set_uv(Vector2(float(column + offset.x) / 40, t))
				surface.add_vertex(Vector3(cos(angle) * (0.217 + groove) * sin(polar), cos(polar) * 0.24 + 0.031, sin(angle) * (0.199 + groove) * sin(polar) + 0.012))
	surface.generate_normals()
	surface.generate_tangents()
	surface.index()
	Shapes.instance(head, "Hair", surface.commit(), Vector3.ZERO, base)
	for lock in 7:
		var points: Array[Vector3] = []
		for step in 12:
			var t := float(step) / 11
			var x: float = -0.15 + lock * 0.045 + sin(t * PI) * 0.023
			var z := -0.153 + t * 0.30
			var y := 0.037 + 0.24 * sqrt(maxf(0.02, 1.0 - pow(x / 0.217, 2) - pow(z / 0.199, 2)))
			points.append(Vector3(x, y, z + 0.012))
		_detail(head, "SweptLock", points, 0.025 if lock % 2 == 0 else 0.019, highlight if lock % 3 == 0 else base)


func advance(delta: float, moving: bool, reacting: bool, press_offset: float) -> void:
	phase += maxf(delta, 0.0)
	state = "reaction" if reacting else "move" if moving else "idle"
	movement_blend = move_toward(movement_blend, 1.0 if moving and not reacting else 0.0, delta * 18.0)
	reaction_blend = move_toward(reaction_blend, 1.0 if reacting else 0.0, delta * 25.0)
	var stride := sin(phase * 32.0) * movement_blend
	for index in 2:
		var sign_value := -1.0 if index == 0 else 1.0
		arms[index].rotation.x = sign_value * stride * 0.65 - reaction_blend * 0.32
		arms[index].rotation.z = sign_value * (reaction_blend * 0.13 + sin(phase * 2.4) * 0.016)
		legs[index].rotation.x = -sign_value * stride * 0.5
	body.scale.y = 1.0 + sin(phase * 2.4) * 0.004 * (1.0 - movement_blend)
	# The controller still owns canonical anchors and all catch-up deadlines.
	for child in root.get_children():
		if child is Node3D:
			if not child.has_meta("rest_y"):
				child.set_meta("rest_y", child.position.y)
			child.position.y = float(child.get_meta("rest_y")) + press_offset - 0.07


func reset() -> void:
	phase = 0.0
	movement_blend = 0.0
	reaction_blend = 0.0
	advance(0.0, false, false, 0.0)
	for limb in arms + legs:
		limb.rotation = Vector3.ZERO


static func _ellipsoid(parent: Node3D, node_name: String, at: Vector3, radii: Vector3, material: Material) -> MeshInstance3D:
	if _unit_sphere == null:
		_unit_sphere = SphereMesh.new()
		_unit_sphere.radius = 1.0
		_unit_sphere.height = 2.0
		_unit_sphere.radial_segments = 20
		_unit_sphere.rings = 10
	var node := Shapes.instance(parent, node_name, _unit_sphere, at, material)
	node.scale = radii
	return node


static func _box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material, bevel: float) -> MeshInstance3D:
	return Shapes.instance(parent, node_name, Shapes.rounded_box(size, bevel), at, material)


static func _detail(parent: Node3D, node_name: String, points: Array[Vector3], radius: float, material: Material) -> void:
	Shapes.instance(parent, node_name, Shapes.tube(points, radius), Vector3.ZERO, material)


static func _fabric(material: StandardMaterial3D) -> void:
	var weave := Image.create(64, 64, false, Image.FORMAT_RGB8)
	for y in 64:
		for x in 64:
			weave.set_pixel(x, y, Color(0.5 + sin(x * PI * 0.5) * 0.06, 0.5 + sin(y * PI * 0.5) * 0.06, 1))
	weave.generate_mipmaps()
	material.normal_enabled = true
	material.normal_texture = ImageTexture.create_from_image(weave)
	material.normal_scale = 0.09
	material.uv1_scale = Vector3(3, 3, 1)


static func _material(hex: String, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = roughness
	return material
