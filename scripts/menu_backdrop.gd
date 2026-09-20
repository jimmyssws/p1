class_name MenuBackdrop
extends Control

# Tam ekran arka plan: gerçek görsel + vignette. Hepsi bu.

var _tex : Texture2D = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	if ResourceLoader.exists("res://assets/menu_bg.jpg"):
		_tex = load("res://assets/menu_bg.jpg")
	call_deferred("queue_redraw")

func _draw() -> void:
	var s := get_rect().size
	if s.x < 10.0 or s.y < 10.0: return

	if _tex:
		draw_texture_rect(_tex, Rect2(Vector2.ZERO, s), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.05, 0.05, 0.07))

	# Vignette — köşeleri karart
	for i in 10:
		var a := 0.025 + float(i) * 0.012
		var m := float(i) * 18.0
		draw_rect(Rect2(m, m * 0.7, s.x - m * 2.0, s.y - m * 1.4),
			Color(0.0, 0.0, 0.0, a), false, 20.0)

	# Sol panel için ekstra karartma (menü okunabilirliği)
	var grad_w := s.x * 0.50
	for i in 20:
		var r := float(i) / 19.0
		var a := (1.0 - r) * 0.68
		draw_rect(Rect2(float(i) * (grad_w / 20.0), 0.0, grad_w / 20.0 + 2.0, s.y),
			Color(0.02, 0.02, 0.03, a))
