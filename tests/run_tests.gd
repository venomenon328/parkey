extends SceneTree

const KeyInputNormalizer = preload("res://scripts/input/key_input_normalizer.gd")
const CoreSuite = preload("res://tests/core_suite.gd")
const IntegrationSuite = preload("res://tests/integration_suite.gd")

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_requested_suite")


func _run_requested_suite() -> void:
	var suite := _requested_suite(OS.get_cmdline_user_args())
	if suite.is_empty():
		_fail("Missing value for --suite. Available suites: smoke, core, integration, all.")
		_finish()
		return
	if suite != "smoke" and suite != "core" and suite != "integration" and suite != "all":
		_fail("Unknown suite '%s'. Available suites: smoke, core, integration, all." % suite)
		_finish()
		return

	if suite == "smoke" or suite == "all":
		_run_smoke_suite()
	if suite == "core" or suite == "all":
		CoreSuite.run(self)
	if suite == "integration" or suite == "all":
		await IntegrationSuite.run(self)
	_finish()


func _requested_suite(args: PackedStringArray) -> String:
	var index := args.find("--suite")
	if index == -1 or index + 1 >= args.size():
		return ""
	return args[index + 1]


func _run_smoke_suite() -> void:
	print("Running suite: smoke")
	_assert_true(ResourceLoader.exists("res://scenes/foundation.tscn"), "Foundation scene is importable.")
	_assert_true(ResourceLoader.exists("res://scripts/input/key_input_normalizer.gd"), "Input normalizer is importable.")
	_assert_true(ResourceLoader.exists("res://scripts/presentation/render_profile.gd"), "Render profile helper is importable.")
	_assert_true(ResourceLoader.exists("res://scenes/playable_course.tscn"), "Playable course scene is importable.")

	var scene := load("res://scenes/foundation.tscn") as PackedScene
	_assert_not_null(scene, "Foundation scene loads as PackedScene.")
	if scene != null:
		var instance := scene.instantiate()
		_assert_true(instance is Node3D, "Foundation scene has a 3D root.")
		_assert_not_null(instance.get_node_or_null("TestKey/Letter"), "Foundation scene contains a labelled test key.")
		_assert_not_null(instance.get_node_or_null("PlaceholderFigure/Head"), "Foundation scene contains a distinguishable figure head.")
		_assert_not_null(instance.get_node_or_null("Camera3D"), "Foundation scene contains a camera.")
		instance.free()

	_assert_equal(ProjectSettings.get_setting("application/run/main_scene"), "res://scenes/playable_course.tscn", "Playable course is registered as the main scene.")
	_assert_equal(ProjectSettings.get_setting("rendering/renderer/rendering_method.web"), "gl_compatibility", "Web renderer override is Compatibility.")
	_assert_equal(_preset_value("preset.0", "name"), "Windows Desktop", "Windows export preset has the required name.")
	_assert_equal(_preset_value("preset.0", "platform"), "Windows Desktop", "Windows export targets Windows Desktop.")
	_assert_equal(_preset_value("preset.0", "exclude_filter"), "build/**", "Windows export excludes build products.")
	_assert_equal(_preset_value("preset.1", "name"), "Web", "Web export preset has the required name.")
	_assert_equal(_preset_value("preset.1", "platform"), "Web", "Web export targets Web.")
	_assert_equal(_preset_value("preset.1", "exclude_filter"), "build/**", "Web export excludes build products.")
	_assert_false(_preset_value("preset.1.options", "variant/thread_support"), "Web export stays single-threaded in P0.")

	var qwertz_z := InputEventKey.new()
	qwertz_z.pressed = true
	qwertz_z.unicode = 122
	qwertz_z.keycode = KEY_Z
	qwertz_z.physical_keycode = KEY_Y
	var normalized_z := KeyInputNormalizer.normalize(qwertz_z)
	_assert_true(normalized_z.get("accepted", false), "Unicode Z is accepted even when its physical key is Y.")
	_assert_equal(normalized_z.get("letter", ""), "Z", "Layout normalization uses the visible Unicode character.")

	var shifted_y := InputEventKey.new()
	shifted_y.pressed = true
	shifted_y.shift_pressed = true
	shifted_y.unicode = 89
	shifted_y.keycode = KEY_Y
	var normalized_y := KeyInputNormalizer.normalize(shifted_y)
	_assert_true(normalized_y.get("accepted", false), "Shifted A-Z input is accepted.")
	_assert_equal(normalized_y.get("letter", ""), "Y", "Shifted input is normalized to uppercase.")

	var echo := InputEventKey.new()
	echo.pressed = true
	echo.echo = true
	echo.unicode = 89
	_assert_equal(KeyInputNormalizer.normalize(echo).get("reason", ""), "echo", "Key echo is ignored.")

	var released := InputEventKey.new()
	released.pressed = false
	released.unicode = 89
	_assert_equal(KeyInputNormalizer.normalize(released).get("reason", ""), "key_up", "Key-up is ignored.")

	var shortcut := InputEventKey.new()
	shortcut.pressed = true
	shortcut.ctrl_pressed = true
	shortcut.unicode = 89
	_assert_equal(KeyInputNormalizer.normalize(shortcut).get("reason", ""), "shortcut_modifier", "Shortcut modifiers are ignored.")


func _preset_value(section: String, key: String) -> Variant:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	_assert_equal(error, OK, "Export presets configuration loads.")
	if error != OK:
		return null
	return config.get_value(section, key, null)


func _assert_true(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		_fail(message)


func _assert_false(condition: bool, message: String) -> void:
	_assert_true(not condition, message)


func _assert_not_null(value: Variant, message: String) -> void:
	_assert_true(value != null, message)


func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	assertions += 1
	if actual != expected:
		_fail("%s Expected '%s', received '%s'." % [message, str(expected), str(actual)])


func _assert_vector_close(actual: Vector3, expected: Vector3, tolerance: float, message: String) -> void:
	assertions += 1
	if actual.distance_to(expected) > tolerance:
		_fail("%s Expected '%s', received '%s'." % [message, str(expected), str(actual)])


func _fail(message: String) -> void:
	failures.append(message)
	push_error(message)


func _finish() -> void:
	if assertions == 0:
		_fail("No assertions were selected.")
	if failures.is_empty():
		print("PASS: %d assertions, %d failures." % [assertions, failures.size()])
		quit(0)
		return
	for failure in failures:
		print("FAIL: %s" % failure)
	print("FAIL: %d assertions, %d failures." % [assertions, failures.size()])
	quit(1)
