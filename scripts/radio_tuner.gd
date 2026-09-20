class_name RadioTuner
extends Control

# Tam ekran FM radyo menüsünün üst frekans göstergesi.
# Bu düğüm menü arka planının üstünde, buton panelinin ise üstünde konumlandırılır.
# Skalanın yanı sıra "şu an çalan kanal" bilgisini canlı gösterir.

const GOLD  := Color("e5a93c")
const AMBER := Color("e8850f")
const INK   := Color(0.03, 0.035, 0.045)
const TEXT  := Color("e7e9e6")
const MUTED := Color("8a9298")

var phase    := 0.0
var station  := 104.2
var title    := "MEYDAN ANA YAYINI"
var subtitle := "CANLI YAYIN"

var _box : StyleBoxFlat = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_top    = 0.0
	offset_bottom = 90.0
	_box = StyleBoxFlat.new()
	_box.bg_color = Color(0.04, 0.05, 0.06, 0.96)
	_box.border_width_bottom = 2
	_box.border_color = Color(0.88, 0.65, 0.22, 0.50)
	_box.shadow_color = Color(0.0, 0.0, 0.0, 0.70)
	_box.shadow_size  = 12

func tune(value: float, label: String, sub: String = "SECILDI") -> void:
	station  = value
	title    = label
	subtitle = sub
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x < 40.0: return
	if _box == null: return

	draw_style_box(_box, Rect2(Vector2.ZERO, s))

	var font := ThemeDB.fallback_font

	# ── Sol: Kanal frekansı ──────────────────────────────────────────────
	draw_string(font, Vector2(22, 26), "%.1f" % station,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 38, GOLD)
	draw_string(font, Vector2(22, 46), "MHz",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(GOLD, 0.55))

	# ── Orta: Kanal adı ve altyazı ──────────────────────────────────────
	var mid_x := s.x * 0.5
	draw_string(font, Vector2(mid_x, 30), title,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 18, TEXT)
	draw_string(font, Vector2(mid_x, 52), subtitle,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(AMBER, 0.80))

	# ── Sağ: Sinyal göstergesi ──────────────────────────────────────────
	var sig := 0.72 + 0.28 * sin(phase * 0.8)
	for i in 5:
		var bh := 8.0 + i * 4.5
		var bx := s.x - 28.0 - (4 - i) * 11.0
		var by := 40.0 - bh
		var col := Color(GOLD, 0.9) if sig > float(i) / 4.5 else Color(GOLD, 0.14)
		draw_rect(Rect2(bx, by, 8.0, bh), col)

	# ── Frekans skala şeridi ─────────────────────────────────────────────
	var sy    := 65.0
	var lx    := 22.0
	var rw    := s.x - 110.0
	draw_line(Vector2(lx, sy), Vector2(lx + rw, sy), Color(MUTED, 0.4), 1.5)
	for i in 41:
		var freq := 88.0 + float(i) * 0.5
		var x := lx + rw * (freq - 88.0) / 20.0
		var major := (int(freq * 2.0) % 2) == 0
		var h := 10.0 if major else 5.0
		draw_line(Vector2(x, sy - h), Vector2(x, sy + h), Color(MUTED, 0.6 if major else 0.25), 1.0)
		if major and int(freq) % 4 == 0:
			draw_string(font, Vector2(x - 8.0, sy + 20.0), str(int(freq)),
						HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(MUTED, 0.5))

	# Hareketli iğne
	var kx := lx + rw * clampf((station - 88.0) / 20.0, 0.0, 1.0)
	draw_circle(Vector2(kx, sy), 9.0 + 1.5 * sin(phase * 3.5), Color(GOLD, 0.90))
	draw_circle(Vector2(kx, sy), 4.0, INK)

	# LIVE yazı
	if fmod(phase, 1.6) < 0.9:
		draw_string(font, Vector2(s.x - 28.0, sy + 6.0), "LIVE",
					HORIZONTAL_ALIGNMENT_RIGHT, -1, 11, Color(Color("ca3432"), 0.9))
