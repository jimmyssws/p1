class_name MenuBackdrop
extends Control

# Tam ekran retro FM radyo kasası arka planı.
# Procedural _draw() — sıfır asset.

var t := 0.0

const C_BODY    := Color(0.055, 0.060, 0.068)
const C_PANEL   := Color(0.040, 0.045, 0.055)
const C_CHROME  := Color(0.30, 0.32, 0.34)
const C_CHROME2 := Color(0.55, 0.58, 0.60)
const C_GOLD    := Color(0.88, 0.65, 0.22)
const C_AMBER   := Color(0.93, 0.52, 0.08)
const C_RED_LED := Color(0.92, 0.20, 0.18)
const C_GREEN   := Color(0.22, 0.82, 0.38)
const C_SPEAKER := Color(0.060, 0.065, 0.075)
const C_FABRIC  := Color(0.12, 0.10, 0.08)

var _vu_levels  : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var _vu_targets : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var _signal     := 0.0
var _scan       := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	call_deferred("queue_redraw")

func _process(delta: float) -> void:
	t += delta
	for i in 8:
		_vu_levels[i]  = lerp(_vu_levels[i], _vu_targets[i], delta * 7.0)
		if abs(_vu_levels[i] - _vu_targets[i]) < 0.02:
			_vu_targets[i] = randf()
	_signal = 0.60 + 0.40 * sin(t * 0.75) * (0.7 + 0.3 * sin(t * 2.1))
	_scan   = fmod(t * 0.16, 1.0)
	queue_redraw()

func _draw() -> void:
	var s := get_rect().size
	if s.x < 10.0 or s.y < 10.0:
		return

	# ── Arka plan degrade ────────────────────────────────────────────────────
	for i in 24:
		var r := float(i) / 23.0
		var c := Color(0.04, 0.045, 0.06).lerp(Color(0.02, 0.025, 0.035), r)
		draw_rect(Rect2(0.0, r * s.y, s.x, s.y / 23.0 + 2.0), c)

	# ── Ana gövde ────────────────────────────────────────────────────────────
	var px := s.x * 0.04
	var py := s.y * 0.05
	var bx := px
	var by := py
	var bw := s.x - px * 2.0
	var bh := s.y - py * 2.0
	_fill_rect(bx, by, bw, bh, C_BODY, 26.0)
	_stroke_rect(bx, by, bw, bh, C_CHROME, 26.0, 3.0)
	_stroke_rect(bx + 6.0, by + 6.0, bw - 12.0, bh - 12.0, Color(C_CHROME2, 0.30), 22.0, 1.0)

	# ── Sol hoparlör ─────────────────────────────────────────────────────────
	var sp_w := bw * 0.26
	_draw_speaker(bx + 18.0, by + 18.0, sp_w, bh - 36.0)

	# ── Sağ hoparlör ─────────────────────────────────────────────────────────
	_draw_speaker(bx + bw - sp_w - 18.0, by + 18.0, sp_w, bh - 36.0)

	# ── Merkez panel (radyo ekran çerçevesi) ──────────────────────────────────
	var cx  := bx + sp_w + 26.0
	var cw  := bw - sp_w * 2.0 - 52.0
	var cy  := by + 14.0
	var ch  := bh - 28.0
	_fill_rect(cx, cy, cw, ch, C_PANEL, 14.0)
	_stroke_rect(cx, cy, cw, ch, C_CHROME, 14.0, 2.0)

	# ── Frekans şeridi ────────────────────────────────────────────────────────
	var scale_h := ch * 0.13
	_draw_freq_scale(cx + 8.0, cy + 8.0, cw - 16.0, scale_h)

	# ── LED satırı ────────────────────────────────────────────────────────────
	var led_y := cy + 8.0 + scale_h + 5.0
	_draw_led_row(cx + 12.0, led_y, cw - 24.0)

	# ── VU-meter ──────────────────────────────────────────────────────────────
	var vu_h := ch * 0.09
	_draw_vu_meter(cx + 8.0, cy + ch - vu_h - 8.0, cw - 16.0, vu_h)

	# ── Alt model etiketi ────────────────────────────────────────────────────
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(cx, by + bh - 20.0),
		"MFM-104  •  MITING FM  •  v0.5",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.38, 0.42))

	# ── Vignette ─────────────────────────────────────────────────────────────
	for i in 6:
		var a := 0.022 + float(i) * 0.010
		draw_rect(Rect2(float(i) * 14.0, float(i) * 12.0,
			s.x - float(i) * 28.0, s.y - float(i) * 24.0),
			Color(0.0, 0.0, 0.0, a), false, 14.0)

# ─── Hoparlör ──────────────────────────────────────────────────────────────

func _draw_speaker(x: float, y: float, w: float, h: float) -> void:
	_fill_rect(x, y, w, h, C_SPEAKER, 10.0)
	_stroke_rect(x, y, w, h, C_CHROME, 10.0, 2.0)
	var ix := x + 8.0
	var iy := y + 8.0
	var iw := w - 16.0
	var ih := h - 16.0
	_fill_rect(ix, iy, iw, ih, C_FABRIC, 7.0)
	var row_count := int(ih / 6.0)
	for row in row_count:
		var ry := iy + float(row) * 6.0 + 3.0
		if ry > iy + ih - 4.0:
			break
		draw_line(Vector2(ix + 6.0, ry), Vector2(ix + iw - 6.0, ry),
			Color(0.10, 0.09, 0.07), 1.0)
	var cx_ := x + w * 0.5
	var cy_ := y + h * 0.5
	draw_circle(Vector2(cx_, cy_), w * 0.28, Color(0.07, 0.065, 0.075))
	draw_circle(Vector2(cx_, cy_), w * 0.22, Color(0.09, 0.085, 0.095))
	draw_circle(Vector2(cx_, cy_), w * 0.09, Color(0.11, 0.10, 0.12))
	draw_circle(Vector2(cx_, cy_), w * 0.030, Color(C_CHROME, 0.5))
	# Vidalar
	var corners_x := [x + 10.0, x + w - 10.0, x + w - 10.0, x + 10.0]
	var corners_y := [y + 10.0, y + 10.0,      y + h - 10.0, y + h - 10.0]
	for i in 4:
		draw_circle(Vector2(corners_x[i], corners_y[i]), 4.0, C_CHROME)
		draw_circle(Vector2(corners_x[i], corners_y[i]), 1.5, C_PANEL)

# ─── Frekans şeridi ────────────────────────────────────────────────────────

func _draw_freq_scale(x: float, y: float, w: float, h: float) -> void:
	_fill_rect(x, y, w, h, Color(0.08, 0.06, 0.03), 5.0)
	_stroke_rect(x, y, w, h, C_GOLD, 5.0, 1.5)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(x + 8.0, y + h * 0.55),
		"MITING FM", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(C_GOLD, 0.65))
	draw_string(font, Vector2(x + w - 8.0, y + h * 0.55),
		"STEREO", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(C_AMBER, 0.75))
	var lx   := x + 14.0
	var lw   := w - 28.0
	for tick in 41:
		var freq := 88.0 + float(tick) * 0.5
		var tx   := lx + lw * (freq - 88.0) / 20.0
		var major := (tick % 2) == 0
		var th    := h * (0.50 if major else 0.28)
		var col   := Color(C_GOLD, 0.75 if major else 0.30)
		draw_line(Vector2(tx, y + 4.0), Vector2(tx, y + 4.0 + th), col, 1.0)
		if major and (int(freq) % 4 == 0):
			draw_string(font, Vector2(tx - 9.0, y + h - 2.0),
				str(int(freq)), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(C_GOLD, 0.60))
	# Hareketli iğne
	var needle_freq := 104.2 + 1.8 * sin(t * 0.28)
	var nx := lx + lw * clampf((needle_freq - 88.0) / 20.0, 0.0, 1.0)
	draw_line(Vector2(nx, y + 2.0), Vector2(nx, y + h - 2.0),
		Color(C_AMBER, 0.88 + 0.12 * sin(t * 4.0)), 2.0)
	draw_circle(Vector2(nx, y + 5.0), 4.5, C_AMBER)
	# Tarama efekti
	var sx2 := lx + lw * _scan
	draw_line(Vector2(sx2, y + 2.0), Vector2(sx2, y + h - 2.0),
		Color(1.0, 1.0, 1.0, 0.05 + 0.03 * sin(t * 5.0)), 1.0)

# ─── LED satırı ────────────────────────────────────────────────────────────

func _draw_led_row(x: float, y: float, _w: float) -> void:
	# Power LED
	draw_circle(Vector2(x + 6.0, y + 7.0), 5.0,
		Color(C_RED_LED, 0.82 + 0.18 * sin(t * 3.0)))
	draw_circle(Vector2(x + 6.0, y + 7.0), 2.5, Color(1.0, 0.55, 0.55, 0.85))
	var font := ThemeDB.fallback_font
	var labels := ["STEREO", "104.2 MHz", "CANLI"]
	var on_arr := [true, true, true]
	var lx := x + 22.0
	for i in 3:
		var on: bool = on_arr[i]
		var col := Color(C_AMBER, 0.88 if on else 0.14)
		draw_rect(Rect2(lx, y + 4.0, 6.0, 6.0), col)
		draw_string(font, Vector2(lx + 9.0, y + 13.0),
			labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
			Color(col, 0.80 if on else 0.20))
		lx += 80.0
	# REC yanıp sönen
	var rec_on := fmod(t, 1.4) > 0.7
	var rec_col := Color(C_RED_LED, 0.88 if rec_on else 0.12)
	draw_rect(Rect2(lx, y + 4.0, 6.0, 6.0), rec_col)
	draw_string(font, Vector2(lx + 9.0, y + 13.0),
		"REC", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(rec_col, 0.80 if rec_on else 0.15))
	# Sinyal çubukları (sağ taraf)
	var sig_x := x + _w
	for i in 5:
		var bh2 := 4.0 + float(i) * 2.5
		var bx2  := sig_x - float(5 - i) * 9.0
		var filled := _signal > float(i) / 4.5
		var sc := Color(C_GREEN, 0.88 if filled else 0.13)
		draw_rect(Rect2(bx2, y + 14.0 - bh2, 6.0, bh2), sc)

# ─── VU-meter ──────────────────────────────────────────────────────────────

func _draw_vu_meter(x: float, y: float, w: float, h: float) -> void:
	_fill_rect(x, y, w, h, Color(0.04, 0.04, 0.05), 4.0)
	var bar_w := (w - 10.0) / 8.0 - 2.0
	for i in 8:
		var bx2 := x + 5.0 + float(i) * (bar_w + 2.0)
		var level := _vu_levels[i]
		var segs := 12
		for seg in segs:
			var ratio := float(seg) / float(segs - 1)
			var sy2   := y + h - 4.0 - ratio * (h - 8.0)
			var active := level > ratio
			var col: Color
			if ratio > 0.84:
				col = Color(C_RED_LED, 0.88 if active else 0.07)
			elif ratio > 0.64:
				col = Color(C_GOLD, 0.88 if active else 0.07)
			else:
				col = Color(C_GREEN, 0.82 if active else 0.07)
			draw_rect(Rect2(bx2, sy2, bar_w, h / float(segs) * 0.68), col)

# ─── Köşeli dikdörtgen yardımcıları ────────────────────────────────────────
# GDScript 4 mixed-type array'dan kaçınmak için sadece float alır.

func _fill_rect(x: float, y: float, w: float, h: float, color: Color, radius: float) -> void:
	var r := minf(radius, minf(w, h) * 0.5)
	# Orta yatay şerit
	draw_rect(Rect2(x, y + r, w, h - r * 2.0), color)
	# Üst + alt yatay şerit (kenar boşluğu hariç)
	draw_rect(Rect2(x + r, y, w - r * 2.0, r), color)
	draw_rect(Rect2(x + r, y + h - r, w - r * 2.0, r), color)
	# Dört köşe çeyrek daire
	_quarter(x + r,       y + r,       r, PI,        color)
	_quarter(x + w - r,   y + r,       r, PI * 1.5,  color)
	_quarter(x + w - r,   y + h - r,   r, 0.0,       color)
	_quarter(x + r,       y + h - r,   r, PI * 0.5,  color)

func _stroke_rect(x: float, y: float, w: float, h: float, color: Color, radius: float, lw: float) -> void:
	var r := minf(radius, minf(w, h) * 0.5)
	draw_line(Vector2(x + r, y),         Vector2(x + w - r, y),         color, lw)
	draw_line(Vector2(x + w, y + r),     Vector2(x + w, y + h - r),     color, lw)
	draw_line(Vector2(x + r, y + h),     Vector2(x + w - r, y + h),     color, lw)
	draw_line(Vector2(x, y + r),         Vector2(x, y + h - r),         color, lw)

func _quarter(cx: float, cy: float, r: float, start_angle: float, color: Color) -> void:
	var steps := 8
	var pts   := PackedVector2Array()
	pts.append(Vector2(cx, cy))
	for i in steps + 1:
		var a := start_angle + PI * 0.5 * float(i) / float(steps)
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	draw_colored_polygon(pts, color)
