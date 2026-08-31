class_name MenuVisuals
extends RefCounted

# Presentation layer only: it preserves the menu scene's existing nodes and signal paths.
const INK := Color("e9f2f7")
const MUTED := Color("9eb2c0")
const NAVY := Color("07131e")
const SURFACE := Color("0e2231")
const SURFACE_RAISED := Color("132c3e")
const BORDER := Color("31516a")
const GOLD := Color("f2c14e")
const TEAL := Color("39c6b4")
const RED := Color("dd655c")

static func apply(menu: Control) -> void:
	_apply_background(menu)
	_apply_panel(menu)
	_apply_typography(menu)
	_apply_buttons(menu)
	_apply_settings(menu)
	_play_intro(menu)

static func _apply_background(menu: Control) -> void:
	var background := menu.get_node_or_null("Background") as ColorRect
	if background:
		background.color = NAVY

	var glow := Gradient.new()
	glow.colors = PackedColorArray([
		Color("102f45"), Color("0a1c2b"), Color("07131e")
	])
	glow.offsets = PackedFloat32Array([0.0, 0.50, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = glow
	texture.width = 1600
	texture.height = 900
	texture.fill_from = Vector2(0.15, 0.0)
	texture.fill_to = Vector2(0.85, 1.0)
	var atmosphere := TextureRect.new()
	atmosphere.name = "MenuAtmosphere"
	atmosphere.texture = texture
	atmosphere.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	atmosphere.stretch_mode = TextureRect.STRETCH_SCALE
	atmosphere.set_anchors_preset(Control.PRESET_FULL_RECT)
	atmosphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(atmosphere)
	menu.move_child(atmosphere, 1)

	var top_rule := ColorRect.new()
	top_rule.name = "TopRule"
	top_rule.color = GOLD
	top_rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_rule.offset_bottom = 4.0
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(top_rule)

	var footer := Label.new()
	footer.name = "FooterNote"
	footer.text = "BÜYÜK MİTİNG  /  ÇOK OYUNCULU SOSYAL GERİLİM"
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", MUTED)
	footer.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	footer.position = Vector2(28, -36)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(footer)

static func _apply_panel(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as PanelContainer
	if not panel:
		return
	panel.custom_minimum_size = Vector2(610, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(SURFACE, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = BORDER
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.content_margin_left = 34.0
	style.content_margin_right = 34.0
	style.content_margin_top = 30.0
	style.content_margin_bottom = 26.0
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 24
	style.shadow_offset = Vector2(0, 10)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := menu.get_node_or_null("CenterBox/MainPanel/VBox") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 14)

static func _apply_typography(menu: Control) -> void:
	var title := menu.get_node_or_null("CenterBox/MainPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "SUİKASTÇI & BAŞKAN"
		title.add_theme_font_size_override("font_size", 30)
		title.add_theme_color_override("font_color", INK)
	var subtitle := menu.get_node_or_null("CenterBox/MainPanel/VBox/SubtitleLabel") as Label
	if subtitle:
		subtitle.text = "MİTİNG MEYDANI  •  3D ÇOK OYUNCULU"
		subtitle.add_theme_font_size_override("font_size", 12)
		subtitle.add_theme_color_override("font_color", TEAL)
	var version := menu.get_node_or_null("VersionLabel") as Label
	if version:
		version.text = "ERKEN ERİŞİM  •  v0.3"
		version.add_theme_color_override("font_color", MUTED)

static func _apply_buttons(menu: Control) -> void:
	var paths := {
		"CenterBox/MainPanel/VBox/Buttons/ServerQuickButton": {"text": "ANA SUNUCUYA KATIL", "tone": TEAL, "fill": Color("0d5c61")},
		"CenterBox/MainPanel/VBox/Buttons/SoloButton": {"text": "TEK OYUNCULU OYNA", "tone": GOLD, "fill": Color("745620")},
		"CenterBox/MainPanel/VBox/Buttons/HostButton": {"text": "ODA KUR", "tone": Color("76aee9"), "fill": Color("193f68")},
		"CenterBox/MainPanel/VBox/Buttons/JoinToggleButton": {"text": "IP İLE KATIL", "tone": Color("b0c6d7"), "fill": SURFACE_RAISED},
		"CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton": {"text": "BAĞLAN", "tone": TEAL, "fill": Color("0d5c61")},
		"CenterBox/MainPanel/VBox/Buttons/SettingsButton": {"text": "AYARLAR", "tone": MUTED, "fill": Color("142b3b")},
		"CenterBox/MainPanel/VBox/Buttons/QuitButton": {"text": "OYUNDAN ÇIK", "tone": RED, "fill": Color("44232c")},
		"SettingsPanel/VBox/CloseButton": {"text": "KAYDET VE KAPAT", "tone": TEAL, "fill": Color("0d5c61")}
	}
	for path in paths:
		var button := menu.get_node_or_null(path) as Button
		if button:
			var spec: Dictionary = paths[path]
			button.text = spec.text
			button.custom_minimum_size.y = 46
			button.add_theme_font_size_override("font_size", 14)
			button.add_theme_color_override("font_color", INK)
			button.add_theme_stylebox_override("normal", _button_box(spec.fill, spec.tone, 0.0))
			button.add_theme_stylebox_override("hover", _button_box(_lift(spec.fill), spec.tone, 7.0))
			button.add_theme_stylebox_override("pressed", _button_box(Color(spec.fill, 0.82), spec.tone, 0.0))
			button.pivot_offset = button.size * 0.5
			button.mouse_entered.connect(func() -> void: _button_focus(button))
			button.mouse_exited.connect(func() -> void: _button_unfocus(button))

static func _apply_settings(menu: Control) -> void:
	var panel := menu.get_node_or_null("SettingsPanel") as PanelContainer
	if panel:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(SURFACE, 0.98)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = BORDER
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		style.corner_radius_bottom_left = 16
		style.corner_radius_bottom_right = 16
		style.content_margin_left = 28.0
		style.content_margin_top = 26.0
		style.content_margin_right = 28.0
		style.content_margin_bottom = 26.0
		panel.add_theme_stylebox_override("panel", style)
	for label in [menu.get_node_or_null("SettingsPanel/VBox/SettingsTitle"), menu.get_node_or_null("SettingsPanel/VBox/VolTitle"), menu.get_node_or_null("SettingsPanel/VBox/SensTitle"), menu.get_node_or_null("SettingsPanel/VBox/WeatherTitle")]:
		if label is Label:
			label.add_theme_color_override("font_color", INK)
	var input := menu.get_node_or_null("CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput") as LineEdit
	if input:
		input.add_theme_color_override("font_color", INK)
		input.add_theme_color_override("placeholder_color", MUTED)
		input.add_theme_font_size_override("font_size", 14)

static func _button_box(fill: Color, border: Color, shadow_size: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = Color(border, 0.72)
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_right = 10
	box.corner_radius_bottom_left = 10
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_size = int(shadow_size)
	box.shadow_offset = Vector2(0, 3)
	return box

static func _lift(color: Color) -> Color:
	return Color(min(color.r + 0.06, 1.0), min(color.g + 0.06, 1.0), min(color.b + 0.06, 1.0), color.a)

static func _button_focus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.015, 1.015), 0.12)

static func _button_unfocus(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.12)

static func _play_intro(menu: Control) -> void:
	var panel := menu.get_node_or_null("CenterBox/MainPanel") as Control
	if panel:
		panel.modulate.a = 0.0
		panel.position.y += 18.0
		var tween := menu.create_tween().set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.28)
		tween.tween_property(panel, "position:y", panel.position.y - 18.0, 0.32).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
