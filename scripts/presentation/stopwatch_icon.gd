extends Control

## Resolution-independent original line icon; no symbol-font fallback.
func _draw() -> void:
	var ink := Color("fff5e5")
	draw_arc(Vector2(17, 24), 14, 0, TAU, 48, ink, 2.8, true)
	draw_line(Vector2(17, 10), Vector2(17, 5), ink, 2.8, true)
	draw_line(Vector2(12, 4), Vector2(22, 4), ink, 3.2, true)
	draw_line(Vector2(28, 12), Vector2(31, 8), ink, 2.8, true)
	draw_line(Vector2(17, 24), Vector2(11, 17), ink, 2.4, true)
	draw_line(Vector2(17, 24), Vector2(17, 14), ink, 2.4, true)
