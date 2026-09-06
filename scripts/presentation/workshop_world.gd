class_name WorkshopWorld
extends RefCounted

const KeycapVisualScript = preload("res://scripts/presentation/keycap_visual.gd")
const SkyPanorama = preload("res://assets/environment/kloofendal_48d_partly_cloudy_puresky_2k.hdr")
const WorldFont = preload("res://assets/fonts/BarlowSemiCondensed-SemiBold.ttf")
const Shapes = preload("res://scripts/presentation/atelier_mesh.gd")
const WoodColor = preload("res://assets/materials/wood_table_001_diff_1k.png")
const WoodNormal = preload("res://assets/materials/wood_table_001_nor_gl_1k.png")
const WoodRoughness = preload("res://assets/materials/wood_table_001_rough_1k.png")
static var _materials := {}


static func build(parent: Node3D, world_environment: WorldEnvironment, floor_node: MeshInstance3D, quality: bool) -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = preload("res://scripts/presentation/atelier_sky.gdshader")
	sky_material.set_shader_parameter("panorama", SkyPanorama)
	sky_material.set_shader_parameter("srgb_output", not quality)
	sky.radiance_size = Sky.RADIANCE_SIZE_256
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b7d4e1")
	environment.ambient_light_energy = 0.46
	environment.ambient_light_sky_contribution = 0.25
	environment.sky_rotation = Vector3(0, deg_to_rad(95), 0)
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES if quality else Environment.TONE_MAPPER_LINEAR
	environment.ssao_enabled = quality
	environment.ssao_radius = 0.65
	environment.ssao_intensity = 1.65
	environment.ssao_detail = 0.5
	environment.ssil_enabled = quality
	environment.ssil_radius = 2.0
	environment.ssil_intensity = 0.65
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("b8c9d2")
	environment.fog_density = 0.0008
	environment.fog_sky_affect = 0.0
	world_environment.environment = environment
	var world := Node3D.new()
	world.name = "Workshop"
	world.rotation_degrees.y = -18.0
	parent.add_child(world)
	# A continuous workshop floor supports the side stations below the course.
	# It is scenery only: no collider, course field, anchor or transition.
	floor_node.mesh = KeycapVisualScript.rounded_mesh(Vector2(64, 29), 0.25, 0.12)
	floor_node.position = Vector3(24, -1.08, 0).rotated(Vector3.UP, deg_to_rad(-18))
	floor_node.rotation_degrees.y = -18
	floor_node.material_override = _floor_material()
	floor_node.visible = true
	# Recessed workbench: below the course, never a same-height apparent route.
	_box(world, "Workbench", Vector3(21, -0.58, 0), Vector3(52, 0.7, 17), _wood_material(), 0.18)
	_box(world, "DeskMat", Vector3(21, -0.20, 0), Vector3(50, 0.06, 15.5), _mat_material(), 0.12)
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

	_build_atelier(world)
	_build_craft_details(world)
	_batch_furniture(world)


static func _box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material, bevel: float = 0.01) -> void:
	Shapes.instance(parent, node_name, Shapes.rounded_box(size, bevel), at, material)


static func _material(hex: String, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var key := "%s:%.3f:%.3f" % [hex, roughness, metallic]
	if _materials.has(key):
		return _materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = roughness
	material.metallic = metallic
	_materials[key] = material
	return material


static func _wood_material(floor_planks: bool = false, grain_along_z: bool = false) -> ShaderMaterial:
	var key := "floor_wood" if floor_planks else ("wood_z" if grain_along_z else "wood")
	if _materials.has(key):
		return _materials[key]
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/presentation/workshop_wood.gdshader")
	material.set_shader_parameter("wood_color", WoodColor)
	material.set_shader_parameter("wood_normal", WoodNormal)
	material.set_shader_parameter("wood_roughness", WoodRoughness)
	material.set_shader_parameter("floor_planks", floor_planks)
	material.set_shader_parameter("grain_along_z", grain_along_z)
	_materials[key] = material
	return material


static func _build_atelier(world: Node3D) -> void:
	var enamel := _material("294c50", 0.38, 0.25)
	var brass := _material("b48a52", 0.32, 0.72)
	var dark := _material("162e32", 0.82)
	var ceramic := _material("c7bda4", 0.48)
	# Workshop architecture frames the course at a different height and outside
	# all canonical footprints. These are furniture, never extra walkable links.
	for side in [-1.0, 1.0]:
		_box(world, "ServiceRail", Vector3(23, 0.55, side * 8.4), Vector3(51, 0.16, 0.16), brass, 0.03)
		for x in [2.0, 18.0, 35.0, 48.0]:
			_cylinder(world, Vector3(x, -0.1, side * 8.4), 0.11, 1.4, brass)
		for x in [19.0, 38.0]:
			_box(world, "ToolCabinet", Vector3(x, -0.15, side * 10.2), Vector3(7.5, 1.4, 2.8), enamel, 0.15)
			_box(world, "CabinetTop", Vector3(x, 0.62, side * 10.2), Vector3(7.8, 0.18, 3.0), _wood_material(), 0.06)
			for drawer in 3:
				_box(world, "Drawer", Vector3(x - 2.45 + drawer * 2.45, -0.08, side * 8.76), Vector3(2.2, 0.95, 0.06), dark)
				_box(world, "DrawerHandle", Vector3(x - 2.45 + drawer * 2.45, 0.22, side * 8.69), Vector3(0.68, 0.05, 0.10), brass)
			for post in [-3.3, 3.3]:
				_cylinder(world, Vector3(x + post, 2.1, side * 11.2), 0.075, 3.0, brass)
			_box(world, "SupplyShelf", Vector3(x, 2.8, side * 11.2), Vector3(7.1, 0.13, 1.6), enamel, 0.04)
			for part in 5:
				_box(world, "PartsBox", Vector3(x - 2.5 + part * 1.2, 3.1, side * 11.2), Vector3(0.9, 0.5 + (part % 2) * 0.25, 0.9), ceramic if part % 2 == 0 else dark, 0.05)
		# A crafted potentiometer assembly: turned metal, knurled collar, cable.
		for x in [6.5, 23.0, 40.0]:
			_cylinder(world, Vector3(x, 0.0, side * 5.9), 0.57, 0.25, dark)
			_cylinder(world, Vector3(x, 0.2, side * 5.9), 0.46, 0.34, brass)
			_cylinder(world, Vector3(x, 0.39, side * 5.9), 0.40, 0.06, enamel)
			_box(world, "DialIndex", Vector3(x + 0.19, 0.428, side * 5.9), Vector3(0.22, 0.012, 0.035), ceramic)
			for groove in 16:
				var a := TAU * groove / 16.0
				_cylinder(world, Vector3(x + cos(a) * 0.46, 0.2, side * 5.9 + sin(a) * 0.46), 0.017, 0.25, dark, 6)
			var cable: Array[Vector3] = []
			for segment in 18:
				var t := segment / 17.0
				cable.append(Vector3(x + t * 3.0, -0.13, side * (6.0 + sin(t * PI) * 0.72)))
			_tube(world, cable, 0.035, dark)
		_plant(world, Vector3(40.3, 0.71, side * 10.0), ceramic)
	# Readable, solid destination with warm inset light, well beyond the last key.
	for side in [-1.0, 1.0]:
		_box(world, "PortalPost", Vector3(46.4, 1.9, side * 2.2), Vector3(0.6, 4.1, 0.48), enamel, 0.10)
		_box(world, "PortalInlay", Vector3(46.05, 2.0, side * 2.2), Vector3(0.025, 3.3, 0.12), brass)
	_box(world, "PortalLintel", Vector3(46.4, 3.9, 0), Vector3(0.60, 0.62, 4.85), enamel, 0.10)
	var sign := Label3D.new()
	sign.name = "AtelierFinish"
	sign.text = "Z I E L"
	sign.font = WorldFont
	sign.font_size = 96
	sign.pixel_size = 0.0055
	sign.outline_size = 0
	sign.position = Vector3(46.05, 3.93, 0)
	sign.rotation_degrees.y = -90
	sign.modulate = Color("f2d39a")
	world.add_child(sign)


static func _cylinder(parent: Node3D, at: Vector3, radius: float, height: float, material: Material, segments: int = 24) -> void:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	node.mesh = mesh
	node.material_override = material
	node.position = at
	parent.add_child(node)


static func _tube(parent: Node3D, points: Array[Vector3], radius: float, material: Material) -> void:
	Shapes.instance(parent, "Tube", Shapes.tube(points, radius), Vector3.ZERO, material)


static func _plant(parent: Node3D, at: Vector3, pot: Material) -> void:
	Shapes.instance(parent, "CeramicPot", Shapes.lathe([
		Vector3(0.01, 0, 0.01), Vector3(0.36, 0, 0.36), Vector3(0.43, 0.04, 0.43),
		Vector3(0.54, 0.68, 0.54), Vector3(0.57, 0.73, 0.57), Vector3(0.57, 0.79, 0.57),
		Vector3(0.49, 0.79, 0.49), Vector3(0.48, 0.70, 0.48)
	]), at, pot)
	_cylinder(parent, at + Vector3.UP * 0.70, 0.48, 0.035, _material("302b24", 0.98))
	for leaf in 15:
		var angle := leaf * 2.4
		var length := 0.85 + (leaf % 4) * 0.18
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_smooth_group(0)
		for row in 10:
			for column in 4:
				for offset in [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
					var t := float(row + offset.y) / 10
					var across := float(column + offset.x) / 2 - 1
					var width := sin(t * PI) * 0.24
					var point := Vector3(across * width, 0.70 + t * length - pow(t, 3) * 0.56, t * t * (0.62 + (leaf % 3) * 0.2) + absf(across) * width * 0.38)
					surface.set_uv(Vector2((across + 1) * 0.5, t))
					surface.add_vertex(at + point.rotated(Vector3.UP, angle))
		surface.generate_normals()
		surface.generate_tangents()
		surface.index()
		var material := _material("537b53" if leaf % 3 else "7c995e", 0.58)
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		Shapes.instance(parent, "CurvedLeaf", surface.commit(), Vector3.ZERO, material)
		var stem: Array[Vector3] = []
		for step in 6:
			var t := step / 5.0
			stem.append(at + Vector3(0, 0.70 + t * length - pow(t, 3) * 0.56, t * t * (0.62 + (leaf % 3) * 0.2)).rotated(Vector3.UP, angle))
		_tube(parent, stem, 0.016, _material("93a86d", 0.72))


static func _batch_furniture(world: Node3D) -> void:
	# One immutable mesh per material, shared by both profiles. Keep per-key
	# nodes separate because their visual press and status remain independent.
	var batches := {}
	var materials := {}
	var unindexed := {}
	for child in world.get_children():
		if not child is MeshInstance3D:
			continue
		var material: Material = child.material_override
		if material == null:
			continue
		# Resource identity keeps texture/UV/emission distinctions intact.
		var key: int = material.get_rid().get_id()
		if not batches.has(key):
			var builder := SurfaceTool.new()
			builder.begin(Mesh.PRIMITIVE_TRIANGLES)
			batches[key] = builder
			materials[key] = material
		var mesh_id: int = child.mesh.get_rid().get_id()
		if not unindexed.has(mesh_id):
			var source := SurfaceTool.new()
			source.create_from(child.mesh, 0)
			source.deindex()
			unindexed[mesh_id] = source.commit()
		batches[key].append_from(unindexed[mesh_id], 0, child.transform)
		world.remove_child(child)
		child.free()
	for key in batches:
		var node := MeshInstance3D.new()
		node.name = "FurnitureBatch"
		batches[key].index()
		node.mesh = batches[key].commit()
		node.material_override = materials[key]
		world.add_child(node)


static func _mat_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/presentation/workshop_mat.gdshader")
	return material


static func _floor_material() -> ShaderMaterial:
	return _wood_material(true)


static func _build_craft_details(world: Node3D) -> void:
	var enamel := _material("294c50", 0.38, 0.25)
	var brass := _material("b48a52", 0.32, 0.72)
	var dark := _material("162e32", 0.82)
	var ivory := _material("e0d4ba", 0.5)
	var terracotta := _material("ad674d", 0.7)
	var wood := _wood_material()
	var paper := _material("cfc4a9", 0.9)
	# Close furniture gains feet, rail sockets, drawer lips, handles and tools.
	for side in [-1.0, 1.0]:
		for x in [2.0, 18.0, 35.0, 48.0]:
			_cylinder(world, Vector3(x, -0.72, side * 8.4), 0.22, 0.12, dark)
			_cylinder(world, Vector3(x, 0.50, side * 8.4), 0.16, 0.24, brass)
			_cylinder(world, Vector3(x, -0.54, side * 8.4), 0.15, 0.12, brass)
		for x in [19.0, 38.0]:
			for foot_x in [-3.0, 3.0]:
				for foot_z in [-0.95, 0.95]:
					_cylinder(world, Vector3(x + foot_x, -0.83, side * 10.2 + foot_z), 0.16, 0.33, dark)
					_cylinder(world, Vector3(x + foot_x, -0.93, side * 10.2 + foot_z), 0.22, 0.10, brass)
			for drawer in 3:
				var dx: float = x - 2.45 + drawer * 2.45
				for row in 3:
					var y := -0.49 + row * 0.32
					_box(world, "DrawerFront", Vector3(dx, y, side * 8.70), Vector3(2.1, 0.285, 0.065), enamel, 0.027)
					_tube(world, [Vector3(dx - 0.32, y + 0.02, side * 8.65), Vector3(dx - 0.27, y + 0.02, side * 8.54), Vector3(dx + 0.27, y + 0.02, side * 8.54), Vector3(dx + 0.32, y + 0.02, side * 8.65)], 0.035, brass)
					_box(world, "LabelFrame", Vector3(dx - 0.7, y, side * 8.659), Vector3(0.28, 0.12, 0.02), brass)
					_box(world, "PaperLabel", Vector3(dx - 0.7, y, side * 8.644), Vector3(0.23, 0.078, 0.012), paper)
			# A lower shelf and shaped storage tins with lids and label bands.
			_box(world, "LowerShelf", Vector3(x, 1.83, side * 11.2), Vector3(7.1, 0.12, 1.6), wood, 0.045)
			for item in 5:
				var at := Vector3(x - 2.5 + item * 1.18, 1.9, side * 11.2)
				if item % 2 == 0:
					Shapes.instance(world, "TurnedTin", Shapes.lathe([Vector3(0.01, 0, 0.01), Vector3(0.28, 0, 0.28), Vector3(0.31, 0.06, 0.31), Vector3(0.31, 0.55, 0.31), Vector3(0.29, 0.61, 0.29), Vector3(0.01, 0.61, 0.01)]), at, ivory)
					_cylinder(world, at + Vector3.UP * 0.58, 0.32, 0.07, brass)
					_box(world, "TinLabel", at + Vector3(0, 0.3, -side * 0.312), Vector3(0.26, 0.19, 0.018), terracotta, 0.016)
				else:
					for book in 3:
						_box(world, "ManualPages", at + Vector3(0, 0.045 + book * 0.15, 0), Vector3(0.76, 0.11, 0.72), paper, 0.014)
						_box(world, "ManualCover", at + Vector3(0, 0.11 + book * 0.15, 0), Vector3(0.8, 0.024, 0.76), terracotta if book % 2 else enamel, 0.01)
			# Pegboard and upright hand tools at the back of the counter.
			_box(world, "ToolBoardFrame", Vector3(x - 1.9, 1.17, side * 11.32), Vector3(2.8, 0.83, 0.11), wood, 0.04)
			_box(world, "ToolBoard", Vector3(x - 1.9, 1.17, side * 11.23), Vector3(2.6, 0.69, 0.055), dark, 0.02)
			for tool in 5:
				var tx: float = x - 2.9 + tool * 0.49
				_box(world, "ToolGrip", Vector3(tx, 1.0, side * 11.16), Vector3(0.12, 0.33, 0.13), terracotta if tool % 2 else ivory, 0.045)
				_box(world, "ToolShaft", Vector3(tx, 1.33, side * 11.16), Vector3(0.035, 0.36, 0.045), brass)
			# Sculpted plant foliage replaces the former stretched ellipsoid leaves.
			_plant(world, Vector3(x - 3.1, 0.71, side * 9.9), terracotta)
			# Counter tray, a coil, and a small ceramic cup have real contact surfaces.
			_box(world, "CounterTray", Vector3(x + 0.9, 0.755, side * 9.6), Vector3(1.7, 0.085, 0.9), enamel, 0.03)
			for tool in 3:
				_box(world, "Handle", Vector3(x + 0.3 + tool * 0.46, 0.86, side * 9.6), Vector3(0.15, 0.10, 0.48), _wood_material(false, true), 0.04)
				_box(world, "Shaft", Vector3(x + 0.3 + tool * 0.46, 0.85, side * 9.25), Vector3(0.045, 0.04, 0.33), brass)
		# No objects enter the canonical course envelope (maximum |z| < 4).
		for x in [8.0, 25.0, 42.0]:
			_cylinder(world, Vector3(x, 0.05, side * 6.6), 0.25, 0.13, enamel)
			_tube(world, [Vector3(x, 2.3, side * 6.6), Vector3(x + 0.55, 2.76, side * 6.45), Vector3(x + 0.42, 2.95, side * 6.6)], 0.065, brass)
			for y in [0.22, 2.3]:
				_cylinder(world, Vector3(x, y, side * 6.6), 0.145, 0.14, enamel)
			for rib in 7:
				_box(world, "ShadeRib", Vector3(x - 0.99 + rib * 0.33, 3.095, side * 6.6), Vector3(0.038, 0.045, 0.49), brass)
	# Portal has layered joinery, shaped feet, corner brackets and an inset sign.
	for side in [-1.0, 1.0]:
		_box(world, "PortalFoot", Vector3(46.4, 0.03, side * 2.2), Vector3(0.92, 0.35, 0.82), brass, 0.07)
		_box(world, "PortalPlinth", Vector3(46.4, -0.11, side * 2.2), Vector3(1.05, 0.12, 0.95), dark, 0.05)
		_box(world, "PortalShoulder", Vector3(46.4, 3.6, side * 2.2), Vector3(0.72, 0.38, 0.66), brass, 0.06)
		for y in [0.32, 3.60]:
			_box(world, "PortalBolt", Vector3(46.015, y, side * 2.2), Vector3(0.05, 0.095, 0.095), ivory, 0.02)
	_box(world, "PortalCrown", Vector3(46.4, 4.25, 0), Vector3(0.72, 0.14, 5.05), brass, 0.05)
	# Bench construction visible around its edge, below every key.
	for side in [-1.0, 1.0]:
		_box(world, "BenchApron", Vector3(21, -0.57, side * 8.37), Vector3(51.2, 0.25, 0.18), enamel, 0.055)
		for x in range(-3, 48, 5):
			_box(world, "ApronFastener", Vector3(x, -0.53, side * 8.48), Vector3(0.075, 0.075, 0.04), brass, 0.017)
