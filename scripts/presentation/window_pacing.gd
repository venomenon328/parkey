class_name WindowPacing
extends Node

## Presentation scheduling only. Never touches the input adapter or run clock.
## Mailbox presents the newest complete image; a display-rate cap avoids
## unbounded GPU work. Refresh changes are handled outside input events.
var window: Window
var elapsed := 0.0
var applied_limit := 0
var explicit_limit := false


static func frame_limit(refresh_hz: float) -> int:
	return maxi(1, ceili(refresh_hz)) if is_finite(refresh_hz) and refresh_hz > 0 else 60


func _ready() -> void:
	window = get_window()
	explicit_limit = Engine.max_fps > 0
	_refresh()
	# Initialize the Windows swapchain with FIFO, then select Mailbox on the
	# existing window. Native Vulkan startup in Mailbox can choose a different
	# NVIDIA/DWM presentation path than switching the established swapchain.
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= 0.5:
		elapsed = 0.0
		_refresh()


func _exit_tree() -> void:
	# A recreated scene must not mistake our former cap for a CLI override.
	if not explicit_limit and Engine.max_fps == applied_limit:
		Engine.max_fps = 0


func _refresh() -> void:
	if explicit_limit:
		return
	var limit := frame_limit(DisplayServer.screen_get_refresh_rate(window.current_screen))
	if applied_limit != limit:
		applied_limit = limit
		Engine.max_fps = limit
