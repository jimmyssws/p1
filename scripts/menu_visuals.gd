class_name MenuVisuals
extends RefCounted

# Presentation-only main-menu pass. Gameplay node paths and button signals stay intact.
# Art direction: a tactile political-thriller campaign poster, not a SaaS dashboard.
const IVORY := Color("f2e8d5")
const INK := Color("17130f")
const CHARCOAL := Color("29231d")
const OXIDE := Color("a52b25")
const OXIDE_DARK := Color("5b1d1a")
const MUSTARD := Color("c79328")
const OLIVE := Color("4d5b36")
const CONCRETE := Color("b5aa98")

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
		background.color = Color("1e1a16")
	var field := menu.get_node_or_null("PosterField") as ColorRect
	if field == null:
		field = ColorRect.new()
		field.name = "PosterField"
		field.set_anchors_preset(Control.PRESET_FULL_RECT)
		field.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu.add_child(field)
		menu.move_child(field, 1)
	field.color = Color("6a2420")
	_add_rule(menu, "TopRule", Vector2(0, 72), MUSTARD)
	_add_rule(menu, "BottomRule", Vector2(0, -76), MUSTARD, true)
	_add_banner(menu, "TopBanner", "MEYDAN DOSYASI  /  GİZLİ ROLLER  /  AÇIK HESAPLAŞMA", Vector2(0, 28), IVORY)
	_add_banner(menu, "BottomBanner", "BİR MİTİNG. ÜÇ ROL. KİMSE MASUM DEĞİL.", Vector2(0, -50), IVORY, true)

static func _apply_main_panel(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if panel == null:
		return
	panel.custom_minimum_size = Vector2(660, 0)
	panel.add_theme_stylebox_override("panel", _panel_box())
	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 12)

static func _apply_copy(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUIKASTCI & BASKAN"
		title.add_theme_font_size_override("font_size", 36)
		title.add_theme_color_override("font_color", OXIDE)
		title.add_theme_color_override("font_outline_color", IVORY)
		title.add_theme_constant_override("outline_size", 2)
	var subtitle := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if subtitle:
		subtitle.text = "MEYDAN GECESI  /  SOSYAL GIZEM  /  COK OYUNCULU"
		subtitle.add_theme_font_size_override("font_size", 13)
		subtitle.add_theme_color_override("font_color", CHARCOAL)
	var version := menu.get_node_or_null("VersionLabel") as Label
	if version:
		version.text = "ERKEN ERISIM  •  DOSYA 04"
		version.add_theme_color_override("font_color", IVORY)

static func _apply_buttons(menu: Control) -> void:
	var buttons := {
		"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": {"text": "ANA MEYDANA GIR", "tone": OXIDE},
		"CenterBox/MainPanel/VBox/Buttons/SoloButton": {"text": "TEK BASINA TATBIKAT", "tone": MUSTARD},
		"CenterBox/MainPanel/VBox/Buttons/HostButton": {"text": "YENI MITING KUR", "tone": OLIVE},
		"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton": {"text": "ODA KODU / IP ILE GIR", "tone": CHARCOAL},
		"CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton": {"text": "BAGLAN", "tone": OXIDE},
		"CenterBox/MainPanel/VBox/Buttons/SettingsButton": {"text": "SESLER VE KONTROLLER", "tone": CHARCOAL},
		"CenterBox/MainPanel/VBox/Buttons/QuitButton": {"text": "MASADAN KALK", "tone": OXIDE_DARK},
		"SettingsPanel/VBox/CloseButton": {"text": "KAYDET VE DON", "tone": OLIVE}
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
			label.add_theme_color_override("font_color", CHARCOAL)
	var input := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if input:
		input.add_theme_color_override("font_color", INK)
		input.add_theme_color_override("placeholder_color", Color("6e6254"))
		input.add_theme_stylebox_override("normal", _input_box())

static func _apply_button(button: Button, tone: Color) -> void:
	button.custom_minimum_size.y = 52
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", IVORY)
	button.add_theme_stylebox_override("normal", _button_box(tone.darkened(0.18), tone, 2))
	button.add_theme_stylebox_override("hover", _button_box(tone, IVORY, 5))
	button.add_theme_stylebox_override("pressed", _button_box(tone.darkened(0.40), INK, 1))
	button.add_theme_stylebox_override("focus", _button_box(tone.darkened(0.18), MUSTARD, 4))
	button.mouse_entered.connect(func() -> void: _focus(button))
	button.mouse_exited.connect(func() -> void: _unfocus(button))

static func _panel_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = IVORY
	box.border_width_left = 5
	box.border_width_top = 5
	box.border_width_right = 5
	box.border_width_bottom = 5
	box.border_color = INK
	box.corner_radius_top_left = 2
	box.corner_radius_top_right = 2
	box.corner_radius_bottom_left = 2
	box.corner_radius_bottom_right = 2
	box.shadow_color = Color(0.04, 0.03, 0.02, 0.64)
	box.shadow_size = 20
	box.shadow_offset = Vector2(9, 11)
	box.content_margin_left = 40.0
	box.content_margin_top = 32.0
	box.content_margin_right = 40.0
	box.content_margin_bottom = 30.0
	return box

static func _button_box(fill: Color, border: Color, shadow: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.border_color = border
	box.corner_radius_top_left = 1
	box.corner_radius_top_right = 1
	box.corner_radius_bottom_left = 1
	box.corner_radius_bottom_right = 1
	box.shadow_color = Color(0.08, 0.05, 0.03, 0.52)
	box.shadow_size = shadow
	box.shadow_offset = Vector2(3, 3)
	return box

static func _input_box() -> StyleBoxFlat:
	return _button_box(Color("ddd1bd"), CHARCOAL, 0)

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
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 3)

static func _add_rule(menu: Control, node_name: String, offset: Vector2, tone: Color, bottom: bool = false) -> void:
	var rule := menu.get_node_or_null(node_name) as ColorRect
	if rule == null:
		rule = ColorRect.new()
		rule.name = node_name
		rule.set_anchors_preset(Control.PRESET_BOTTOM_WIDE if bottom else Control.PRESET_TOP_WIDE)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu.add_child(rule)
	rule.color = tone
	rule.position = offset
	rule.size = Vector2(0, 3)

static func _focus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.018, 1.018), 0.10)

static func _unfocus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.10)

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		panel.position.y += 18.0
		var tween := menu.create_tween().set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.28)
		tween.tween_property(panel, "position:y", panel.position.y - 18.0, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
