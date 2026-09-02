class_name RadioTuner
extends Control

const GOLD := Color("e5a93c")
const INK := Color("091018")
const TEXT := Color("e7e9e6")
var phase := 0.0
var station := 104.2
var title := "MEYDAN ANA YAYINI"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_left = 440.0
	offset_right = -75.0
	offset_top = -166.0
	offset_bottom = -42.0

func tune(value: float, label: String) -> void:
	station = value
	title = label
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x < 40: return
	draw_style_box(_box(), Rect2(Vector2.ZERO, s))
	draw_string(ThemeDB.fallback_font, Vector2(26, 28), "MITING FM  //  " + title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TEXT)
	draw_string(ThemeDB.fallback_font, Vector2(s.x - 132, 28), "%.1f MHz" % station, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD)
	var y := 66.0
	draw_line(Vector2(28,y), Vector2(s.x-28,y), Color("61707a"), 2)
	for i in 33:
		var x := 28.0 + (s.x-56.0) * float(i)/32.0
		var h := 18.0 if i % 4 == 0 else 9.0
		draw_line(Vector2(x,y-h), Vector2(x,y+h), Color("9aa5a8"), 1)
	var knob_x: float = 28.0 + (s.x-56.0) * clampf((station-88.0)/18.0, 0.0, 1.0)
	draw_circle(Vector2(knob_x,y), 12.0 + sin(phase*3.0)*1.5, GOLD)
	draw_circle(Vector2(knob_x,y), 5.0, INK)
	draw_string(ThemeDB.fallback_font, Vector2(28,105), "88.0", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("89959a"))
	draw_string(ThemeDB.fallback_font, Vector2(s.x-58,105), "106.0", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("89959a"))

func _box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.025,0.045,0.065,0.88)
	box.border_width_top = 2
	box.border_color = GOLD.darkened(0.25)
	box.corner_radius_top_left = 12
	box.corner_radius_top_right = 12
	box.shadow_color = Color(0,0,0,0.65)
	box.shadow_size = 14
	return box
