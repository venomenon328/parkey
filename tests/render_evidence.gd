extends Node

## Opt-in synthetic viewport input in the real exported renderer.
## No test clock, no core calls, no writes to player best times.
var scene: Node
var frames_ms: Array[float] = []
var reports: Array[Dictionary] = []
var measuring := false
var last_tick := 0
var started := 0
var skip_frames := 0
var frames_without_focus := 0
var first_frame := {}
var pacing_seconds := 0.0
var output_directory := "user://parkey-test-results/render-evidence"


static func requested() -> bool:
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('evidence') === '1'"))
	return OS.get_cmdline_user_args().has("--p2b-evidence")


func _ready() -> void:
	scene = get_parent()
	started = Time.get_ticks_usec()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--evidence-output="):
			output_directory = argument.trim_prefix("--evidence-output=")
		if argument.begins_with("--evidence-pacing="):
			pacing_seconds = clampf(float(argument.trim_prefix("--evidence-pacing=")), 5.0, 120.0)
	DirAccess.make_dir_recursive_absolute(output_directory)
	_run.call_deferred()


func _process(_delta: float) -> void:
	var tick := Time.get_ticks_usec()
	if measuring and last_tick > 0 and skip_frames <= 0:
		frames_ms.append(float(tick - last_tick) / 1000.0)
		if not get_window().has_focus():
			frames_without_focus += 1
	skip_frames = maxi(0, skip_frames - 1)
	last_tick = tick


func _run() -> void:
	# Set physical client pixels after startup DPI negotiation, then verify the texture.
	if not OS.has_feature("web"):
		get_window().current_screen = DisplayServer.get_primary_screen()
		for screen_index in DisplayServer.get_screen_count():
			if DisplayServer.screen_get_refresh_rate(screen_index) > DisplayServer.screen_get_refresh_rate(get_window().current_screen):
				get_window().current_screen = screen_index
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--evidence-screen="):
				get_window().current_screen = int(argument.trim_prefix("--evidence-screen="))
		get_window().position = DisplayServer.screen_get_position(get_window().current_screen)
		get_window().grab_focus()
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--evidence-position="):
				var position_parts := argument.trim_prefix("--evidence-position=").split(",")
				get_window().position = Vector2i(int(position_parts[0]), int(position_parts[1]))
			if argument.begins_with("--evidence-vsync="):
				DisplayServer.window_set_vsync_mode(int(argument.trim_prefix("--evidence-vsync=")))
			if argument.begins_with("--evidence-window-mode="):
				get_window().mode = int(argument.trim_prefix("--evidence-window-mode="))
			if argument.begins_with("--evidence-size="):
				var dimensions := argument.trim_prefix("--evidence-size=").split("x")
				if dimensions.size() == 2:
					get_window().size = Vector2i(int(dimensions[0]), int(dimensions[1]))
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_emit({"kind": "first_frame", "engine_ticks_ms": Time.get_ticks_msec(), "renderer": RenderingServer.get_current_rendering_method(), "viewport": _resolution(), "adapter": RenderingServer.get_video_adapter_name(), "screen_refresh_hz": DisplayServer.screen_get_refresh_rate(get_window().current_screen) if not OS.has_feature("web") else -1.0, "screen_index": get_window().current_screen, "window_position": str(get_window().position), "vsync_mode": DisplayServer.window_get_vsync_mode()})
	await get_tree().create_timer(3.0).timeout
	if not OS.has_feature("web") and OS.get_cmdline_user_args().has("--evidence-portrait"):
		# Separate model inspection, explicitly not the normal gameplay camera.
		scene.set_process(false)
		scene.figure.rotation = Vector3.ZERO
		var anchor: Vector3 = scene.figure.global_position
		for side in [-1.0, 1.0]:
			scene.camera.global_position = anchor + Vector3(0.0, 1.18, side * 3.2)
			scene.camera.look_at(anchor + Vector3.UP * 0.84)
			await _capture("character_front" if side < 0 else "character_back")
		get_tree().quit()
		return
	if pacing_seconds > 0.0:
		await _letters("AZK", 0.24)
		await get_tree().create_timer(1.0).timeout
		measuring = true
		await get_tree().create_timer(pacing_seconds).timeout
		measuring = false
		_finish_report()
		return
	await _capture("ready")
	await _letters("AZK", 0.24)
	await _capture("alpha")
	await _letters("F", 0.24)
	await _letters("K", 0.24)
	await _capture("visited_return")
	_key(KEY_X, "X")
	await get_tree().create_timer(0.05).timeout
	await _capture("error")
	await get_tree().create_timer(0.3).timeout
	_key(KEY_BACKSPACE)
	await _letters("AZKFJKMVB", 0.16)
	await _capture("beta")
	await _letters("QW", 0.24)
	await _capture("beta_long")
	_key(KEY_BACKSPACE)
	await get_tree().create_timer(0.3).timeout
	# All four complete P2a combinations; frame timings include movement and result I/O.
	measuring = true
	for route in ["AZKFJKMVBPLMGYUION", "AZKFJKMVBQWERTGYUION", "AZKASDFGHMVBPLMGYUION", "AZKASDFGHMVBQWERTGYUION"]:
		_key(KEY_BACKSPACE)
		await get_tree().create_timer(0.3).timeout
		await _letters(route, 0.16)
		reports.append({"route": route, "state": scene.session.state, "finished": scene.session.state == RunSession.State.FINISHED, "errors": scene.session.error_count, "duration_usec": scene.session.last_result.get("duration_usec", -1), "identity": scene.session.course_identity()})
		await get_tree().create_timer(0.6).timeout
	measuring = false
	await _capture("result")
	_key(KEY_F3)
	await get_tree().create_timer(0.2).timeout
	await _capture("debug")
	_key(KEY_F3)
	# Additional steady idle sampling at a decision after shader/material warmup.
	_key(KEY_BACKSPACE)
	await _letters("AZK", 0.12)
	await get_tree().create_timer(1.0).timeout
	measuring = true
	await get_tree().create_timer(15.0).timeout
	measuring = false
	_finish_report()


func _finish_report() -> void:
	var ordered_frames := frames_ms.duplicate()
	frames_ms.sort()
	var total := 0.0
	var over_20 := 0
	var over_33 := 0
	for frame in frames_ms:
		total += frame
		if frame > 20.0:
			over_20 += 1
		if frame > 33.334:
			over_33 += 1
	var report := {"kind": "complete", "renderer": RenderingServer.get_current_rendering_method(), "viewport": _resolution(), "engine": Engine.get_version_info().string, "adapter": RenderingServer.get_video_adapter_name(), "frames_without_focus": frames_without_focus, "sample_frames": frames_ms.size(), "sample_seconds": total / 1000.0, "mean_fps": frames_ms.size() * 1000.0 / total, "p50_ms": _percentile(0.5), "p95_ms": _percentile(0.95), "p99_ms": _percentile(0.99), "max_ms": frames_ms[-1], "frames_over_20_ms": over_20, "frames_over_33_ms": over_33, "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), "runs": reports}
	report["first_frame"] = first_frame
	report["measurement"] = "static_pacing_diagnostic" if pacing_seconds > 0.0 else "four_routes_and_decision_idle"
	report["frame_intervals_ms"] = ordered_frames
	if not OS.has_feature("web"):
		report["final_max_fps"] = Engine.max_fps
		report["final_vsync_mode"] = DisplayServer.window_get_vsync_mode()
		report["final_screen_refresh_hz"] = DisplayServer.screen_get_refresh_rate(get_window().current_screen)
	var file := FileAccess.open(output_directory.path_join("metrics.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	_emit(report)
	if not OS.has_feature("web"):
		get_tree().quit(0 if reports.all(func(item): return item.finished and item.errors == 0) else 1)


func _letters(letters: String, interval: float) -> void:
	for letter in letters:
		_key(letter.unicode_at(0), letter)
		await get_tree().create_timer(interval).timeout


func _key(code: int, letter: String = "") -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.unicode = letter.unicode_at(0) if not letter.is_empty() else 0
	event.pressed = true
	scene.get_viewport().push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	scene.get_viewport().push_input(event, true)


func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var screenshot: Image = scene.get_viewport().get_texture().get_image()
	if not OS.has_feature("web"):
		screenshot.save_png(output_directory.path_join(label + ".png"))
	else:
		_upload({"kind": "screenshot", "label": label, "png": Marshalls.raw_to_base64(screenshot.save_png_to_buffer())})
	_emit({"kind": "checkpoint", "label": label})
	await get_tree().create_timer(0.5).timeout


func _emit(report: Dictionary) -> void:
	if report.kind == "first_frame" and not OS.has_feature("web"):
		report["window_mode"] = get_window().mode
		report["window_size"] = str(get_window().size)
		report["window_position_with_decorations"] = str(DisplayServer.window_get_position_with_decorations())
		report["window_size_with_decorations"] = str(DisplayServer.window_get_size_with_decorations())
		report["rendering_driver"] = RenderingServer.get_current_rendering_driver_name()
		report["max_fps"] = Engine.max_fps
		report["arguments"] = OS.get_cmdline_args() + OS.get_cmdline_user_args()
		var screens: Array[Dictionary] = []
		for index in DisplayServer.get_screen_count():
			screens.append({"index": index, "position": str(DisplayServer.screen_get_position(index)), "size": str(DisplayServer.screen_get_size(index)), "refresh_hz": DisplayServer.screen_get_refresh_rate(index)})
		report["screens"] = screens
	if report.kind == "first_frame":
		first_frame = report.duplicate(true)
	var summary := report.duplicate()
	summary.erase("frame_intervals_ms")
	print("P2B_EVIDENCE " + JSON.stringify(summary))
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.parkeyEvidence = " + JSON.stringify(report))
		if report.kind == "complete":
			var browser_data = JavaScriptBridge.eval("JSON.stringify({user_agent:navigator.userAgent,canvas:[document.querySelector('canvas').width,document.querySelector('canvas').height],navigation_to_complete_ms:performance.now(),resources:performance.getEntriesByType('resource').map(x=>({name:x.name.split('/').pop(),duration_ms:x.duration,transfer_bytes:x.transferSize}))})")
			report["browser"] = JSON.parse_string(str(browser_data))
		if report.kind == "first_frame":
			report["navigation_to_frame_ms"] = JavaScriptBridge.eval("performance.now()")
		_upload(report)


func _upload(report: Dictionary) -> void:
	# Only the explicitly requested localhost evidence server receives this game's
	# own images/metrics. Normal web hosting has no upload or telemetry path.
	JavaScriptBridge.eval("if(location.hostname==='127.0.0.1' && new URLSearchParams(location.search).get('capture')==='1'){fetch('/__evidence',{method:'POST',headers:{'Content-Type':'application/json'},body:" + JSON.stringify(JSON.stringify(report)) + "}).catch(console.error)}")


func _resolution() -> String:
	# Image pixels are authoritative: stretched WindowTexture width can report a
	# scaled logical value that differs from the actual captured framebuffer.
	var rendered_size: Vector2i = scene.get_viewport().get_texture().get_image().get_size()
	return "%dx%d" % [rendered_size.x, rendered_size.y]


func _percentile(fraction: float) -> float:
	return frames_ms[mini(frames_ms.size() - 1, int(ceil(frames_ms.size() * fraction)) - 1)]
