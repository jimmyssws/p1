class_name MenuVisuals
extends RefCounted

# Sinematik karanlık thriller stili menü görsel katmanı.
# Tüm node yolları ve sinyaller menu.gd'de değişmez.

const RadioTunerGd = preload("res://scripts/radio_tuner.gd")
const Backdrop     = preload("res://scripts/menu_backdrop.gd")

const TEXT   := Color("e7e9e6")
const MUTED  := Color("7a858c")
const GOLD   := Color("e5a93c")
const AMBER  := Color("e8850f")
const RED    := Color("ca3432")
const INK    := Color(0.02, 0.025, 0.032)

# [frekans, başlık, altyazı, kırmızı_mı]
const CHANNELS : Dictionary = {
	"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": [104.2, "MEYDAN YAYINI", "CANLI • ANA SUNUCU"],
	"CenterBox/MainPanel/VBox/Buttons/SoloButton":        [ 96.3, "TATBIKAT",      "TEK OYUNCU • KAYIT"],
	"CenterBox/MainPanel/VBox/Buttons/HostButton":        [ 92.7, "MITING ODASI",  "COK OYUNCU • HOST"],
	"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton":  [ 88.4, "GUVENLI HAT",   "IP ILE BAGLAN"],
}
const DANGER_PATHS : Array = [
	"CenterBox/MainPanel/VBox/Buttons/QuitButton",
]
const OTHER_PATHS : Array = [
	"CenterBox/MainPanel/VBox/Buttons/SettingsButton",
	"CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton",
]

static func apply(menu: Control) -> void:
	_setup_bg(menu)
	_setup_layout(menu)
	_setup_tuner(menu)
	_setup_copy(menu)
	_setup_buttons(menu)
	_setup_settings(menu)
	_play_intro(menu)

# ── Arka plan ────────────────────────────────────────────────────────────────

static func _setup_bg(menu: Control) -> void:
	var bg := menu.get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.0, 0.0, 0.0, 1.0)
	var bd := menu.get_node_or_null("RallyNightBackdrop")
	if bd == null:
		bd = Backdrop.new()
		bd.name = "RallyNightBackdrop"
		menu.add_child(bd)
		menu.move_child(bd, 1)

# ── Layout ───────────────────────────────────────────────────────────────────

static func _setup_layout(menu: Control) -> void:
	var center := menu.get_node_or_null("CenterBox") as CenterContainer
	if center:
		center.anchor_left   = 0.30
		center.anchor_top    = 0.06
		center.anchor_right  = 0.72
		center.anchor_bottom = 0.92
		center.offset_left   = 0.0
		center.offset_top    = 0.0
		center.offset_right  = 0.0
		center.offset_bottom = 0.0

	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel:
		panel.custom_minimum_size = Vector2(0.0, 0.0)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", _panel_box())

	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 5)

# ── RadioTuner (üst frekans şeridi) ─────────────────────────────────────────

static func _setup_tuner(menu: Control) -> void:
	var tuner := menu.get_node_or_null("MitingFMTuner")
	if tuner == null:
		tuner = RadioTunerGd.new()
		tuner.name = "MitingFMTuner"
		menu.add_child(tuner)
	tuner.anchor_left   = 0.30
	tuner.anchor_top    = 0.06
	tuner.anchor_right  = 0.72
	tuner.anchor_bottom = 0.06
	tuner.offset_top    = 0.0
	tuner.offset_bottom = 82.0
	tuner.offset_left   = 0.0
	tuner.offset_right  = 0.0

# ── Başlık metinleri ─────────────────────────────────────────────────────────

static func _setup_copy(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUIKASTCI\nVE BASKAN"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title.add_theme_font_size_override("font_size", 32)
		title.add_theme_color_override("font_color", TEXT)
		title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		title.add_theme_constant_override("outline_size", 3)

	var sub := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if sub:
		sub.text = "GIZLI ROLLER  //  ACIK HESAPLASMA"
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		sub.add_theme_font_size_override("font_size", 11)
		sub.add_theme_color_override("font_color", Color(GOLD, 0.72))

	var ver := menu.get_node_or_null("VersionLabel") as Label
	if ver:
		ver.text = "ERKEN ERISIM  //  v0.5"
		ver.add_theme_color_override("font_color", Color(MUTED, 0.7))

# ── Butonlar ─────────────────────────────────────────────────────────────────

static func _setup_buttons(menu: Control) -> void:
	var tuner := menu.get_node_or_null("MitingFMTuner") as RadioTuner

	# Kanal butonları
	for path in CHANNELS:
		var btn := menu.get_node_or_null(path) as Button
		if btn == null:
			continue
		var ch : Array = CHANNELS[path]
		_style_btn(btn, GOLD)
		if tuner:
			var freq : float  = ch[0]
			var lbl  : String = ch[1]
			var sub2 : String = ch[2]
			btn.mouse_entered.connect(func(): tuner.tune(freq, lbl, sub2))
		btn.mouse_entered.connect(func(): _slide_in(btn))
		btn.mouse_exited.connect(func():  _slide_out(btn))

	# Tehlike butonu (çıkış)
	for path in DANGER_PATHS:
		var btn := menu.get_node_or_null(path) as Button
		if btn:
			_style_btn(btn, RED)
			btn.mouse_entered.connect(func(): _slide_in(btn))
			btn.mouse_exited.connect(func():  _slide_out(btn))

	# Diğer butonlar (ayarlar, bağlan)
	for path in OTHER_PATHS:
		var btn := menu.get_node_or_null(path) as Button
		if btn:
			_style_btn(btn, Color(MUTED, 1.0))

	# Metinler
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/ServerQuickButton",
		"⚡  MEYDAN YAYINI\n    104.2 MHz  •  Ana Sunucu: 100.68.81.79")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/SoloButton",
		"▶  TATBIKAT MODU\n    96.3 MHz  •  Tek Oyuncu / Hizli Basla")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/HostButton",
		"◈  MITING ODASI  —  ODA KUR\n    92.7 MHz  •  Port 9999")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/JoinToggleButton",
		"→  GUVENLI HAT  —  IP ILE BAGLAN\n    88.4 MHz")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton",
		"  BAGLAN")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/SettingsButton",
		"⚙  PROTOKOL AYARLARI")
	_set_text(menu, "CenterBox/MainPanel/VBox/Buttons/QuitButton",
		"×  OTURUMU KAPAT")

	# IP input
	var ip := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if ip:
		ip.add_theme_color_override("font_color", TEXT)
		ip.add_theme_color_override("font_placeholder_color", Color(MUTED, 0.5))
		ip.add_theme_stylebox_override("normal", _ip_box())

# ── Ayarlar paneli ───────────────────────────────────────────────────────────

static func _setup_settings(menu: Control) -> void:
	var panel := menu.get_node_or_null("SettingsPanel") as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _settings_box())
	for lp in ["SettingsPanel/VBox/SettingsTitle", "SettingsPanel/VBox/VolTitle",
			   "SettingsPanel/VBox/SensTitle", "SettingsPanel/VBox/WeatherTitle"]:
		var lbl := menu.get_node_or_null(lp) as Label
		if lbl:
			lbl.add_theme_color_override("font_color", TEXT)
	var cb := menu.get_node_or_null("SettingsPanel/VBox/CloseButton") as Button
	if cb:
		_style_btn(cb, GOLD)
		cb.text = "← KAYDET & KAPAT"

# ── Intro ─────────────────────────────────────────────────────────────────────

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		var tw := menu.create_tween()
		tw.tween_property(panel, "modulate:a", 1.0, 0.60)

# ── StyleBox fabrikaları ─────────────────────────────────────────────────────

static func _panel_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.04, 0.045, 0.055, 0.88)
	b.border_width_left   = 3
	b.border_width_top    = 1
	b.border_width_right  = 1
	b.border_width_bottom = 1
	b.border_color = Color(GOLD, 0.55)
	b.corner_radius_top_left     = 4
	b.corner_radius_top_right    = 4
	b.corner_radius_bottom_left  = 4
	b.corner_radius_bottom_right = 4
	b.shadow_color = Color(0.0, 0.0, 0.0, 0.90)
	b.shadow_size  = 32
	b.shadow_offset = Vector2(0.0, 8.0)
	b.content_margin_left   = 22.0
	b.content_margin_top    = 88.0   # RadioTuner için boşluk
	b.content_margin_right  = 18.0
	b.content_margin_bottom = 14.0
	return b

static func _btn_normal(accent: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.05, 0.055, 0.065, 0.82)
	b.border_width_left   = 3
	b.border_width_top    = 0
	b.border_width_right  = 0
	b.border_width_bottom = 1
	b.border_color = Color(accent, 0.55)
	b.corner_radius_top_left     = 2
	b.corner_radius_top_right    = 2
	b.corner_radius_bottom_left  = 2
	b.corner_radius_bottom_right = 2
	b.content_margin_left   = 16.0
	b.content_margin_top    = 7.0
	b.content_margin_right  = 10.0
	b.content_margin_bottom = 7.0
	return b

static func _btn_hover(accent: Color) -> StyleBoxFlat:
	var b := _btn_normal(accent)
	b.bg_color = Color(accent.r, accent.g, accent.b, 0.16)
	b.border_color = Color(accent, 0.90)
	b.border_width_left = 4
	b.shadow_color = Color(accent, 0.25)
	b.shadow_size  = 8
	return b

static func _btn_pressed(accent: Color) -> StyleBoxFlat:
	var b := _btn_normal(accent)
	b.bg_color = Color(accent.r, accent.g, accent.b, 0.28)
	b.border_color = TEXT
	b.border_width_left = 5
	return b

static func _ip_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.05, 0.055, 0.07)
	b.border_width_left   = 2
	b.border_width_top    = 1
	b.border_width_right  = 1
	b.border_width_bottom = 1
	b.border_color = Color(GOLD, 0.40)
	b.corner_radius_top_left     = 3
	b.corner_radius_top_right    = 3
	b.corner_radius_bottom_left  = 3
	b.corner_radius_bottom_right = 3
	b.content_margin_left = 10.0
	b.content_margin_right = 8.0
	return b

static func _settings_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.04, 0.045, 0.055, 0.97)
	b.border_width_left   = 3
	b.border_width_top    = 1
	b.border_width_right  = 1
	b.border_width_bottom = 1
	b.border_color = Color(GOLD, 0.45)
	b.corner_radius_top_left     = 6
	b.corner_radius_top_right    = 6
	b.corner_radius_bottom_left  = 6
	b.corner_radius_bottom_right = 6
	b.shadow_color = Color(0.0, 0.0, 0.0, 0.85)
	b.shadow_size  = 28
	b.content_margin_left   = 26.0
	b.content_margin_top    = 26.0
	b.content_margin_right  = 26.0
	b.content_margin_bottom = 26.0
	return b

# ── Buton stili uygula ───────────────────────────────────────────────────────

static func _style_btn(btn: Button, accent: Color) -> void:
	btn.custom_minimum_size.y = 58.0
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", TEXT)
	btn.add_theme_color_override("font_hover_color", accent)
	btn.add_theme_stylebox_override("normal",  _btn_normal(accent))
	btn.add_theme_stylebox_override("hover",   _btn_hover(accent))
	btn.add_theme_stylebox_override("pressed", _btn_pressed(accent))
	btn.add_theme_stylebox_override("focus",   _btn_normal(Color(accent, 0.5)))

static func _set_text(menu: Control, path: String, text: String) -> void:
	var btn := menu.get_node_or_null(path) as Button
	if btn:
		btn.text = text

# ── Animasyon ────────────────────────────────────────────────────────────────

static func _slide_in(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 8.0, 0.07)

static func _slide_out(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 0.0, 0.09)
