class_name MenuVisuals
extends RefCounted

# Menu-only presentation. Existing controls and signal paths are never renamed.
const INK := Color("fff7e8")
const NIGHT := Color("142039")
const SKY := Color("4fa6e8")
const GOLD := Color("f3bd35")
const GREEN := Color("43ae67")
const RED := Color("d9504f")
const OUTLINE := Color("152235")

static func apply(menu: Control) -> void:
	_apply_background(menu)
	_apply_main_panel(menu)
	_apply_copy(menu)
	_apply_buttons(menu)
	_apply_settings(menu)
	_play_intro(menu)

static func _apply_background(menu: Control) -> void:
	var background := menu.get_node_or_null("Background") as ColorRect
	if background:
		background.color = NIGHT
	var atmosphere := menu.get_node_or_null("RallySky") as ColorRect
	if atmosphere == null:
		atmosphere = ColorRect.new()
		atmosphere.name = "RallySky"
		atmosphere.set_anchors_preset(Control.PRESET_FULL_RECT)
		atmosphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu.add_child(atmosphere)
		menu.move_child(atmosphere, 1)
	atmosphere.color = Color("254d78")
	_add_banner(menu, "TopBanner", "MİTİNG MEYDANI  •  OYUNCULAR HAZIR MI?", Vector2(0, 26), SKY)
	_add_banner(menu, "BottomBanner", "CANLI MİTİNG / TAKTİK • BLÖF • KAÇIŞ", Vector2(0, -54), GOLD, true)

static func _apply_main_panel(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel == null:
		return
	panel.custom_minimum_size = Vector2(620, 0)
	panel.add_theme_stylebox_override("panel", _panel_box())
	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 13)

static func _apply_copy(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUİKASTÇI & BAŞKAN"
		title.add_theme_font_size_override("font_size", 32)
		title.add_theme_color_override("font_color", GOLD)
		title.add_theme_color_override("font_outline_color", OUTLINE)
		title.add_theme_constant_override("outline_size", 8)
	var subtitle := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if subtitle:
		subtitle.text = "3 ROL  •  1 MEYDAN  •  SON SÖZ SENİN"
		subtitle.add_theme_font_size_override("font_size", 14)
		subtitle.add_theme_color_override("font_color", INK)
	var version := menu.get_node_or_null("VersionLabel") as Label
	if version:
		version.text = "ERKEN ERİŞİM  •  v0.4"
		version.add_theme_color_override("font_color", Color("c8d7e8"))

static func _apply_buttons(menu: Control) -> void:
	var buttons := {
		"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": {"text": "ANA SUNUCUYA KATIL", "tone": GREEN},
		"CenterBox/MainPanel/VBox/Buttons/SoloButton": {"text": "TEK OYUNCULU BAŞLAT", "tone": GOLD},
		"CenterBox/MainPanel/VBox/Buttons/HostButton": {"text": "ÇOK OYUNCULU ODA KUR", "tone": SKY},
		"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton": {"text": "IP İLE ODAYA KATIL", "tone": Color("758ca8")},
		"CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton": {"text": "BAĞLAN", "tone": GREEN},
		"CenterBox/MainPanel/VBox/Buttons/SettingsButton": {"text": "AYARLAR", "tone": Color("758ca8")},
		"CenterBox/MainPanel/VBox/Buttons/QuitButton": {"text": "OYUNDAN ÇIK", "tone": RED},
		"SettingsPanel/VBox/CloseButton": {"text": "KAYDET VE KAPAT", "tone": GREEN}
	}
	for path in buttons:
		var button := menu.get_node_or_null(path) as Button
		if button:
			var spec: Dictionary = buttons[path]
			button.text = spec.text
			_apply_button(button, spec.tone)

static func _apply_settings(menu: Control) -> void:
	var panel := menu.get_node_or_null("SettingsPanel") as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _panel_box())
	for label_path in ["SettingsPanel/VBox/SettingsTitle", "SettingsPanel/VBox/VolTitle", "SettingsPanel/VBox/SensTitle", "SettingsPanel/VBox/WeatherTitle"]:
		var label := menu.get_node_or_null(label_path) as Label
		if label:
			label.add_theme_color_override("font_color", INK)
	var input := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if input:
		input.add_theme_color_override("font_color", INK)
		input.add_theme_color_override("placeholder_color", Color("afc1d2"))
		input.add_theme_stylebox_override("normal", _input_box())

static func _apply_button(button: Button, tone: Color) -> void:
	button.custom_minimum_size.y = 50
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _button_box(tone.darkened(0.42), tone, 3))
	button.add_theme_stylebox_override("hover", _button_box(tone.darkened(0.18), Color("fff0c9"), 6))
	button.add_theme_stylebox_override("pressed", _button_box(tone.darkened(0.58), tone.darkened(0.1), 1))
	button.add_theme_stylebox_override("focus", _button_box(tone.darkened(0.42), Color("fff0c9"), 4))
	button.mouse_entered.connect(func() -> void: _focus(button))
	button.mouse_exited.connect(func() -> void: _unfocus(button))

static func _panel_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("1d3151")
	box.border_width_left = 3
	box.border_width_top = 3
	box.border_width_right = 3
	box.border_width_bottom = 3
	box.border_color = GOLD
	box.corner_radius_top_left = 20
	box.corner_radius_top_right = 20
	box.corner_radius_bottom_left = 20
	box.corner_radius_bottom_right = 20
	box.shadow_color = Color(0.02, 0.03, 0.08, 0.72)
	box.shadow_size = 24
	box.shadow_offset = Vector2(0, 10)
	box.content_margin_left = 36.0
	box.content_margin_top = 30.0
	box.content_margin_right = 36.0
	box.content_margin_bottom = 28.0
	return box

static func _button_box(fill: Color, border: Color, shadow: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.border_color = border
	box.corner_radius_top_left = 11
	box.corner_radius_top_right = 11
	box.corner_radius_bottom_left = 11
	box.corner_radius_bottom_right = 11
	box.shadow_color = Color(0.02, 0.04, 0.08, 0.55)
	box.shadow_size = shadow
	box.shadow_offset = Vector2(0, 4)
	return box

static func _input_box() -> StyleBoxFlat:
	var box := _button_box(Color("10213b"), SKY, 0)
	box.corner_radius_top_left = 8
	box.corner_radius_top_right = 8
	box.corner_radius_bottom_left = 8
	box.corner_radius_bottom_right = 8
	return box

static func _add_banner(menu: Control, node_name: String, text: String, offset: Vector2, tone: Color, bottom: bool = false) -> void:
	var label := menu.get_node_or_null(node_name) as Label
	if label == null:
		label = Label.new()
		label.name = node_name
		label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE if bottom else Control.PRESET_TOP_WIDE)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu.add_child(label)
	label.text = text
	label.position = offset
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", tone)
	label.add_theme_color_override("font_outline_color", OUTLINE)
	label.add_theme_constant_override("outline_size", 5)

static func _focus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.02, 1.02), 0.10)

static func _unfocus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.10)

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		panel.position.y += 22.0
		var tween := menu.create_tween().set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.32)
		tween.tween_property(panel, "position:y", panel.position.y - 22.0, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
