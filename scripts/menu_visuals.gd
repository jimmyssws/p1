class_name MenuVisuals
extends RefCounted

# The Last of Us / Control tarzı sol panel menü.
# Butonlarda SIFIR dikdörtgen kutu — sadece metin + hover çizgisi.

const RadioTunerGd = preload("res://scripts/radio_tuner.gd")
const Backdrop     = preload("res://scripts/menu_backdrop.gd")

const TEXT  := Color(1.0, 1.0, 1.0, 1.0)
const DIM   := Color(0.65, 0.65, 0.65, 1.0)
const GOLD  := Color(0.90, 0.68, 0.22, 1.0)
const RED   := Color(0.82, 0.18, 0.18, 1.0)

static func apply(menu: Control) -> void:
	_bg(menu)
	_layout(menu)
	_title(menu)
	_buttons(menu)
	_settings(menu)
	_intro(menu)

# ── Arka plan ─────────────────────────────────────────────────────────────────

static func _bg(menu: Control) -> void:
	var bg := menu.get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.0, 0.0, 0.0, 1.0)
	if menu.get_node_or_null("RallyNightBackdrop") == null:
		var bd := Backdrop.new()
		bd.name = "RallyNightBackdrop"
		menu.add_child(bd)
		menu.move_child(bd, 1)
	# RadioTuner varsa gizle — bu stilde kullanmıyoruz
	var tuner := menu.get_node_or_null("MitingFMTuner")
	if tuner:
		tuner.hide()

# ── Layout: Sol panel full-height ─────────────────────────────────────────────

static func _layout(menu: Control) -> void:
	# CenterBox → Sol panel: ekranın sol %38'i, tam yükseklik
	var center := menu.get_node_or_null("CenterBox") as CenterContainer
	if center:
		center.anchor_left   = 0.0
		center.anchor_top    = 0.0
		center.anchor_right  = 0.40
		center.anchor_bottom = 1.0
		center.offset_left   = 0.0
		center.offset_top    = 0.0
		center.offset_right  = 0.0
		center.offset_bottom = 0.0

	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel:
		panel.custom_minimum_size = Vector2(0.0, 0.0)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", _left_panel_box())

	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 2)

	# VersionLabel → Sol alta
	var ver := menu.get_node_or_null("VersionLabel") as Label
	if ver:
		ver.anchor_left   = 0.0
		ver.anchor_top    = 1.0
		ver.anchor_right  = 0.40
		ver.anchor_bottom = 1.0
		ver.offset_left   = 20.0
		ver.offset_top    = -30.0
		ver.offset_right  = 0.0
		ver.offset_bottom = -8.0
		ver.grow_horizontal = Control.GROW_DIRECTION_END
		ver.grow_vertical   = Control.GROW_DIRECTION_BEGIN
		ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		ver.text = "v0.5  •  ERKEN ERİŞİM"
		ver.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45, 1.0))
		ver.add_theme_font_size_override("font_size", 11)

# ── Başlık ─────────────────────────────────────────────────────────────────────

static func _title(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUİKASTÇI\nVE BAŞKAN"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title.add_theme_font_size_override("font_size", 42)
		title.add_theme_color_override("font_color", TEXT)
		title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		title.add_theme_constant_override("outline_size", 0)
		title.add_theme_constant_override("line_spacing", 4)

	var sub := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if sub:
		sub.text = "GİZLİ ROLLER  //  AÇIK HESAPLAŞMA"
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		sub.add_theme_font_size_override("font_size", 11)
		sub.add_theme_color_override("font_color", Color(GOLD, 0.75))

	# Separator düzenle
	var sep := menu.get_node_or_null("CenterBox/MainPanel/VBox/HSep") as HSeparator
	if sep:
		sep.add_theme_color_override("color", Color(1.0, 1.0, 1.0, 0.10))
		sep.add_theme_constant_override("separation", 14)

# ── Butonlar: SIFIR dikdörtgen, sadece metin ──────────────────────────────────

static func _buttons(menu: Control) -> void:
	# Normal butonlar → altın vurgu
	var main_btns : Array[String] = [
		"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton",
		"CenterBox/MainPanel/VBox/Buttons/SoloButton",
		"CenterBox/MainPanel/VBox/Buttons/HostButton",
		"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton",
	]
	for path in main_btns:
		var btn := menu.get_node_or_null(path) as Button
		if btn:
			_plain_btn(btn, GOLD)

	# Ayarlar → soluk
	var sb := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/SettingsButton") as Button
	if sb:
		_plain_btn(sb, Color(0.60, 0.60, 0.60, 1.0))

	# Çıkış → kırmızı
	var qb := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/QuitButton") as Button
	if qb:
		_plain_btn(qb, RED)

	# Bağlan butonu
	var cb := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton") as Button
	if cb:
		_plain_btn(cb, GOLD)
		cb.custom_minimum_size.y = 0.0

	# Metinler — temiz, kısa
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/ServerQuickButton", "Ana Sunucuya Katıl")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/SoloButton",        "Tek Oyuncu Başlat")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/HostButton",        "Oda Kur  (Host)")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/JoinToggleButton",  "IP ile Katıl")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton", "Bağlan →")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/SettingsButton",    "Ayarlar")
	_txt(menu, "CenterBox/MainPanel/VBox/Buttons/QuitButton",        "Çıkış")

	# IP input → minimal
	var ip := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if ip:
		ip.add_theme_color_override("font_color", TEXT)
		ip.add_theme_color_override("font_placeholder_color", Color(0.45, 0.45, 0.45, 1.0))
		ip.add_theme_stylebox_override("normal", _ip_box())

# ── Ayarlar paneli ─────────────────────────────────────────────────────────────

static func _settings(menu: Control) -> void:
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
		_plain_btn(cb, GOLD)
		cb.text = "← Kaydet & Kapat"

# ── Intro ──────────────────────────────────────────────────────────────────────

static func _intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		var tw := menu.create_tween()
		tw.tween_property(panel, "modulate:a", 1.0, 0.50)

# ── Buton stili: ŞEFFAF normal, ince alt çizgi hover ──────────────────────────

static func _plain_btn(btn: Button, accent: Color) -> void:
	btn.custom_minimum_size.y = 46.0
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(accent, 1.0))
	btn.add_theme_color_override("font_pressed_color", TEXT)
	# Normal: tamamen şeffaf — SIFIR kutu
	btn.add_theme_stylebox_override("normal",  _clear_box())
	# Hover: sadece sol ince çizgi + çok hafif transparan fill
	btn.add_theme_stylebox_override("hover",   _hover_box(accent))
	# Pressed: biraz dolu
	btn.add_theme_stylebox_override("pressed", _pressed_box(accent))
	btn.add_theme_stylebox_override("focus",   _clear_box())
	# Hover animasyonu
	btn.mouse_entered.connect(func(): _slide_in(btn))
	btn.mouse_exited.connect(func():  _slide_out(btn))

static func _clear_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	b.draw_center = false
	b.border_width_left   = 0
	b.border_width_top    = 0
	b.border_width_right  = 0
	b.border_width_bottom = 0
	b.content_margin_left   = 4.0
	b.content_margin_top    = 4.0
	b.content_margin_right  = 4.0
	b.content_margin_bottom = 4.0
	return b

static func _hover_box(accent: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(accent.r, accent.g, accent.b, 0.07)
	b.border_width_left   = 3
	b.border_width_top    = 0
	b.border_width_right  = 0
	b.border_width_bottom = 0
	b.border_color = Color(accent, 0.85)
	b.content_margin_left   = 12.0
	b.content_margin_top    = 4.0
	b.content_margin_right  = 4.0
	b.content_margin_bottom = 4.0
	return b

static func _pressed_box(accent: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(accent.r, accent.g, accent.b, 0.15)
	b.border_width_left   = 3
	b.border_color = Color(accent, 1.0)
	b.content_margin_left   = 12.0
	b.content_margin_top    = 4.0
	b.content_margin_right  = 4.0
	b.content_margin_bottom = 4.0
	return b

static func _left_panel_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	# Soldan sağa doğru eriyip kaybolan koyu panel
	b.bg_color = Color(0.04, 0.04, 0.05, 0.82)
	b.draw_center = true
	b.border_width_left   = 0
	b.border_width_top    = 0
	b.border_width_right  = 0
	b.border_width_bottom = 0
	b.content_margin_left   = 48.0
	b.content_margin_top    = 80.0
	b.content_margin_right  = 32.0
	b.content_margin_bottom = 60.0
	return b

static func _ip_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.08, 0.08, 0.10, 1.0)
	b.border_width_bottom = 1
	b.border_color = Color(GOLD, 0.50)
	b.content_margin_left = 8.0
	b.content_margin_right = 8.0
	return b

static func _settings_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.06, 0.06, 0.08, 0.97)
	b.border_width_left   = 2
	b.border_color = Color(GOLD, 0.40)
	b.shadow_color = Color(0.0, 0.0, 0.0, 0.90)
	b.shadow_size  = 28
	b.content_margin_left   = 28.0
	b.content_margin_top    = 28.0
	b.content_margin_right  = 28.0
	b.content_margin_bottom = 28.0
	return b

# ── Animasyon ──────────────────────────────────────────────────────────────────

static func _slide_in(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 6.0, 0.06)

static func _slide_out(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "position:x", 0.0, 0.08)

static func _txt(menu: Control, path: String, text: String) -> void:
	var btn := menu.get_node_or_null(path) as Button
	if btn:
		btn.text = text
