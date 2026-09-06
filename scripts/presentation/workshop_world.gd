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
	environment.ambient_light_color = Color("b8c3e0")
	environment.ambient_light_energy = 0.38
	environment.ambient_light_sky_contribution = 0.25
	environment.sky_rotation = Vector3(0, deg_to_rad(155), 0)
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES if quality else Environment.TONE_MAPPER_LINEAR
	environment.ssao_enabled = quality
	environment.ssao_radius = 0.65
	environment.ssao_intensity = 1.5
	environment.ssao_detail = 0.5
	environment.ssil_enabled = quality
	environment.ssil_radius = 2.0
	environment.ssil_intensity = 0.65
	environment.glow_enabled = false
	environment.fog_enabled = true
	environment.fog_light_color = Color("b8c9d2")
	environment.fog_density = 0.0018
	environment.fog_sky_affect = 0.0
	world_environment.environment = environment
	var world := Node3D.new()
	world.name = "Workshop"
	world.rotation_degrees.y = -18.0
	parent.add_child(world)
	# A continuous workshop floor supports the side stations below the course.
	# It is scenery only: no collider, course field, anchor or transition.
	floor_node.mesh = KeycapVisualScript.rounded_mesh(Vector2(56, 26), 0.25, 0.12)
	floor_node.position = Vector3(21, -1.08, 0).rotated(Vector3.UP, deg_to_rad(-18))
	floor_node.rotation_degrees.y = -18
	floor_node.material_override = _floor_material()
	floor_node.visible = true
	# Recessed workbench: below the course, never a same-height apparent route.
	_box(world, "Workbench", Vector3(21, -0.58, 0), Vector3(52, 0.7, 17), _wood_material(), 0.18)
	_box(world, "DeskMat", Vector3(21, -0.20, 0), Vector3(50, 0.06, 10.2), _mat_material(), 0.12)
	_build_keyboard_atelier(world, quality)
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


static func _wood_material(floor_planks: bool = false, grain_along_z: bool = false, grain_vertical: bool = false) -> ShaderMaterial:
	var key := "floor_wood" if floor_planks else ("wood_y" if grain_vertical else "wood_z" if grain_along_z else "wood")
	if _materials.has(key):
		return _materials[key]
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/presentation/workshop_wood.gdshader")
	material.set_shader_parameter("wood_color", WoodColor)
	material.set_shader_parameter("wood_normal", WoodNormal)
	material.set_shader_parameter("wood_roughness", WoodRoughness)
	material.set_shader_parameter("floor_planks", floor_planks)
	material.set_shader_parameter("grain_along_z", grain_along_z)
	material.set_shader_parameter("grain_vertical", grain_vertical)
	_materials[key] = material
	return material


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


static func _worktop_material() -> ShaderMaterial:
	if not _materials.has("worktop"):
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/presentation/workshop_worktop.gdshader")
		_materials["worktop"] = material
	return _materials["worktop"]


static func _build_keyboard_atelier(world: Node3D, quality: bool) -> void:
	var enamel := _material("476563", 0.43, 0.22)
	var dark := _material("253b3c", 0.75)
	var brass := _material("b49668", 0.39, 0.65)
	var ivory := _material("d7cab4", 0.56)
	var plum := _material("84768d", 0.64)
	# Three asymmetrical work cells tell one workflow. All are outside |z|=4.5;
	# below them is the continuous scenery floor, never a new course connection.
	_work_cell(world, Vector3(11.5, 0, -6.5), -1, "01  /  SWITCH-MONTAGE", enamel, brass)
	_keyboard(world, Vector3(11.1, 0.91, -6.12), true, enamel, ivory, brass)
	_parts_bin(world, Vector3(8.9, 0.88, -6.05), plum, ivory)
	_tool_rack(world, Vector3(13.9, 1.0, -7.61), ivory, brass)
	_task_lamp(world, Vector3(9.0, 0.83, -7.33), 1, enamel, brass, quality)
	# A few loose switch parts and a wire puller sit on the assembly surface.
	_switch(world, Vector3(13.8, 0.87, -5.76), 0.5, plum, ivory, brass)
	_tube(world, [Vector3(14.4, 0.9, -6.0), Vector3(14.4, 0.9, -5.48), Vector3(14.75, 0.9, -5.48), Vector3(14.75, 0.9, -6.0)], 0.018, brass)
	_box(world, "PullerGrip", Vector3(14.57, 0.91, -6.17), Vector3(0.34, 0.13, 0.34), plum, 0.04)
	_work_cell(world, Vector3(24.5, 0, 6.5), 1, "02  /  FARBEN & PROFILE", enamel, brass)
	_sample_board(world, Vector3(24.5, 1.1, 7.58), ivory, brass)
	for i in 3:
		_parts_bin(world, Vector3(22.1 + i * 1.25, 0.88, 5.9), [_material("a77c79", 0.66), plum, _material("9ba58b", 0.65)][i], ivory)
	_task_lamp(world, Vector3(27.1, 0.83, 7.24), -1, enamel, brass, quality)
	# One profile sample shows a separated shell/stem in a dedicated cradle.
	_switch(world, Vector3(26.4, 0.88, 5.8), 0.68, plum, ivory, brass)
	_box(world, "SectionCap", Vector3(26.4, 1.58, 5.8), Vector3(0.62, 0.19, 0.62), ivory, 0.075)
	_work_cell(world, Vector3(38.1, 0, -6.5), -1, "03  /  TASTATUR-PRUEFUNG", enamel, brass)
	_keyboard(world, Vector3(37.7, 0.91, -6.07), false, plum, ivory, brass)
	_box(world, "TestInstrument", Vector3(40.5, 1.21, -6.85), Vector3(1.05, 0.73, 0.86), enamel, 0.1)
	_box(world, "TestScreen", Vector3(40.5, 1.24, -6.405), Vector3(0.75, 0.36, 0.024), dark, 0.025)
	for bar in 7:
		_box(world, "ResponseBar", Vector3(40.23 + bar * 0.09, 1.20 + sin(bar * 0.8) * 0.048, -6.384), Vector3(0.043, 0.12 + sin(bar * 0.8) * 0.08, 0.01), _material("a9baa0", 0.6), 0.004)
	_tube(world, [Vector3(39.5, 0.86, -6.4), Vector3(40.0, 0.86, -5.8), Vector3(41.2, 0.86, -5.8), Vector3(41.1, 1.0, -6.7)], 0.035, dark)
	_task_lamp(world, Vector3(35.6, 0.83, -7.28), 1, enamel, brass, quality)
	# A single supply wall groups boxed keyboards and matching parts storage.
	_box(world, "SupplyBack", Vector3(35.2, 1.45, 11.8), Vector3(9.1, 4.65, 0.26), enamel, 0.11)
	for level in 3:
		var y := -0.6 + level * 1.36
		_box(world, "SupplyShelf", Vector3(35.2, y, 11.1), Vector3(9.1, 0.14, 1.8), _wood_material(), 0.055)
		for box in (3 if level != 1 else 5):
			var width := 2.55 if level != 1 else 1.37
			var x := 31.1 + width * 0.5 + box * (width + 0.18)
			_box(world, "KeyboardCarton", Vector3(x, y + 0.37, 11.1), Vector3(width, 0.57, 1.4), _material("b19a7b", 0.92), 0.025)
			_box(world, "CartonBand", Vector3(x, y + 0.37, 10.383), Vector3(width * 0.17, 0.54, 0.017), plum if level == 1 else ivory)
			_box(world, "CartonLabel", Vector3(x - width * 0.21, y + 0.4, 10.366), Vector3(width * 0.28, 0.22, 0.012), ivory, 0.013)
	_label(world, "SupplyLabel", "KEYCAPS  /  ATELIER", Vector3(35.2, 3.43, 11.65), Vector3(0, 180, 0), 0.008)
	_plant(world, Vector3(30.4, -0.95, 10.9), _material("ad7d63", 0.77))
	_plant(world, Vector3(42.8, -0.95, -9.5), ivory)
	# Timber canopy belongs to the assembly cell. Its open slats cast light only
	# across the side workspace and leave the course's decision views unobstructed.
	for x in [6.7, 16.3]:
		_box(world, "CanopyPost", Vector3(x, 1.92, -8.25), Vector3(0.25, 5.74, 0.25), _wood_material(false, false, true), 0.045)
		_box(world, "CanopyShoe", Vector3(x, -0.69, -8.25), Vector3(0.36, 0.5, 0.36), enamel, 0.035)
	_box(world, "CanopyBeam", Vector3(11.5, 4.63, -8.25), Vector3(10.25, 0.34, 0.32), _wood_material(), 0.065)
	for rib in 8:
		_box(world, "CanopySlat", Vector3(6.9 + rib * 1.31, 4.83, -6.78), Vector3(0.19, 0.16, 3.42), _wood_material(false, true), 0.03)
	# A continuous utility conduit links the three cells behind the work surface.
	for side in [-1.0, 1.0]:
		_tube(world, [Vector3(5.3, -0.86, side * 9.0), Vector3(16.8, -0.86, side * 9.0), Vector3(29.8, -0.86, side * 9.0), Vector3(43.5, -0.86, side * 9.0)], 0.055, dark)
	# Continuous edge joinery frames the assembly bed; no repeated loose dials.
	for side in [-1.0, 1.0]:
		_box(world, "MatBinding", Vector3(21, -0.153, side * 5.06), Vector3(50, 0.025, 0.045), _material("998975", 0.89))
		_box(world, "BenchApron", Vector3(21, -0.57, side * 8.37), Vector3(51.2, 0.25, 0.18), enamel, 0.055)
		_box(world, "ServiceRail", Vector3(22, 0.13, side * 12.5), Vector3(51, 0.12, 0.12), brass, 0.025)
		for x in [0.0, 17.0, 34.0, 47.5]:
			_cylinder(world, Vector3(x, -0.4, side * 12.5), 0.075, 1.14, brass)
			_cylinder(world, Vector3(x, -0.9, side * 12.5), 0.17, 0.08, dark)
	# Destination uses the same violet accent as the hoodie and sample collection.
	for side in [-1.0, 1.0]:
		_box(world, "PortalFoot", Vector3(46.4, 0.03, side * 2.2), Vector3(0.92, 0.35, 0.82), brass, 0.07)
		_box(world, "PortalPost", Vector3(46.4, 1.9, side * 2.2), Vector3(0.6, 4.1, 0.48), plum, 0.10)
		_box(world, "PortalInlay", Vector3(46.05, 2, side * 2.2), Vector3(0.025, 3.3, 0.12), ivory)
	_box(world, "PortalLintel", Vector3(46.4, 3.9, 0), Vector3(0.6, 0.62, 4.85), plum, 0.10)
	_box(world, "PortalCrown", Vector3(46.4, 4.25, 0), Vector3(0.72, 0.14, 5.05), brass, 0.05)
	_label(world, "AtelierFinish", "Z I E L", Vector3(46.05, 3.93, 0), Vector3(0, -90, 0), 0.0055)


static func _work_cell(world: Node3D, at: Vector3, side: float, title: String, enamel: Material, brass: Material) -> void:
	var dark := _material("253b3c", 0.75)
	_box(world, "WorkCellCabinet", at + Vector3(0, -0.07, 0), Vector3(8.1, 1.52, 2.9), enamel, 0.13)
	_box(world, "WorkCellTop", at + Vector3(0, 0.78, 0), Vector3(8.5, 0.18, 3.15), _worktop_material(), 0.075)
	for foot in [-3.4, 3.4]:
		for depth in [-1.1, 1.1]:
			_cylinder(world, at + Vector3(foot, -0.89, depth), 0.12, 0.22, dark)
	for drawer in 4:
		for row in 2:
			var p := at + Vector3(-3.0 + drawer * 2, -0.39 + row * 0.63, -side * 1.49)
			_box(world, "DrawerReveal", p, Vector3(1.86, 0.56, 0.04), dark, 0.026)
			_box(world, "DrawerFace", p + Vector3(0, 0, -side * 0.03), Vector3(1.78, 0.48, 0.06), enamel, 0.035)
			_tube(world, [p + Vector3(-0.28, 0.07, -side * 0.08), p + Vector3(-0.23, 0.07, -side * 0.18), p + Vector3(0.23, 0.07, -side * 0.18), p + Vector3(0.28, 0.07, -side * 0.08)], 0.026, brass)
	_box(world, "CellBack", at + Vector3(0, 1.8, side * 1.5), Vector3(8.4, 1.95, 0.13), enamel, 0.06)
	_box(world, "CellCornice", at + Vector3(0, 2.79, side * 1.45), Vector3(8.55, 0.12, 0.32), _wood_material(), 0.04)
	_label(world, "CellLabel", title, at + Vector3(0, 2.46, side * 1.42), Vector3(0, 0 if side < 0 else 180, 0), 0.0045)


static func _keyboard(world: Node3D, at: Vector3, open_switches: bool, case_material: Material, caps: Material, metal: Material) -> void:
	var dark := _material("253b3c", 0.75)
	_box(world, "KeyboardCase", at, Vector3(4.55, 0.24, 1.55), case_material, 0.10)
	_box(world, "KeyboardPlate", at + Vector3.UP * 0.13, Vector3(4.33, 0.025, 1.35), metal if open_switches else dark, 0.04)
	for row in 3:
		for column in 11:
			var p := at + Vector3(-1.95 + column * 0.389, 0.16, -0.43 + row * 0.39)
			if open_switches:
				_switch(world, p, 0.27, case_material, caps, metal)
			else:
				_box(world, "DisplayKeycap", p + Vector3.UP * 0.075, Vector3(0.345, 0.16, 0.345), caps if column > 0 else case_material, 0.05)
	_box(world, "Spacebar", at + Vector3(0.15, 0.24, 0.6), Vector3(1.95, 0.16, 0.25), caps, 0.045)
	for screw in [-2.08, 2.08]:
		_cylinder(world, at + Vector3(screw, 0.14, 0.61), 0.035, 0.018, metal, 10)


static func _switch(world: Node3D, at: Vector3, size: float, stem: Material, shell: Material, metal: Material) -> void:
	_box(world, "SwitchHousing", at + Vector3.UP * size * 0.19, Vector3(size, size * 0.38, size), shell, size * 0.08)
	_box(world, "SwitchTop", at + Vector3.UP * size * 0.44, Vector3(size * 0.75, size * 0.15, size * 0.75), metal, size * 0.04)
	_box(world, "CrossStem", at + Vector3.UP * size * 0.63, Vector3(size * 0.58, size * 0.3, size * 0.19), stem, size * 0.025)
	_box(world, "CrossStem", at + Vector3.UP * size * 0.63, Vector3(size * 0.19, size * 0.3, size * 0.58), stem, size * 0.025)


static func _parts_bin(world: Node3D, at: Vector3, color: Material, ivory: Material) -> void:
	_box(world, "PartsTray", at, Vector3(1.03, 0.12, 0.88), _material("253b3c", 0.75), 0.035)
	for side in [-1.0, 1.0]:
		_box(world, "TrayRim", at + Vector3(side * 0.49, 0.13, 0), Vector3(0.07, 0.25, 0.88), color, 0.025)
		_box(world, "TrayRim", at + Vector3(0, 0.13, side * 0.41), Vector3(1.03, 0.25, 0.07), color, 0.025)
	for i in 4:
		_box(world, "SpareKeycap", at + Vector3(-0.22 + (i % 2) * 0.43, 0.17, -0.2 + (i / 2) * 0.38), Vector3(0.34, 0.19, 0.34), ivory, 0.065)


static func _sample_board(world: Node3D, at: Vector3, ivory: Material, brass: Material) -> void:
	_box(world, "SampleFrame", at + Vector3.UP * 0.53, Vector3(5.8, 1.18, 0.1), _wood_material(), 0.06)
	_box(world, "SampleBacking", at + Vector3(0, 0.53, -0.07), Vector3(5.55, 0.99, 0.05), ivory, 0.03)
	for column in 8:
		var colors := ["e2d6bd", "bda283", "a6b195", "6c8c84", "b39db6", "b98c86", "80929d", "596770"]
		for row in 2:
			_box(world, "ColorSample", at + Vector3(-2.3 + column * 0.66, 0.27 + row * 0.5, -0.17), Vector3(0.46, 0.37, 0.21), _material(colors[column], 0.62), 0.07)
	for side in [-1.0, 1.0]:
		_cylinder(world, at + Vector3(side * 2.69, 0.02, -0.1), 0.065, 0.22, brass)


static func _tool_rack(world: Node3D, at: Vector3, ivory: Material, brass: Material) -> void:
	_box(world, "ToolStrip", at + Vector3.UP * 0.48, Vector3(1.5, 0.12, 0.1), brass, 0.025)
	for tool in 4:
		_box(world, "ToolGrip", at + Vector3(-0.55 + tool * 0.36, 0.22, 0.05), Vector3(0.12, 0.35, 0.13), ivory, 0.044)
		_box(world, "ToolShaft", at + Vector3(-0.55 + tool * 0.36, 0.58, 0.05), Vector3(0.035, 0.39, 0.045), brass)


static func _task_lamp(world: Node3D, at: Vector3, direction: float, enamel: Material, brass: Material, quality: bool) -> void:
	_cylinder(world, at + Vector3.UP * 0.07, 0.38, 0.14, enamel)
	_tube(world, [at + Vector3.UP * 0.1, at + Vector3(0, 1.2, 0), at + Vector3(0.25, 1.7, direction * 0.52), at + Vector3(0.1, 1.79, direction * 0.88)], 0.055, brass)
	var shade_at := at + Vector3(0.1, 1.74, direction * 0.88)
	_box(world, "TaskShade", shade_at, Vector3(1.4, 0.16, 0.55), enamel, 0.06)
	var diffuser := _material("f4dfb6", 0.64)
	diffuser.emission_enabled = true
	diffuser.emission = Color("e9b477")
	diffuser.emission_energy_multiplier = 0.5
	_box(world, "TaskDiffuser", shade_at + Vector3.DOWN * 0.09, Vector3(1.2, 0.024, 0.41), diffuser)
	# Local warm pools are decorative, shadowless and shared with Compatibility.
	var light := OmniLight3D.new()
	light.name = "TaskLight"
	light.position = shade_at + Vector3.DOWN * 0.17
	light.light_color = Color("ffcf91")
	light.light_energy = 0.65 if quality else 0.4
	light.omni_range = 3.1
	light.shadow_enabled = false
	world.add_child(light)


static func _label(world: Node3D, node_name: String, text: String, at: Vector3, rotation: Vector3, pixel_size: float) -> void:
	var sign := Label3D.new()
	sign.name = node_name
	sign.text = text
	sign.font = WorldFont
	sign.font_size = 96
	sign.pixel_size = pixel_size
	sign.outline_size = 0
	sign.shaded = true
	sign.position = at
	sign.rotation_degrees = rotation
	sign.modulate = Color("efdfc6")
	world.add_child(sign)
