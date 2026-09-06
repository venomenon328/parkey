class_name RunnerVisual
extends RefCounted

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
	head.position = Vector3(0, 1.30, 0)
	var suit := _material("357f83", 0.82)
	var trousers := _material("233d43", 0.9)
	var skin := _material("dba57d", 0.8)
	var cream := _material("eadcc4", 0.85)
	body = _capsule(root, "Body", Vector3(0, 0.88, 0), 0.23, 0.58, suit)
	body.scale.z = 0.76
	_capsule(root, "Neck", Vector3(0, 1.17, 0), 0.085, 0.18, skin)
	var skull := _capsule(head, "Head", Vector3.ZERO, 0.205, 0.41, skin)
	skull.scale.z = 0.9
	# Fitted hair cap and small nose; no box protruding through the skull.
	var hair := _capsule(head, "Hair", Vector3(0, 0.10, 0.012), 0.208, 0.25, _material("493329", 0.93))
	hair.scale.z = 0.92
	_capsule(head, "Nose", Vector3(0, 0.0, -0.187), 0.04, 0.09, skin)
	for side in [-1.0, 1.0]:
		var suffix := "Left" if side < 0 else "Right"
		var arm := Node3D.new()
		arm.name = suffix + "Arm"
		arm.position = Vector3(side * 0.255, 1.06, 0)
		root.add_child(arm)
		arms.append(arm)
		_capsule(arm, "Sleeve", Vector3(side * 0.02, -0.13, 0), 0.085, 0.32, suit)
		_capsule(arm, "Forearm", Vector3(side * 0.025, -0.34, -0.035), 0.063, 0.23, skin)
		_capsule(arm, "Hand", Vector3(side * 0.025, -0.45, -0.045), 0.07, 0.13, skin)
		var leg := Node3D.new()
		leg.name = suffix + "Leg"
		leg.position = Vector3(side * 0.115, 0.64, 0)
		root.add_child(leg)
		legs.append(leg)
		_capsule(leg, "Thigh", Vector3(0, -0.15, 0), 0.095, 0.35, trousers)
		_capsule(leg, "Shin", Vector3(0, -0.39, 0), 0.078, 0.27, trousers)
		var shoe := _capsule(leg, "Shoe", Vector3(0, -0.55, -0.035), 0.085, 0.24, cream)
		shoe.rotation_degrees.x = 90
		_capsule(head, suffix + "Ear", Vector3(side * 0.197, -0.015, 0), 0.04, 0.095, skin)
	# Fitted collar, cuffs and heel trims make the silhouette read as clothing.
	var collar := _capsule(root, "Collar", Vector3(0, 1.14, 0.015), 0.12, 0.12, cream)
	collar.scale = Vector3(1.15, 0.42, 1.0)
	for index in 2:
		_capsule(arms[index], "Cuff", Vector3((-1.0 if index == 0 else 1.0) * 0.025, -0.27, -0.01), 0.087, 0.07, cream).scale.y = 0.45
		var heel := _capsule(legs[index], "HeelTrim", Vector3(0, -0.585, 0.02), 0.085, 0.12, suit)
		heel.scale.y = 0.3
	# Small fitted seam on the back helps orientation from the play camera.
	_capsule(root, "BackSeam", Vector3(0, 0.92, 0.169), 0.018, 0.29, cream)


func advance(delta: float, moving: bool, reacting: bool, press_offset: float) -> void:
	phase += maxf(delta, 0.0)
	state = "reaction" if reacting else "move" if moving else "idle"
	movement_blend = move_toward(movement_blend, 1.0 if moving and not reacting else 0.0, delta * 18.0)
	reaction_blend = move_toward(reaction_blend, 1.0 if reacting else 0.0, delta * 25.0)
	var stride := sin(phase * 32.0) * movement_blend
	for index in 2:
		var sign_value := -1.0 if index == 0 else 1.0
		arms[index].rotation.x = sign_value * stride * 0.65 - reaction_blend * 0.32
		legs[index].rotation.x = -sign_value * stride * 0.5
	body.scale.y = 1.0 + sin(phase * 2.4) * 0.012 * (1.0 - movement_blend)
	# Child visual offset follows the cap; the controller's canonical anchor stays intact.
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


static func _capsule(parent: Node3D, node_name: String, at: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 24
	mesh.rings = 8
	node.mesh = mesh
	node.material_override = material
	node.position = at
	parent.add_child(node)
	return node


static func _material(hex: String, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = roughness
	return material
