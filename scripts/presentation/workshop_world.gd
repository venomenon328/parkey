class_name WorkshopWorld
extends RefCounted

const KeycapVisualScript = preload("res://scripts/presentation/keycap_visual.gd")
const SkyPanorama = preload("res://assets/environment/kloofendal_48d_partly_cloudy_puresky_2k.hdr")
const WorldFont = preload("res://assets/fonts/BarlowSemiCondensed-SemiBold.ttf")


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
	environment.ambient_light_color = Color("dce3e0")
	environment.ambient_light_energy = 0.40
	environment.ambient_light_sky_contribution = 0.25
	environment.sky_rotation = Vector3(0, deg_to_rad(95), 0)
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES if quality else Environment.TONE_MAPPER_LINEAR
	environment.ssao_enabled = quality
	environment.ssao_radius = 0.85
	environment.ssao_intensity = 1.35
	environment.ssao_detail = 0.5
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
	_box(world, "Workbench", Vector3(21, -0.58, 0), Vector3(52, 0.7, 17), _material("795941", 0.82), 0.18)
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
	_batch_furniture(world)


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
			_box(world, "CabinetTop", Vector3(x, 0.62, side * 10.2), Vector3(7.8, 0.18, 3.0), ceramic, 0.06)
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
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for segment in range(points.size() - 1):
		var direction := (points[segment + 1] - points[segment]).normalized()
		var side := direction.cross(Vector3.UP).normalized()
		for index in 8:
			var a := TAU * index / 8.0
			var b := TAU * (index + 1) / 8.0
			var offset_a := (side * cos(a) + Vector3.UP * sin(a)) * radius
			var offset_b := (side * cos(b) + Vector3.UP * sin(b)) * radius
			for point in [points[segment] + offset_a, points[segment + 1] + offset_a, points[segment] + offset_b, points[segment] + offset_b, points[segment + 1] + offset_a, points[segment + 1] + offset_b]:
				surface.add_vertex(point)
	surface.generate_normals()
	var node := MeshInstance3D.new()
	node.mesh = surface.commit()
	node.material_override = material
	parent.add_child(node)


static func _plant(parent: Node3D, at: Vector3, pot: Material) -> void:
	_cylinder(parent, at + Vector3.UP * 0.45, 0.6, 0.9, pot)
	var leaf_material := _material("46766a", 0.66)
	for index in 11:
		var angle := index * 2.4
		var leaf := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.3
		mesh.height = 0.6
		mesh.radial_segments = 12
		mesh.rings = 6
		leaf.mesh = mesh
		leaf.material_override = leaf_material
		leaf.position = at + Vector3(cos(angle) * 0.48, 1.45 + (index % 3) * 0.25, sin(angle) * 0.48)
		leaf.scale = Vector3(0.6, 2.4, 0.12)
		leaf.rotation = Vector3(0.35, -angle, 0.35)
		parent.add_child(leaf)


static func _batch_furniture(world: Node3D) -> void:
	# One immutable mesh per material, shared by both profiles. Keep per-key
	# nodes separate because their visual press and status remain independent.
	var batches := {}
	var materials := {}
	for child in world.get_children():
		if not child is MeshInstance3D:
			continue
		var material := child.material_override as StandardMaterial3D
		if material == null:
			continue
		if material.normal_enabled:
			continue
		var key := "%s:%.3f:%.3f" % [material.albedo_color.to_html(), material.roughness, material.metallic]
		if not batches.has(key):
			var builder := SurfaceTool.new()
			builder.begin(Mesh.PRIMITIVE_TRIANGLES)
			batches[key] = builder
			materials[key] = material
		var source := SurfaceTool.new()
		source.create_from(child.mesh, 0)
		source.deindex()
		batches[key].append_from(source.commit(), 0, child.transform)
		world.remove_child(child)
		child.free()
	for key in batches:
		var node := MeshInstance3D.new()
		node.name = "FurnitureBatch"
		batches[key].index()
		node.mesh = batches[key].commit()
		node.material_override = materials[key]
		world.add_child(node)


static func _mat_material() -> StandardMaterial3D:
	var noise := FastNoiseLite.new()
	noise.seed = 6206
	noise.frequency = 0.3
	var texture := NoiseTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.seamless = true
	texture.noise = noise
	texture.as_normal_map = true
	texture.bump_strength = 0.3
	var material := _material("29494a", 0.88)
	material.normal_enabled = true
	material.normal_texture = texture
	material.normal_scale = 0.22
	material.uv1_scale = Vector3(95, 30, 1)
	return material


static func _floor_material() -> StandardMaterial3D:
	# Versioned procedural plank texture, with long grain and staggered joints.
	# Created once during world construction, never sampled from external files.
	var color := Image.create(512, 256, false, Image.FORMAT_RGB8)
	var normal := Image.create(512, 256, false, Image.FORMAT_RGB8)
	for y in 256:
		var plank := y / 64
		for x in 512:
			var seam := y % 64 < 2 or (x + plank * 127) % 512 < 2
			var grain := sin(y * 2.1 + sin(x * 0.037) * 1.7) * 0.025
			grain += float((x * 13 + y * 73 + x * y * 3) % 29) / 650.0
			var shade := 0.86 + (plank % 3) * 0.045 + grain
			color.set_pixel(x, y, Color("766451") * (0.53 if seam else shade))
			normal.set_pixel(x, y, Color(0.5, 0.5 + grain * 0.6, 1.0))
	color.generate_mipmaps()
	normal.generate_mipmaps()
	var material := _material("ffffff", 0.88)
	material.albedo_texture = ImageTexture.create_from_image(color)
	material.normal_enabled = true
	material.normal_texture = ImageTexture.create_from_image(normal)
	material.normal_scale = 0.25
	material.uv1_scale = Vector3(8, 4, 1)
	return material
