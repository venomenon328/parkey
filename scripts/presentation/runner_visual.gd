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
	head.position = Vector3(0, 1.185, -0.012)
	var suit := _material("b7accb", 0.83)
	var rib := _material("a49ab9", 0.86)
	var trousers := _material("927764", 0.88)
	var skin := _material("edbd9f", 0.72)
	var cream := _material("e9ded9", 0.7)
	var sole := _material("bcab9c", 0.78)
	var hair := _material("d9bda6", 0.69)
	var hair_light := _material("e1c6af", 0.7)
	hair.metallic_specular = 0.25
	hair_light.metallic_specular = 0.25
	var dark := _material("493c43", 0.79)
	_fabric(suit)
	_fabric(trousers)
	# Childlike silhouette: broad bob, soft oversized hoodie and short legs.
	body = Shapes.instance(root, "Body", Shapes.lathe([
		Vector3(0.01, 0.52, 0.01), Vector3(0.223, 0.52, 0.152),
		Vector3(0.24, 0.56, 0.168), Vector3(0.238, 0.60, 0.17),
		Vector3(0.226, 0.69, 0.164), Vector3(0.228, 0.80, 0.174),
		Vector3(0.244, 0.91, 0.171), Vector3(0.224, 0.97, 0.147),
		Vector3(0.14, 1.035, 0.106), Vector3(0.085, 1.06, 0.075)
	], 40), Vector3.ZERO, suit)
	Shapes.instance(root, "RibbedHem", Shapes.lathe([
		Vector3(0.22, 0.523, 0.153), Vector3(0.236, 0.534, 0.169),
		Vector3(0.241, 0.562, 0.173), Vector3(0.237, 0.574, 0.169)
	], 40), Vector3.ZERO, rib)
	_ellipsoid(root, "Neck", Vector3(0, 1.065, 0), Vector3(0.086, 0.1, 0.08), skin)
	_ellipsoid(head, "Head", Vector3(0, -0.015, -0.02), Vector3(0.261, 0.272, 0.229), skin)
	_ellipsoid(head, "Nose", Vector3(0, -0.048, -0.246), Vector3(0.028, 0.035, 0.025), skin)
	_build_hair(hair, hair_light)
	for side in [-1.0, 1.0]:
		var suffix := "Left" if side < 0 else "Right"
		_ellipsoid(head, suffix + "Ear", Vector3(side * 0.25, -0.072, -0.044), Vector3(0.04, 0.06, 0.033), skin)
		_ellipsoid(head, suffix + "Eye", Vector3(side * 0.09, -0.017, -0.235), Vector3(0.022, 0.031, 0.012), dark)
		_ellipsoid(head, suffix + "EyeGlint", Vector3(side * 0.087, -0.008, -0.247), Vector3.ONE * 0.007, cream)
		_ellipsoid(head, suffix + "Brow", Vector3(side * 0.09, 0.038, -0.234), Vector3(0.031, 0.007, 0.009), hair)
		_ellipsoid(head, suffix + "Cheek", Vector3(side * 0.141, -0.083, -0.216), Vector3(0.035, 0.013, 0.008), _material("dfa595", 0.86))
		var arm := Node3D.new()
		arm.name = suffix + "Arm"
		arm.position = Vector3(side * 0.233, 0.928, 0)
		root.add_child(arm)
		arms.append(arm)
		_ellipsoid(arm, "Sleeve", Vector3(side * 0.045, -0.125, -0.003), Vector3(0.103, 0.176, 0.105), suit).rotation.z = side * 0.20
		_ellipsoid(arm, "Cuff", Vector3(side * 0.075, -0.255, -0.005), Vector3(0.081, 0.045, 0.083), rib)
		_ellipsoid(arm, "Hand", Vector3(side * 0.08, -0.307, -0.011), Vector3(0.062, 0.067, 0.05), skin)
		_ellipsoid(arm, "Thumb", Vector3(side * 0.033, -0.29, -0.046), Vector3(0.026, 0.039, 0.026), skin).rotation.z = side * 0.35
		var leg := Node3D.new()
		leg.name = suffix + "Leg"
		leg.position = Vector3(side * 0.112, 0.54, 0)
		root.add_child(leg)
		legs.append(leg)
		_ellipsoid(leg, "Thigh", Vector3(0, -0.10, 0.008), Vector3(0.107, 0.163, 0.098), trousers)
		_ellipsoid(leg, "Shin", Vector3(0, -0.285, 0), Vector3(0.075, 0.13, 0.073), skin)
		_ellipsoid(leg, "Sock", Vector3(0, -0.36, 0), Vector3(0.079, 0.071, 0.077), cream)
		_box(leg, "Sole", Vector3(0, -0.485, -0.048), Vector3(0.198, 0.048, 0.321), sole, 0.022)
		_box(leg, "Shoe", Vector3(0, -0.423, -0.052), Vector3(0.19, 0.115, 0.31), cream, 0.049)
		_box(leg, "Welt", Vector3(0, -0.46, -0.049), Vector3(0.201, 0.026, 0.324), cream, 0.012)
		_ellipsoid(leg, "Tongue", Vector3(0, -0.372, -0.079), Vector3(0.06, 0.038, 0.082), suit)
		for lace in 3:
			_detail(leg, "Lace", [Vector3(-0.052, -0.357, -0.04 - lace * 0.029), Vector3(0.052, -0.357, -0.052 - lace * 0.029)], 0.005, cream)
		_box(leg, "HeelTab", Vector3(0, -0.383, 0.105), Vector3(0.045, 0.068, 0.022), rib, 0.009)
		_detail(root, "SideSeam", [Vector3(side * 0.211, 0.6, 0.086), Vector3(side * 0.202, 0.75, 0.097), Vector3(side * 0.217, 0.89, 0.071)], 0.004, rib)
	# A relaxed hood and small original bear embroidery read from the play camera.
	_ellipsoid(root, "Hood", Vector3(0, 0.964, 0.127), Vector3(0.188, 0.114, 0.135), suit)
	_ellipsoid(root, "HoodLining", Vector3(0, 1.017, 0.14), Vector3(0.151, 0.059, 0.099), rib)
	_detail(root, "HoodSeam", [Vector3(0, 0.862, 0.177), Vector3(0, 0.92, 0.257), Vector3(0, 0.983, 0.257)], 0.004, rib)
	var embroidery := _material("84718d", 0.92)
	for side in [-1.0, 1.0]:
		_ellipsoid(root, "BearEar", Vector3(side * 0.054, 0.788, 0.173), Vector3(0.019, 0.021, 0.008), embroidery)
		_ellipsoid(root, "BearEye", Vector3(side * 0.028, 0.753, 0.179), Vector3(0.008, 0.010, 0.004), embroidery)
	_detail(root, "BearSmile", [Vector3(-0.041, 0.732, 0.18), Vector3(-0.025, 0.718, 0.18), Vector3(0, 0.718, 0.18), Vector3(0.025, 0.718, 0.18), Vector3(0.041, 0.732, 0.18)], 0.006, embroidery)
	_ellipsoid(root, "BearNose", Vector3(0, 0.738, 0.18), Vector3(0.012, 0.009, 0.005), embroidery)
	_detail(head, "Mouth", [Vector3(-0.026, -0.125, -0.229), Vector3(0, -0.132, -0.233), Vector3(0.026, -0.125, -0.229)], 0.004, _material("ae796f", 0.88))


func _build_hair(base: Material, highlight: Material) -> void:
	# One sculpted bob surface: continuous crown, tapered locks, rolled-in ends.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for row in 24:
		for column in 96:
			for offset in [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
				var angle := TAU * float(column + offset.x) / 96
				var t := float(row + offset.y) / 24
				var front := pow(maxf(0, -sin(angle)), 6.0)
				var polar := 0.008 + t * (2.31 - front * (0.76 + 0.12 * sin(angle * 4.0)))
				var flow := angle * 22.0 + sin(angle * 3.0) * 0.65 + sin(polar * 1.3) * (0.8 + cos(angle) * 0.3)
				var groove := (cos(flow) * 0.0025 + cos(flow * 2.0) * 0.0008) * sin(polar) * smoothstep(0.0, 0.25, t)
				var roll := smoothstep(0.82, 1.0, t) * 0.018
				var radius := sin(polar) * (0.30 + groove) - roll
				surface.set_uv(Vector2(float(column + offset.x) / 96, t))
				surface.add_vertex(Vector3(cos(angle) * radius, cos(polar) * 0.293 + 0.038 + sin(flow) * (0.004 + front * 0.012) * pow(t, 8), sin(angle) * radius * 0.89 + 0.027))
	surface.generate_normals()
	surface.generate_tangents()
	surface.index()
	Shapes.instance(head, "BobHair", surface.commit(), Vector3.ZERO, base)
	for side in [-1.0, 1.0]:
		_ellipsoid(head, "HairBun", Vector3(side * 0.223, 0.264, 0.011), Vector3(0.083, 0.094, 0.075), highlight).rotation.z = side * 0.24


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
		_unit_sphere.radial_segments = 32
		_unit_sphere.rings = 16
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
