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
var output_directory := "user://parkey-test-results/render-evidence"


static func requested() -> bool:
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('evidence') === '1'"))
	return OS.get_cmdline_user_args().has("--p2b-evidence")


func _ready() -> void:
	scene = get_parent()
	started = Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(output_directory)
	_run.call_deferred()


func _process(_delta: float) -> void:
	var tick := Time.get_ticks_usec()
	if measuring and last_tick > 0 and skip_frames <= 0:
		frames_ms.append(float(tick - last_tick) / 1000.0)
	skip_frames = maxi(0, skip_frames - 1)
	last_tick = tick


func _run() -> void:
	# Set physical client pixels after startup DPI negotiation, then verify the texture.
	if not OS.has_feature("web"):
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--evidence-size="):
				var dimensions := argument.trim_prefix("--evidence-size=").split("x")
				if dimensions.size() == 2:
					get_window().size = Vector2i(int(dimensions[0]), int(dimensions[1]))
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_emit({"kind": "first_frame", "engine_ticks_ms": Time.get_ticks_msec(), "renderer": RenderingServer.get_current_rendering_method(), "viewport": _resolution(), "adapter": RenderingServer.get_video_adapter_name()})
	await get_tree().create_timer(3.0).timeout
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
	var report := {"kind": "complete", "renderer": RenderingServer.get_current_rendering_method(), "viewport": _resolution(), "engine": Engine.get_version_info().string, "adapter": RenderingServer.get_video_adapter_name(), "sample_frames": frames_ms.size(), "sample_seconds": total / 1000.0, "mean_fps": frames_ms.size() * 1000.0 / total, "p50_ms": _percentile(0.5), "p95_ms": _percentile(0.95), "p99_ms": _percentile(0.99), "max_ms": frames_ms[-1], "frames_over_20_ms": over_20, "frames_over_33_ms": over_33, "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), "runs": reports}
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
	print("P2B_EVIDENCE " + JSON.stringify(report))
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
