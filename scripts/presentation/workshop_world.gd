class_name WorkshopWorld
extends RefCounted

const KeycapVisualScript = preload("res://scripts/presentation/keycap_visual.gd")


static func build(parent: Node3D, world_environment: WorldEnvironment, floor_node: MeshInstance3D, quality: bool) -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("173238")
	sky_material.sky_horizon_color = Color("789991")
	sky_material.ground_horizon_color = Color("789991")
	sky_material.ground_bottom_color = Color("29494b")
	sky_material.sky_energy_multiplier = 0.65
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c3d8d3")
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC if quality else Environment.TONE_MAPPER_LINEAR
	environment.ssao_enabled = quality
	environment.ssao_radius = 0.5
	environment.ssao_intensity = 0.65
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("557a79")
	environment.fog_density = 0.003
	world_environment.environment = environment
	var world := Node3D.new()
	world.name = "Workshop"
	world.rotation_degrees.y = -18.0
	parent.add_child(world)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(180, 180)
	floor_node.mesh = floor_mesh
	floor_node.position = Vector3(20, -1.05, 6)
	floor_node.material_override = _material("29494b", 0.95)
	# Recessed workbench: below the course, never a same-height apparent route.
	_box(world, "Workbench", Vector3(21, -0.58, 0), Vector3(52, 0.7, 17), _material("795941", 0.82), 0.18)
	_box(world, "DeskMat", Vector3(21, -0.20, 0), Vector3(50, 0.06, 15.5), _material("233f43", 0.95), 0.12)
	var brass := _material("bb9560", 0.4, 0.65)
	for side in [-1.0, 1.0]:
		_box(world, "Rim", Vector3(21, -0.12, side * 7.55), Vector3(49, 0.07, 0.045), brass)
		for index in 10:
			_box(world, "CalibrationTick", Vector3(-1 + index * 5, -0.11, side * 7.25), Vector3(0.025, 0.012, 0.22), brass)
		# Slatted task-light architecture sits outside every field and connection.
		for x in [8.0, 25.0, 42.0]:
			_box(world, "LampFoot", Vector3(x, -0.05, side * 6.6), Vector3(1.0, 0.2, 0.7), brass, 0.06)
			_box(world, "LampStem", Vector3(x, 1.45, side * 6.6), Vector3(0.08, 3.0, 0.08), brass)
			_box(world, "LampShade", Vector3(x, 3.0, side * 6.6), Vector3(2.5, 0.18, 0.6), _material("203b3d", 0.65), 0.05)
			_box(world, "LampDiffuser", Vector3(x, 2.90, side * 6.6), Vector3(2.1, 0.025, 0.4), _material("efcf94", 0.65))
	for x in [-2.0, 45.5]:
		var goal: bool = x > 0
		var color := _material("b95c78" if goal else "3e9e75", 0.65)
		for z in [-1.75, 1.75]:
			_box(world, "FinishBeacon" if goal else "StartBeacon", Vector3(x, 0.65, z), Vector3(0.22, 1.7, 0.22), color, 0.04)
		var label := Label3D.new()
		label.name = "FinishSign" if goal else "StartSign"
		label.text = "ZIEL" if goal else "START"
		label.position = Vector3(x, 0.7, -2.6)
		label.rotation_degrees.y = -90
		label.font_size = 48
		label.pixel_size = 0.006
		label.modulate = Color("eddfc5")
		world.add_child(label)
	var title := Label3D.new()
	title.text = "PARKEY   /   ATELIER 01"
	title.position = Vector3(17, -0.145, -6.9)
	title.rotation_degrees = Vector3(-90, -90, 0)
	title.font_size = 72
	title.pixel_size = 0.013
	title.modulate = Color("bb9560")
	world.add_child(title)
	# Small mechanical still lifes, well outside the route's widest +/-3.7 bounds.
	for x in [13.0, 30.0]:
		var spool := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.65
		cylinder.bottom_radius = 0.72
		cylinder.height = 0.62
		cylinder.radial_segments = 32
		spool.mesh = cylinder
		spool.material_override = _material("bf9e6d", 0.55, 0.35)
		spool.position = Vector3(x, 0.12, 6.0)
		world.add_child(spool)
		for level in 3:
			var ring := MeshInstance3D.new()
			var torus := TorusMesh.new()
			torus.inner_radius = 0.53
			torus.outer_radius = 0.71
			torus.rings = 24
			torus.ring_segments = 8
			ring.mesh = torus
			ring.material_override = _material("d0b68c", 0.6)
			ring.position = Vector3(x, 0.04 + level * 0.15, 6.0)
			world.add_child(ring)
		_box(world, "PartsTray", Vector3(x + 2.4, -0.02, -6.0), Vector3(2.1, 0.2, 1.15), brass, 0.07)
		for index in 3:
			_box(world, "SpareSwitch", Vector3(x + 1.8 + index * 0.6, 0.14, -6.0), Vector3(0.4, 0.25, 0.5), _material("b8c8b8", 0.8), 0.06)


static func _box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material, bevel: float = 0.01) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = KeycapVisualScript.rounded_mesh(Vector2(size.x, size.z), size.y, minf(bevel, minf(size.x, size.z) * 0.1))
	node.material_override = material
	node.position = at - Vector3.UP * size.y * 0.5
	parent.add_child(node)


static func _material(hex: String, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = roughness
	material.metallic = metallic
	return material
