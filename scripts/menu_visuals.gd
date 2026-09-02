class_name MenuVisuals
extends RefCounted

# Presentation-only. The menu retains every original node path and action signal.
const Backdrop = preload("res://scripts/menu_backdrop.gd")
const RadioTunerScene = preload("res://scripts/radio_tuner.gd")
const INK := Color("0f1319")
const PANEL := Color(0.035, 0.055, 0.075, 0.86)
const TEXT := Color("e7e9e6")
const MUTED := Color("9da8ae")
const GOLD := Color("e5a93c")
const WINE := Color("651419")
const RED := Color("ca3432")

static func apply(menu: Control) -> void:
	_apply_scene(menu)
	_apply_copy(menu)
	_apply_navigation(menu)
	_apply_settings(menu)
	_play_intro(menu)

static func _apply_scene(menu: Control) -> void:
	var background := menu.get_node_or_null("Background") as ColorRect
	if background:
		background.color = INK
	var backdrop := menu.get_node_or_null("RallyNightBackdrop") as Control
	if backdrop == null:
		backdrop = Backdrop.new()
		backdrop.name = "RallyNightBackdrop"
		menu.add_child(backdrop)
		menu.move_child(backdrop, 1)
	var tuner := menu.get_node_or_null("MitingFMTuner") as RadioTuner
	if tuner == null:
		tuner = RadioTunerScene.new()
		tuner.name = "MitingFMTuner"
		menu.add_child(tuner)
	# The menu is a physical CRT broadcast monitor, centered over the rally scene.
	var center := menu.get_node_or_null("CenterBox") as CenterContainer
	if center:
		center.anchor_left = 0.30
		center.anchor_top = 0.12
		center.anchor_right = 0.78
		center.anchor_bottom = 0.84
		center.offset_left = 0.0
		center.offset_top = 0.0
		center.offset_right = 0.0
		center.offset_bottom = 0.0
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel:
		panel.custom_minimum_size = Vector2(640, 610)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", _tv_box())
	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 8)
	_add_label(menu, "OperationMark", "// OPERASYON DOSYASI  04", Vector2(48, 45), MUTED, 12)
	_add_label(menu, "LiveReadout", "CANLI YAYIN  •  MEYDAN 7  •  FREKANS 104.2", Vector2(0, -42), MUTED, 11, true)
	_add_label(menu, "SceneCaption", "GECE MITINGI\nGUVENLIK CERCEVESI AKTIF", Vector2(0, -130), TEXT, 13, true)

static func _apply_copy(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUIKASTCI\nVE BASKAN"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title.add_theme_font_size_override("font_size", 39)
		title.add_theme_color_override("font_color", TEXT)
		title.add_theme_color_override("font_outline_color", Color("000000"))
		title.add_theme_constant_override("outline_size", 2)
	var subtitle := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if subtitle:
		subtitle.text = "GIZLI ROLLER  /  ACIK HESAPLASMA"
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		subtitle.add_theme_font_size_override("font_size", 12)
		subtitle.add_theme_color_override("font_color", GOLD)
	var version := menu.get_node_or_null("VersionLabel") as Label
	if version:
		version.text = "ERKEN ERISIM  //  v0.5"
		version.add_theme_color_override("font_color", MUTED)

static func _apply_navigation(menu: Control) -> void:
	var buttons := {
		"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": "KANAL 04  //  MEYDAN YAYINI\n104.2 MHz  •  CANLI",
		"CenterBox/MainPanel/VBox/Buttons/SoloButton": "KANAL 03  //  TATBIKAT\n96.3 MHz  •  KAYIT",
		"CenterBox/MainPanel/VBox/Buttons/HostButton": "KANAL 02  //  MITING ODASI\n92.7 MHz  •  YAYIN AC",
		"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton": "KANAL 01  //  GUVENLI HAT\n88.4 MHz  •  BAGLAN",
		"CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton": "BAGLANTIYI AÇ",
		"CenterBox/MainPanel/VBox/Buttons/SettingsButton": "⚙  PROTOKOL AYARLARI\n   SES / KONTROL / ERISILEBILIRLIK",
		"CenterBox/MainPanel/VBox/Buttons/QuitButton": "×  OTURUMU KAPAT\n   ANA TERMINALE DON",
		"SettingsPanel/VBox/CloseButton": "DEGISIKLIKLERI KAYDET"
	}
	for path in buttons:
		var button := menu.get_node_or_null(path) as Button
		if button:
			button.text = buttons[path]
			_apply_nav_button(menu, button, RED if "KAPAT" in button.text else GOLD)
			var tuner := menu.get_node_or_null("MitingFMTuner") as RadioTuner
			if tuner:
				var freq := 104.2 if "ServerQuick" in path else (96.3 if "Solo" in path else (92.7 if "Host" in path else 88.4))
				button.mouse_entered.connect(func(): tuner.tune(freq, button.text.split("\n")[0]))

static func _apply_settings(menu: Control) -> void:
	var panel := menu.get_node_or_null("SettingsPanel") as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _rail_box())
	for label_path in ["SettingsPanel/VBox/SettingsTitle", "SettingsPanel/VBox/VolTitle", "SettingsPanel/VBox/SensTitle", "SettingsPanel/VBox/WeatherTitle"]:
		var label := menu.get_node_or_null(label_path) as Label
		if label:
			label.add_theme_color_override("font_color", TEXT)
	var input := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if input:
		input.add_theme_color_override("font_color", TEXT)
		input.add_theme_color_override("placeholder_color", MUTED)
		input.add_theme_stylebox_override("normal", _input_box())

static func _apply_nav_button(menu: Control, button: Button, accent: Color) -> void:
	button.custom_minimum_size.y = 68
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_stylebox_override("normal", _action_card_box(Color(0.04, 0.065, 0.09, 0.58), Color("40505b"), 2))
	button.add_theme_stylebox_override("hover", _action_card_box(Color(accent.r, accent.g, accent.b, 0.18), accent, 4))
	button.add_theme_stylebox_override("pressed", _action_card_box(Color(accent.r, accent.g, accent.b, 0.30), TEXT, 5))
	button.add_theme_stylebox_override("focus", _action_card_box(Color(accent.r, accent.g, accent.b, 0.14), GOLD, 4))
	button.mouse_entered.connect(func() -> void: _focus(button))
	button.mouse_exited.connect(func() -> void: _unfocus(button))

static func _tv_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("101d21")
	box.border_width_left = 18
	box.border_width_top = 18
	box.border_width_right = 18
	box.border_width_bottom = 26
	box.border_color = Color("2b3430")
	box.corner_radius_top_left = 32
	box.corner_radius_top_right = 32
	box.corner_radius_bottom_left = 44
	box.corner_radius_bottom_right = 44
	box.shadow_color = Color(0, 0, 0, 0.82)
	box.shadow_size = 34
	box.shadow_offset = Vector2(0, 16)
	box.content_margin_left = 42.0
	box.content_margin_top = 34.0
	box.content_margin_right = 42.0
	box.content_margin_bottom = 34.0
	return box

static func _rail_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = PANEL
	box.border_width_right = 1
	box.border_color = Color(0.90, 0.66, 0.24, 0.38)
	box.shadow_color = Color(0, 0, 0, 0.55)
	box.shadow_size = 22
	box.shadow_offset = Vector2(8, 0)
	box.content_margin_left = 30.0
	box.content_margin_top = 32.0
	box.content_margin_right = 28.0
	box.content_margin_bottom = 28.0
	return box

static func _action_card_box(fill: Color, border: Color, left_width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = left_width
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = border
	box.corner_radius_top_left = 12
	box.corner_radius_top_right = 3
	box.corner_radius_bottom_left = 3
	box.corner_radius_bottom_right = 12
	box.shadow_color = Color(0, 0, 0, 0.34)
	box.shadow_size = 5
	box.shadow_offset = Vector2(3, 3)
	box.content_margin_left = 20.0
	box.content_margin_top = 7.0
	box.content_margin_right = 10.0
	box.content_margin_bottom = 7.0
	return box

static func _nav_box(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = width
	box.border_color = border
	box.content_margin_left = 14.0
	box.content_margin_right = 8.0
	return box

static func _input_box() -> StyleBoxFlat:
	var box := _nav_box(Color("121b24"), GOLD, 1)
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	return box

static func _add_label(menu: Control, node_name: String, text: String, position: Vector2, color: Color, size: int, bottom: bool = false) -> void:
	var label := menu.get_node_or_null(node_name) as Label
	if label == null:
		label = Label.new()
		label.name = node_name
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT if bottom else Control.PRESET_TOP_LEFT)
		menu.add_child(label)
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if bottom:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

static func _focus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "position:x", 7.0, 0.10)

static func _unfocus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "position:x", 0.0, 0.10)

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		var tween := menu.create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.45)
