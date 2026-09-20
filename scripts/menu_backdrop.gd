class_name MenuBackdrop
extends Control

# Menü arka planı: gerçek atmosferik miting görseli + hafif procedural overlay.
# Görsel yüklenemezse saf renkle devam eder.

var t := 0.0
var _bg_tex : Texture2D = null
var _loaded  := false

const C_GOLD    := Color(0.88, 0.65, 0.22)
const C_AMBER   := Color(0.93, 0.52, 0.08)
const C_RED_LED := Color(0.92, 0.20, 0.18)
const C_GREEN   := Color(0.22, 0.82, 0.38)

var _vu_levels  : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var _vu_targets : Array[float] = [0.3, 0.5, 0.7, 0.4, 0.6, 0.8, 0.3, 0.5]
var _signal     := 0.0
var _scan       := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	# Arka plan görselini yükle
	if ResourceLoader.exists("res://assets/menu_bg.jpg"):
		_bg_tex = load("res://assets/menu_bg.jpg") as Texture2D
		_loaded = _bg_tex != null
	call_deferred("queue_redraw")

func _process(delta: float) -> void:
	t += delta
	for i in 8:
		_vu_levels[i]  = lerp(_vu_levels[i], _vu_targets[i], delta * 6.0)
		if abs(_vu_levels[i] - _vu_targets[i]) < 0.02:
			_vu_targets[i] = randf()
	_signal = 0.55 + 0.45 * abs(sin(t * 0.6) * sin(t * 1.9))
	_scan   = fmod(t * 0.14, 1.0)
	queue_redraw()

func _draw() -> void:
	var s := get_rect().size
	if s.x < 10.0 or s.y < 10.0:
		return

	# ── Arka plan görseli ────────────────────────────────────────────────────
	if _loaded and _bg_tex:
		draw_texture_rect(_bg_tex, Rect2(Vector2.ZERO, s), false)
		# Görselin üstüne koyu overlay — menü okunabilirliği için
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.0, 0.0, 0.0, 0.58))
	else:
		# Fallback: basit degrade
		for i in 20:
			var r := float(i) / 19.0
			var c := Color(0.04, 0.045, 0.06).lerp(Color(0.015, 0.02, 0.03), r)
			draw_rect(Rect2(0.0, r * s.y, s.x, s.y / 19.0 + 2.0), c)

	# ── Film grain / vignette ──────────────────────────────────────────────
	# Vignet (köşeleri karart)
	for i in 8:
		var a := 0.03 + float(i) * 0.015
		var margin := float(i) * 20.0
		draw_rect(Rect2(margin, margin * 0.75, s.x - margin * 2.0, s.y - margin * 1.5),
			Color(0.0, 0.0, 0.0, a), false, 20.0)

	# Yatay ince tarama çizgileri (CRT efekti, hafif)
	var line_spacing := 4.0
	var line_count := int(s.y / line_spacing)
	for i in line_count:
		if i % 2 == 0:
			draw_line(Vector2(0.0, float(i) * line_spacing),
				Vector2(s.x, float(i) * line_spacing),
				Color(0.0, 0.0, 0.0, 0.08), 1.0)

	# ── Alt VU-meter şeridi ──────────────────────────────────────────────────
	var vu_h := 48.0
	var vu_y := s.y - vu_h - 12.0
	var vu_x := s.x * 0.02
	var vu_w := s.x * 0.96
	# Arka plan
	draw_rect(Rect2(vu_x, vu_y, vu_w, vu_h), Color(0.0, 0.0, 0.0, 0.65))
	draw_rect(Rect2(vu_x, vu_y, vu_w, vu_h), Color(C_GOLD, 0.15), false, 1.0)
	# Barlar
	var bar_count := 40
	var bar_w := (vu_w - 8.0) / float(bar_count) - 1.5
	for i in bar_count:
		var bx := vu_x + 4.0 + float(i) * (bar_w + 1.5)
		var vu_idx := int(float(i) / float(bar_count) * 8.0)
		var level := _vu_levels[clampi(vu_idx, 0, 7)]
		var jitter : float = abs(sin(t * 3.0 + float(i) * 0.8)) * 0.2
		var lv := clampf(level + jitter, 0.0, 1.0)
		var bh_full := vu_h - 8.0
		var bh := bh_full * lv
		var ratio := lv
		var col: Color
		if ratio > 0.80:
			col = Color(C_RED_LED, 0.90)
		elif ratio > 0.60:
			col = Color(C_AMBER, 0.88)
		else:
			col = Color(C_GREEN, 0.82)
		draw_rect(Rect2(bx, vu_y + 4.0 + bh_full - bh, bar_w, bh), col)

	# ── Frekans band bilgisi (sol alt köşe) ────────────────────────────────
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(vu_x + 8.0, vu_y - 8.0),
		"104.2 MHz  •  MITING FM  •  CANLI YAYIN",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(C_GOLD, 0.65))

	# ── Sağ alt sinyal çubukları ──────────────────────────────────────────
	var sig_x := s.x - 70.0
	for i in 5:
		var bh2 := 5.0 + float(i) * 3.5
		var bx2 := sig_x + float(i) * 11.0
		var filled := _signal > float(i) / 5.0
		draw_rect(Rect2(bx2, vu_y - bh2 - 6.0, 8.0, bh2),
			Color(C_GREEN, 0.88 if filled else 0.12))
