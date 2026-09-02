class_name MenuActionSkin
extends Control

# A non-rectangular presentation layer for a normal Godot Button.
# The parent remains the only interactive control; this node only draws feedback.
const GOLD := Color("e5a93c")
const PALE := Color("e7e9e6")
const STEEL := Color("668090")
const RED := Color("ca3432")

var hovered := false
var pressed := false
var pulse := 0.0
var is_danger := false
var host_button: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# This is placed on the menu root, above the transparent button text layer.
	show_behind_parent = false
	top_level = true
	z_index = 100
	if host_button == null:
		bind(get_parent() as Button)
	resized.connect(queue_redraw)
	set_process(true)
	queue_redraw()

func bind(button: Button) -> void:
	if button == null or host_button == button:
		return
	host_button = button
	is_danger = "KAPAT" in host_button.text
	host_button.mouse_entered.connect(_on_entered)
	host_button.mouse_exited.connect(_on_exited)
	host_button.button_down.connect(_on_down)
	host_button.button_up.connect(_on_up)

func _process(delta: float) -> void:
	pulse += delta
	if host_button and (size != host_button.size or global_position != host_button.global_position):
		global_position = host_button.global_position
		size = host_button.size
		queue_redraw()
	if hovered:
		queue_redraw()

func _on_entered() -> void:
	hovered = true
	queue_redraw()

func _on_exited() -> void:
	hovered = false
	pressed = false
	queue_redraw()

func _on_down() -> void:
	pressed = true
	queue_redraw()

func _on_up() -> void:
	pressed = false
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x < 8.0 or s.y < 8.0:
		return
	var accent := RED if is_danger else GOLD
	var mid_y := s.y * 0.5
	var notch := min(18.0, s.y * 0.34)
	# The default state is a pair of open tactical brackets — intentionally not a card.
	draw_line(Vector2(2, 5), Vector2(28, 5), STEEL, 1.0)
	draw_line(Vector2(2, 5), Vector2(2, s.y - 5), STEEL, 1.0)
	draw_line(Vector2(2, s.y - 5), Vector2(28, s.y - 5), STEEL, 1.0)
	draw_line(Vector2(s.x - 24, 5), Vector2(s.x - 6, 5), STEEL, 1.0)
	draw_line(Vector2(s.x - 6, 5), Vector2(s.x - 6, s.y - 5), STEEL, 1.0)
	draw_line(Vector2(s.x - 24, s.y - 5), Vector2(s.x - 6, s.y - 5), STEEL, 1.0)
	# Left chevron acts as an in-world selector marker.
	var chevron := PackedVector2Array([Vector2(8, mid_y), Vector2(19, mid_y - 8), Vector2(19, mid_y + 8)])
	draw_colored_polygon(chevron, accent if hovered else STEEL)
	if hovered:
		var fill := Color(accent.r, accent.g, accent.b, 0.11 if not pressed else 0.20)
		var body := PackedVector2Array([
			Vector2(25, 4), Vector2(s.x - 7, 4), Vector2(s.x - 7, s.y - 4),
			Vector2(25, s.y - 4), Vector2(12, mid_y)
		])
		draw_colored_polygon(body, fill)
		draw_line(Vector2(28, 4), Vector2(s.x - 7, 4), accent, 2.0)
		draw_line(Vector2(28, s.y - 4), Vector2(s.x - 7, s.y - 4), accent, 2.0)
		var scan_x := 35.0 + fmod(pulse * 105.0, max(1.0, s.x - 80.0))
		draw_line(Vector2(scan_x, 7), Vector2(scan_x, s.y - 7), Color(accent.r, accent.g, accent.b, 0.55), 1.0)
		# A small diamond on the trailing edge makes the interaction feel like equipment, not web nav.
		var diamond := PackedVector2Array([
			Vector2(s.x - 14, mid_y), Vector2(s.x - 9, mid_y - 5),
			Vector2(s.x - 4, mid_y), Vector2(s.x - 9, mid_y + 5)
		])
		draw_colored_polygon(diamond, PALE)
