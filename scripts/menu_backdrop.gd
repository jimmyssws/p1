class_name MenuBackdrop
extends Control

# Tam ekran retro FM radyo kasası arka planı.
# Radyonun fiziksel gövdesi, ızgara hoparlör, LED göstergeleri ve
# animasyonlu VU-meter çizilir. Hiçbir varlık (asset) gerektirmez.

var t := 0.0
var vu_levels := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var vu_targets := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var signal_strength := 0.0
var scan_bar := 0.0

# Renk paleti — koyu plastik / bakalit radyo estetiği
const C_BODY    := Color(0.055, 0.060, 0.068)      # koyu antrasit gövde
const C_PANEL   := Color(0.040, 0.045, 0.055)      # biraz daha koyu iç panel
const C_CHROME  := Color(0.30, 0.32, 0.34)         # krom kenar çıtaları
const C_CHROME2 := Color(0.55, 0.58, 0.60)         # parlak krom vurgu
const C_GOLD    := Color(0.88, 0.65, 0.22)         # altın sarısı skala
const C_AMBER   := Color(0.93, 0.52, 0.08)         # kehribar LED
const C_RED_LED := Color(0.92, 0.20, 0.18)         # kırmızı "LIVE" LED
const C_GREEN   := Color(0.22, 0.82, 0.38)         # yeşil sinyal LED'i
const C_SPEAKER := Color(0.060, 0.065, 0.075)      # hoparlör ızgarası
const C_FABRIC  := Color(0.12, 0.10, 0.08)         # hoparlör kumaşı

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	call_deferred("queue_redraw")
	_randomize_vu()

func _process(delta: float) -> void:
	t += delta
	# VU-meter animasyonu
	for i in 8:
		vu_levels[i] = lerp(vu_levels[i], vu_targets[i], delta * 8.0)
		if abs(vu_levels[i] - vu_targets[i]) < 0.01:
			vu_targets[i] = randf()
	# Sinyal gücü dalgalanması
	signal_strength = 0.65 + 0.35 * sin(t * 0.7) * (0.7 + 0.3 * sin(t * 2.3))
	# Tarama çubuğu (döngüsel)
	scan_bar = fmod(t * 0.18, 1.0)
	queue_redraw()

func _randomize_vu() -> void:
	for i in 8:
		vu_targets[i] = randf()

func _draw() -> void:
	var s := get_rect().size
	if s.x < 10.0 or s.y < 10.0:
		return

	# ── 1. ARKA PLAN — Degrade gece rengi ────────────────────────────────────
	for i in 24:
		var r := float(i) / 23.0
		var c := Color(0.04, 0.045, 0.06).lerp(Color(0.02, 0.025, 0.035), r)
		draw_rect(Rect2(0, r * s.y, s.x, s.y / 23.0 + 2.0), c)

	# ── 2. RADYO KASASI — Ana gövde ──────────────────────────────────────────
	var pad_x := s.x * 0.04
	var pad_y := s.y * 0.05
	var body_rect := Rect2(pad_x, pad_y, s.x - pad_x * 2.0, s.y - pad_y * 2.0)
	_draw_rounded_rect(body_rect, C_BODY, 28.0)

	# Krom çerçeve — dış kenar
	_draw_rounded_rect_border(body_rect, C_CHROME, 28.0, 3.0)

	# Parlak iç krom çizgisi
	var inner := body_rect.grow(-6.0)
	_draw_rounded_rect_border(inner, Color(C_CHROME2, 0.35), 24.0, 1.0)

	# ── 3. HOPARLÖR IZGARASI — Sol blok ─────────────────────────────────────
	var sp_w := body_rect.size.x * 0.28
	var sp_rect := Rect2(body_rect.position.x + 18.0, body_rect.position.y + 18.0,
						 sp_w, body_rect.size.y - 36.0)
	_draw_speaker(sp_rect)

	# ── 4. SAĞ HOPARLÖR IZGARASI ─────────────────────────────────────────────
	var sp2_rect := Rect2(body_rect.end.x - sp_w - 18.0, body_rect.position.y + 18.0,
						  sp_w, body_rect.size.y - 36.0)
	_draw_speaker(sp2_rect)

	# ── 5. MERKEZ PANEL — Menünün oturduğu LCD ekran çerçevesi ───────────────
	var cx := body_rect.position.x + sp_w + 28.0
	var cw := body_rect.size.x - sp_w * 2.0 - 56.0
	var center_panel := Rect2(cx, body_rect.position.y + 14.0, cw, body_rect.size.y - 28.0)
	_draw_rounded_rect(center_panel, C_PANEL, 16.0)
	_draw_rounded_rect_border(center_panel, C_CHROME, 16.0, 2.0)

	# ── 6. FREKANS SKALA ŞERIDI — Merkez panelin üstü ───────────────────────
	var scale_h := center_panel.size.y * 0.14
	var scale_rect := Rect2(center_panel.position.x + 8.0, center_panel.position.y + 8.0,
							center_panel.size.x - 16.0, scale_h)
	_draw_frequency_scale(scale_rect)

	# ── 7. VU-METER — Altta ──────────────────────────────────────────────────
	var vu_h := center_panel.size.y * 0.10
	var vu_rect := Rect2(center_panel.position.x + 8.0,
						 center_panel.end.y - vu_h - 8.0,
						 center_panel.size.x - 16.0, vu_h)
	_draw_vu_meter(vu_rect)

	# ── 8. LED GÖSTERGE SATIRI — Skalanın hemen altı ─────────────────────────
	var led_y := scale_rect.end.y + 6.0
	_draw_led_row(center_panel.position.x + 12.0, led_y, center_panel.size.x - 24.0)

	# ── 9. MARKA ve FREKANS metni (skalanın üstünde) ─────────────────────────
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(center_panel.position.x + 14.0, scale_rect.position.y + 13.0),
				"MITING FM", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(C_GOLD, 0.70))
	draw_string(font, Vector2(center_panel.end.x - 14.0, scale_rect.position.y + 13.0),
				"STEREO", HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(C_AMBER, 0.80))

	# ── 10. POWER LED ─────────────────────────────────────────────────────────
	var pw := Vector2(center_panel.position.x + 16.0, led_y + 7.0)
	draw_circle(pw, 5.0, Color(C_RED_LED, 0.85 + 0.15 * sin(t * 3.0)))
	draw_circle(pw, 2.5, Color(1, 0.6, 0.6, 0.9))

	# ── 11. SİNYAL KUVVETİ ÇUBUKLARI ─────────────────────────────────────────
	var sig_x := center_panel.end.x - 12.0
	for i in 5:
		var h := 4.0 + i * 2.5
		var bar_x := sig_x - (5 - i) * 9.0
		var filled := signal_strength > float(i) / 4.5
		var col := C_GREEN if filled else Color(C_GREEN, 0.15)
		draw_rect(Rect2(bar_x, led_y + 14.0 - h, 6.0, h), col)

	# ── 12. Alt model etiketi ─────────────────────────────────────────────────
	draw_string(font, Vector2(body_rect.position.x + sp_w + 36.0, body_rect.end.y - 20.0),
				"MODEL MFM-104  //  v0.5  ERKEN ERISIM", HORIZONTAL_ALIGNMENT_LEFT,
				-1, 10, Color(0.35, 0.38, 0.42))

	# ── 13. Hafif vignette ───────────────────────────────────────────────────
	for i in 6:
		draw_rect(Rect2(i * 14, i * 12, s.x - i * 28, s.y - i * 24),
				  Color(0, 0, 0, 0.022 + float(i) * 0.010), false, 14.0)

# ─── Yardımcı çizim fonksiyonları ────────────────────────────────────────────

func _draw_rounded_rect(rect: Rect2, color: Color, radius: float) -> void:
	# Köşe yarıçaplı dolu dikdörtgen — Godot'un draw_rect antialiased değil,
	# bu yüzden köşeleri ayrı poligonlarla kaplarız.
	draw_rect(rect.grow(-radius), color)
	draw_rect(Rect2(rect.position.x, rect.position.y + radius, rect.size.x, rect.size.y - radius * 2.0), color)
	for corner in [[rect.position + Vector2(radius, radius), -1, -1],
				   [Vector2(rect.end.x - radius, rect.position.y + radius), 1, -1],
				   [rect.end - Vector2(radius, radius), 1, 1],
				   [Vector2(rect.position.x + radius, rect.end.y - radius), -1, 1]]:
		_draw_quarter_circle(corner[0], radius, corner[1], corner[2], color)

func _draw_rounded_rect_border(rect: Rect2, color: Color, radius: float, width: float) -> void:
	draw_line(rect.position + Vector2(radius, 0), Vector2(rect.end.x - radius, rect.position.y), color, width)
	draw_line(Vector2(rect.end.x, rect.position.y + radius), Vector2(rect.end.x, rect.end.y - radius), color, width)
	draw_line(Vector2(rect.position.x, rect.end.y - radius), Vector2(rect.end.x - radius, rect.end.y), color, width)
	draw_line(rect.position + Vector2(0, radius), Vector2(rect.position.x, rect.end.y - radius), color, width)

func _draw_quarter_circle(center: Vector2, radius: float, sx: float, sy: float, color: Color) -> void:
	var steps := 10
	var pts := PackedVector2Array()
	pts.append(center)
	for i in steps + 1:
		var angle := PI * 0.5 * float(i) / float(steps)
		pts.append(center + Vector2(sx * cos(angle), sy * sin(angle)) * radius)
	draw_colored_polygon(pts, color)

func _draw_speaker(rect: Rect2) -> void:
	# Hoparlör ızgara çerçevesi
	_draw_rounded_rect(rect, C_SPEAKER, 12.0)
	_draw_rounded_rect_border(rect, C_CHROME, 12.0, 2.0)
	# Kumaş dokusu — yatay çizgiler
	var fabric_inner := rect.grow(-8.0)
	_draw_rounded_rect(fabric_inner, C_FABRIC, 8.0)
	for row in int(fabric_inner.size.y / 6.0):
		var y := fabric_inner.position.y + row * 6.0 + 3.0
		if y > fabric_inner.end.y - 4.0:
			break
		draw_line(Vector2(fabric_inner.position.x + 6.0, y),
				  Vector2(fabric_inner.end.x - 6.0, y),
				  Color(0.10, 0.09, 0.07), 1.0)
	# Hoparlör konisi daire göstergesi
	var cx := rect.get_center()
	draw_circle(cx, rect.size.x * 0.30, Color(0.07, 0.065, 0.075))
	draw_circle(cx, rect.size.x * 0.25, Color(0.09, 0.085, 0.095))
	draw_circle(cx, rect.size.x * 0.10, Color(0.11, 0.10, 0.12))
	draw_circle(cx, rect.size.x * 0.035, Color(C_CHROME, 0.5))
	# Çerçeve tutturma vidaları
	for corner in [rect.position + Vector2(10, 10), Vector2(rect.end.x - 10, rect.position.y + 10),
				   rect.end - Vector2(10, 10), Vector2(rect.position.x + 10, rect.end.y - 10)]:
		draw_circle(corner, 4.0, C_CHROME)
		draw_circle(corner, 1.5, Color(C_PANEL, 1.0))

func _draw_frequency_scale(rect: Rect2) -> void:
	# Altın sarısı frekans şeridi arka planı
	var bg_color := Color(0.08, 0.06, 0.03)
	_draw_rounded_rect(rect, bg_color, 6.0)
	_draw_rounded_rect_border(rect, C_GOLD, 6.0, 1.5)
	# Frekans çizgileri (88–108 MHz, her 2 MHz'de bir büyük çizgi)
	var freq_min := 88.0
	var freq_max := 108.0
	var inner_x := rect.position.x + 12.0
	var inner_w := rect.size.x - 24.0
	for tick in 41: # her 0.5 MHz
		var freq := freq_min + float(tick) * 0.5
		var x := inner_x + inner_w * (freq - freq_min) / (freq_max - freq_min)
		var is_major := int(freq) == freq
		var is_label := is_major and int(freq) % 4 == 0
		var h := rect.size.y * (0.55 if is_major else 0.30)
		var col := Color(C_GOLD, 0.8 if is_major else 0.35)
		draw_line(Vector2(x, rect.position.y + 4.0), Vector2(x, rect.position.y + 4.0 + h), col, 1.0)
		if is_label:
			draw_string(ThemeDB.fallback_font,
						Vector2(x - 10.0, rect.end.y - 3.0),
						str(int(freq)), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(C_GOLD, 0.7))
	# Hareketli iğne (tuner knob) — parlayan animasyonlu
	var needle_freq := 88.0 + (104.2 - 88.0) + 2.0 * sin(t * 0.3)
	var needle_x := inner_x + inner_w * clampf((needle_freq - freq_min) / (freq_max - freq_min), 0.0, 1.0)
	draw_line(Vector2(needle_x, rect.position.y + 2.0),
			  Vector2(needle_x, rect.end.y - 2.0),
			  Color(C_AMBER, 0.9 + 0.1 * sin(t * 4.0)), 2.0)
	draw_circle(Vector2(needle_x, rect.position.y + 5.0), 4.5, C_AMBER)
	# Tarama animasyonu
	var sx := inner_x + inner_w * scan_bar
	draw_line(Vector2(sx, rect.position.y + 2.0), Vector2(sx, rect.end.y - 2.0),
			  Color(1, 1, 1, 0.06 + 0.04 * sin(t * 5.0)), 1.0)

func _draw_vu_meter(rect: Rect2) -> void:
	var bg := Color(0.04, 0.04, 0.05)
	_draw_rounded_rect(rect, bg, 4.0)
	var bar_w := (rect.size.x - 10.0) / 8.0 - 2.0
	for i in 8:
		var bx := rect.position.x + 5.0 + i * (bar_w + 2.0)
		var level := vu_levels[i]
		var segments := 12
		for seg in segments:
			var ratio := float(seg) / float(segments - 1)
			var sy := rect.end.y - 4.0 - ratio * (rect.size.y - 8.0)
			var active := level > ratio
			var col: Color
			if ratio > 0.85:
				col = Color(C_RED_LED, 0.9 if active else 0.08)
			elif ratio > 0.65:
				col = Color(C_GOLD, 0.9 if active else 0.08)
			else:
				col = Color(C_GREEN, 0.85 if active else 0.08)
			draw_rect(Rect2(bx, sy, bar_w, rect.size.y / float(segments) * 0.7), col)

func _draw_led_row(x: float, y: float, width: float) -> void:
	# "STEREO / MONO / REC" göstergesi
	var labels := [["STEREO", true], ["104.2 MHz", true], ["CANLI", true], ["REC", fmod(t, 1.4) > 0.7]]
	var lx := x + 28.0
	for lbl in labels:
		var on: bool = lbl[1]
		var col := Color(C_AMBER, 0.9 if on else 0.15)
		draw_rect(Rect2(lx, y + 4.0, 6.0, 6.0), col)
		draw_string(ThemeDB.fallback_font, Vector2(lx + 10.0, y + 13.0),
					lbl[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(col, on ? 0.85 : 0.25))
		lx += 85.0
