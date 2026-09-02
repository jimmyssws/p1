class_name MenuBackdrop
extends Control

# Procedural rally-night tableau for the title screen. Drawn at runtime so the menu
# stays connected to the game's world without requiring an image asset.
var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	call_deferred("queue_redraw")

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	if size.x <= 1.0 or size.y <= 1.0:
		return
	# Night sky: vertical tonal bands create depth without a flat color field.
	var bands := 20
	for i in bands:
		var ratio := float(i) / float(bands - 1)
		var color := Color("071018").lerp(Color("182534"), ratio)
		draw_rect(Rect2(0, ratio * size.y, size.x, size.y / bands + 2.0), color)
	# Distant warm city glow.
	draw_circle(Vector2(size.x * 0.69, size.y * 0.42), size.y * 0.36, Color(0.72, 0.21, 0.11, 0.08))
	# Searchlight beams drifting over the plaza.
	var pulse := sin(t * 0.55) * size.x * 0.035
	_draw_beam(Vector2(size.x * 0.76 + pulse, size.y * 0.08), Vector2(size.x * 0.52, size.y * 0.78), Vector2(size.x * 0.82, size.y * 0.78), Color(0.92, 0.72, 0.31, 0.10))
	_draw_beam(Vector2(size.x * 0.93 - pulse, size.y * 0.18), Vector2(size.x * 0.59, size.y * 0.79), Vector2(size.x * 0.90, size.y * 0.79), Color(0.48, 0.73, 0.92, 0.07))
	# Distant skyline.
	var skyline := PackedVector2Array([
		Vector2(size.x * 0.32, size.y * 0.62), Vector2(size.x * 0.32, size.y * 0.49),
		Vector2(size.x * 0.38, size.y * 0.49), Vector2(size.x * 0.38, size.y * 0.55),
		Vector2(size.x * 0.44, size.y * 0.55), Vector2(size.x * 0.44, size.y * 0.38),
		Vector2(size.x * 0.51, size.y * 0.38), Vector2(size.x * 0.51, size.y * 0.59),
		Vector2(size.x * 0.58, size.y * 0.59), Vector2(size.x * 0.58, size.y * 0.46),
		Vector2(size.x * 0.66, size.y * 0.46), Vector2(size.x * 0.66, size.y * 0.62),
		Vector2(size.x, size.y * 0.62), Vector2(size.x, size.y), Vector2(size.x * 0.32, size.y)
	])
	draw_colored_polygon(skyline, Color("0b1119"))
	# Central stage and screen, deliberately off-center to leave the menu column calm.
	draw_rect(Rect2(size.x * 0.58, size.y * 0.49, size.x * 0.28, size.y * 0.19), Color("10151d"))
	draw_rect(Rect2(size.x * 0.595, size.y * 0.51, size.x * 0.25, size.y * 0.115), Color("5d171c"))
	draw_rect(Rect2(size.x * 0.60, size.y * 0.52, size.x * 0.24, size.y * 0.006), Color("d7a83f"))
	draw_rect(Rect2(size.x * 0.70, size.y * 0.595, size.x * 0.035, size.y * 0.15), Color("17130f"))
	# Flag strips add a moving-event feeling.
	for x in [0.56, 0.86]:
		draw_line(Vector2(size.x * x, size.y * 0.27), Vector2(size.x * x, size.y * 0.70), Color("a9a18f"), 2.0)
		var sway := sin(t * 1.1 + x * 8.0) * 12.0
		var flag := PackedVector2Array([Vector2(size.x * x, size.y * 0.30), Vector2(size.x * x + size.x * 0.065 + sway, size.y * 0.325), Vector2(size.x * x, size.y * 0.37)])
		draw_colored_polygon(flag, Color("9e282c"))
	# Crowd is an irregular silhouette, not a bottom rectangle.
	var crowd := PackedVector2Array([Vector2(0, size.y), Vector2(0, size.y * 0.80)])
	for i in range(52):
		var x := size.x * float(i) / 51.0
		var h := size.y * (0.08 + 0.07 * (0.5 + 0.5 * sin(i * 1.91)))
		crowd.append(Vector2(x, size.y * 0.81 - h))
		crowd.append(Vector2(x + size.x / 105.0, size.y * 0.81))
	crowd.append(Vector2(size.x, size.y))
	draw_colored_polygon(crowd, Color("050709"))
	# Cinema vignette focuses attention on the scene rather than a card.
	for i in 8:
		var alpha := 0.024 + float(i) * 0.012
		draw_rect(Rect2(i * 18, i * 15, size.x - i * 36, size.y - i * 30), Color(0, 0, 0, alpha), false, 18.0)

func _draw_beam(apex: Vector2, left: Vector2, right: Vector2, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([apex, left, right]), color)
