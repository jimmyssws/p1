class_name MenuVisuals
extends RefCounted

# Radyo stili tam ekran menü görsel katmanı.
# Tüm node yolları ve sinyaller menu.gd'de aynı kalır.
# Bu dosya yalnızca görünüm katmanını yönetir.

const Backdrop       = preload("res://scripts/menu_backdrop.gd")
const RadioTunerGd   = preload("res://scripts/radio_tuner.gd")

const TEXT   := Color("e7e9e6")
const MUTED  := Color("8a9298")
const GOLD   := Color("e5a93c")
const AMBER  := Color("e8850f")
const RED    := Color("ca3432")
const INK    := Color(0.03, 0.035, 0.045)

# Kanal atamaları: button node path → [frekans, kısa başlık, altyazı, vurgu rengi]
const CHANNELS := {
	"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": [104.2, "KANAL 04  •  MEYDAN YAYINI", "CANLI • ANA SUNUCU", false],
	"CenterBox/MainPanel/VBox/Buttons/SoloButton":        [ 96.3, "KANAL 03  •  TATBIKAT",      "TEK OYUNCU • KAYIT", false],
	"CenterBox/MainPanel/VBox/Buttons/HostButton":        [ 92.7, "KANAL 02  •  MITING ODASI",  "COK OYUNCU • HOST",  false],
	"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton":  [ 88.4, "KANAL 01  •  GUVENLI HAT",   "IP ILE BAGLAN",      false],
	"CenterBox/MainPanel/VBox/Buttons/SettingsButton":    [  0.0, "PROTOKOL AYARLARI",           "SES / FARE / GRAFIKLER", false],
	"CenterBox/MainPanel/VBox/Buttons/QuitButton":        [  0.0, "OTURUMU KAPAT",               "ANA TERMINALE DON",  true],
}

static func apply(menu: Control) -> void:
	_setup_background(menu)
	_setup_layout(menu)
	_setup_copy(menu)
	_setup_buttons(menu)
	_setup_settings_panel(menu)
	_play_intro(menu)

# ── 1. Arka plan ve backdrop ─────────────────────────────────────────────────

static func _setup_background(menu: Control) -> void:
	# Düz arka plan rengini siyahımsı yap (backdrop üzerini örtmesin)
	var bg := menu.get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.02, 0.025, 0.03, 1.0)

	# Radyo kasası backdrop
	var backdrop := menu.get_node_or_null("RallyNightBackdrop") as Control
	if backdrop == null:
		backdrop = Backdrop.new()
		backdrop.name = "RallyNightBackdrop"
		menu.add_child(backdrop)
		menu.move_child(backdrop, 1)

# ── 2. Layout — CenterBox'ı radyonun merkez kutusuna hizala ─────────────────

static func _setup_layout(menu: Control) -> void:
	# CenterBox'ı backdrop'taki iki hoparlör arasına hizala
	# Backdrop sol %4 + %28 = %32, sağ da aynı şekilde.
	# Merkez bölge yaklaşık %32 – %68 arası.
	var center := menu.get_node_or_null("CenterBox") as CenterContainer
	if center:
		center.anchor_left   = 0.27
		center.anchor_top    = 0.055
		center.anchor_right  = 0.73
		center.anchor_bottom = 0.945
		center.offset_left   = 0.0
		center.offset_top    = 0.0
		center.offset_right  = 0.0
		center.offset_bottom = 0.0

	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel:
		panel.custom_minimum_size = Vector2(0, 0)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", _panel_box())

	# RadioTuner: menu kökünde, CenterBox ile aynı anchor'larda yaşar
	# Ayrıca panel içinde de olabilir — _setup_buttons'da node yolu kontrol edilir
	var tuner := menu.get_node_or_null("MitingFMTuner") as RadioTuner
	if tuner == null:
		tuner = RadioTunerGd.new()
		tuner.name = "MitingFMTuner"
		menu.add_child(tuner)
	# Tuner'ı CenterBox ile aynı anchor bölgesine sabitle
	tuner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tuner.anchor_left   = 0.27
	tuner.anchor_top    = 0.055
	tuner.anchor_right  = 0.73
	tuner.anchor_bottom = 0.055
	tuner.offset_top    = 0.0
	tuner.offset_bottom = 90.0
	tuner.offset_left   = 0.0
	tuner.offset_right  = 0.0

	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 6)

# ── 3. Metin kopyası ──────────────────────────────────────────────────────────

static func _setup_copy(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUIKASTCI\nVE BASKAN"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title.add_theme_font_size_override("font_size", 34)
		title.add_theme_color_override("font_color", TEXT)
		title.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		title.add_theme_constant_override("outline_size", 2)

	var subtitle := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if subtitle:
		subtitle.text = "GIZLI ROLLER  //  ACIK HESAPLASMA"
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		subtitle.add_theme_font_size_override("font_size", 11)
		subtitle.add_theme_color_override("font_color", Color(GOLD, 0.75))

	var version := menu.get_node_or_null("VersionLabel") as Label
	if version:
		version.text = "ERKEN ERISIM  //  v0.5"
		version.add_theme_color_override("font_color", MUTED)

# ── 4. Butonlar — radyo tuş takımı estetiği ─────────────────────────────────

static func _setup_buttons(menu: Control) -> void:
	var tuner := menu.get_node_or_null("MitingFMTuner") as RadioTuner

	for path in CHANNELS:
		var button := menu.get_node_or_null(path) as Button
		if button == null:
			continue
		var ch: Array = CHANNELS[path]
		var is_danger: bool = ch[3]
		var accent := RED if is_danger else GOLD

		# Radyo tuş takımı stili
		button.custom_minimum_size.y = 62
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", TEXT)
		button.add_theme_color_override("font_hover_color", accent)
		button.add_theme_stylebox_override("normal",  _btn_box(Color(INK.r, INK.g, INK.b, 0.70), Color(MUTED, 0.25), 3))
		button.add_theme_stylebox_override("hover",   _btn_box(Color(accent.r, accent.g, accent.b, 0.16), accent, 5))
		button.add_theme_stylebox_override("pressed", _btn_box(Color(accent.r, accent.g, accent.b, 0.28), TEXT, 5))
		button.add_theme_stylebox_override("focus",   _btn_box(Color(accent.r, accent.g, accent.b, 0.10), Color(GOLD, 0.5), 3))
		button.add_theme_color_override("icon_modulate", accent)

		# Hover → frekansı radyo tuner'a gönder
		if ch[0] > 0.0 and tuner:
			var freq: float  = ch[0]
			var lbl: String  = ch[1]
			var sub: String  = ch[2]
			button.mouse_entered.connect(func(): tuner.tune(freq, lbl, sub))

		# Hover slayt efekti
		button.mouse_entered.connect(func() -> void: _slide_in(button))
		button.mouse_exited.connect(func() -> void: _slide_out(button))

	# Buton metinlerini ayarla (simgeler Unicode)
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/ServerQuickButton",
		"⚡  MEYDAN YAYINI  —  ANA SUNUCU\n    104.2 MHz  •  CANLI  •  Katil: 100.68.81.79")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/SoloButton",
		"▶  TATBIKAT MODU  —  TEK OYUNCU\n    96.3 MHz  •  KAYIT  •  Hizli Basla")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/HostButton",
		"◈  MITING ODASI  —  ODA KUR  (HOST)\n    92.7 MHz  •  YAYIN AC  •  Port 9999")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/JoinToggleButton",
		"→  GUVENLI HAT  —  IP ILE BAGLAN\n    88.4 MHz  •  IP GIRIN")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton",
		"  BAGLAN")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/SettingsButton",
		"⚙  PROTOKOL AYARLARI  —  SES / FARE / GRAFIK")
	_set_btn_text(menu, "CenterBox/MainPanel/VBox/Buttons/QuitButton",
		"×  OTURUMU KAPAT  —  ANA TERMINALE DON")

	# IP input kutusu stili
	var ip_input := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if ip_input:
		ip_input.add_theme_color_override("font_color", TEXT)
		ip_input.add_theme_color_override("font_placeholder_color", Color(MUTED, 0.6))
		ip_input.add_theme_stylebox_override("normal", _input_box())

# ── 5. Ayarlar paneli ────────────────────────────────────────────────────────

static func _setup_settings_panel(menu: Control) -> void:
	var panel := menu.get_node_or_null("SettingsPanel") as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _settings_box())
	for lp in ["SettingsPanel/VBox/SettingsTitle", "SettingsPanel/VBox/VolTitle",
			   "SettingsPanel/VBox/SensTitle", "SettingsPanel/VBox/WeatherTitle"]:
		var lbl := menu.get_node_or_null(lp) as Label
		if lbl:
			lbl.add_theme_color_override("font_color", TEXT)
	var close_btn := menu.get_node_or_null("SettingsPanel/VBox/CloseButton") as Button
	if close_btn:
		close_btn.add_theme_stylebox_override("normal",  _btn_box(Color(INK.r, INK.g, INK.b, 0.7), Color(GOLD, 0.3), 3))
		close_btn.add_theme_stylebox_override("hover",   _btn_box(Color(GOLD.r, GOLD.g, GOLD.b, 0.2), GOLD, 5))
		close_btn.add_theme_stylebox_override("pressed", _btn_box(Color(GOLD.r, GOLD.g, GOLD.b, 0.35), TEXT, 5))
		close_btn.add_theme_color_override("font_color", TEXT)
		close_btn.text = "← KAYDET & KAPAT"

# ── 6. Intro animasyonu ──────────────────────────────────────────────────────

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		var tween := menu.create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.55)

# ── StyleBox fabrikaları ─────────────────────────────────────────────────────

static func _panel_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.035, 0.040, 0.052, 0.96)
	b.border_width_left   = 2
	b.border_width_top    = 2
	b.border_width_right  = 2
	b.border_width_bottom = 2
	b.border_color = Color(0.28, 0.30, 0.34, 0.50)
	b.corner_radius_top_left     = 14
	b.corner_radius_top_right    = 14
	b.corner_radius_bottom_left  = 14
	b.corner_radius_bottom_right = 14
	b.shadow_color = Color(0, 0, 0, 0.85)
	b.shadow_size  = 28
	b.shadow_offset = Vector2(0, 8)
	b.content_margin_left   = 20.0
	b.content_margin_top    = 96.0   # RadioTuner yüksekliği için boşluk
	b.content_margin_right  = 20.0
	b.content_margin_bottom = 16.0
	return b

static func _btn_box(fill: Color, border: Color, left_w: int) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_width_left   = left_w
	b.border_width_top    = 1
	b.border_width_right  = 1
	b.border_width_bottom = 1
	b.border_color = border
	b.corner_radius_top_left     = 10
	b.corner_radius_top_right    = 4
	b.corner_radius_bottom_right = 4
	b.corner_radius_bottom_left  = 10
	b.shadow_color  = Color(0, 0, 0, 0.30)
	b.shadow_size   = 4
	b.shadow_offset = Vector2(2, 2)
	b.content_margin_left   = 18.0
	b.content_margin_top    = 6.0
	b.content_margin_right  = 10.0
	b.content_margin_bottom = 6.0
	return b

static func _input_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.06, 0.07, 0.09)
	b.border_width_left   = 1
	b.border_width_top    = 1
	b.border_width_right  = 1
	b.border_width_bottom = 1
	b.border_color = Color(GOLD, 0.45)
	b.corner_radius_top_left     = 8
	b.corner_radius_top_right    = 8
	b.corner_radius_bottom_right = 8
	b.corner_radius_bottom_left  = 8
	b.content_margin_left = 12.0
	b.content_margin_right = 8.0
	return b

static func _settings_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.03, 0.035, 0.048, 0.97)
	b.border_width_top    = 2
	b.border_width_left   = 2
	b.border_width_right  = 2
	b.border_width_bottom = 2
	b.border_color = Color(GOLD, 0.38)
	b.corner_radius_top_left     = 16
	b.corner_radius_top_right    = 16
	b.corner_radius_bottom_left  = 16
	b.corner_radius_bottom_right = 16
	b.shadow_color  = Color(0, 0, 0, 0.75)
	b.shadow_size   = 26
	b.content_margin_left   = 28.0
	b.content_margin_top    = 28.0
	b.content_margin_right  = 28.0
	b.content_margin_bottom = 28.0
	return b

# ── Animasyon ────────────────────────────────────────────────────────────────

static func _slide_in(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 8.0, 0.08)

static func _slide_out(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 0.0, 0.10)

# ── Yardımcı ────────────────────────────────────────────────────────────────

static func _set_btn_text(menu: Control, path: String, text: String) -> void:
	var btn := menu.get_node_or_null(path) as Button
	if btn:
		btn.text = text
