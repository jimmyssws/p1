class_name GameUIVisuals
extends RefCounted

# Shared presentation for lobby and HUD. It never renames nodes or changes gameplay state.
# Visual system: printed field dossier / live campaign broadcast.
const IVORY := Color("f2e8d5")
const INK := Color("17130f")
const OXIDE := Color("a52b25")
const OXIDE_DARK := Color("5b1d1a")
const MUSTARD := Color("c79328")
const OLIVE := Color("4d5b36")
const OLIVE_DARK := Color("28341f")
const SLATE := Color("3a3934")
const PAPER_DARK := Color("c7bba6")

static func apply_lobby(canvas: CanvasLayer) -> void:
	var center := canvas.get_node_or_null("LobbyCenter") as CenterContainer
	if center == null:
		return
	# Lobby is a right-side briefing overlay; the live 3D plaza remains the hero.
	center.anchor_left = 0.56
	center.anchor_top = 0.12
	center.anchor_right = 0.96
	center.anchor_bottom = 0.88
	var panel := center.get_child(0) as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _panel_box(GOLD, Color(0.025, 0.04, 0.055, 0.88), 0, 14))
		panel.custom_minimum_size = Vector2(0, 470)
	for label in _all_labels(canvas):
		label.add_theme_color_override("font_color", IVORY)
	for button in _all_buttons(canvas):
		_apply_button(button, _button_tone(button.text))
	var title := _first_label_with_text(canvas, "MİTİNG")
	if title:
		title.text = "MEYDAN BRIFINGI"
		title.add_theme_font_size_override("font_size", 28)
		title.add_theme_color_override("font_color", OXIDE)
	_add_corner_stamp(panel, "CANLI OTURUM", OXIDE)

static func apply_match_hud(root: Node) -> void:
	var header := root.get_node_or_null("TopBarHUD/TopHeader") as PanelContainer
	if header:
		header.add_theme_stylebox_override("panel", _flat_box(Color(0.02, 0.035, 0.05, 0.72), GOLD, 0, 1))
		header.custom_minimum_size.y = 52
	var timer := root.find_child("TimerLabel", true, false) as Label
	if timer:
		timer.add_theme_color_override("font_color", OXIDE)
		timer.add_theme_font_size_override("font_size", 22)
	var role_badge := root.get_node_or_null("TopBarHUD/TopHeader/Margin/HBox/RoleBadge") as PanelContainer
	if role_badge:
		role_badge.add_theme_stylebox_override("panel", _flat_box(OLIVE_DARK, OLIVE, 0, 2))
	var vote_bar := root.find_child("VoteProgressBar", true, false) as ProgressBar
	if vote_bar:
		vote_bar.add_theme_stylebox_override("background", _flat_box(OXIDE_DARK, INK, 0, 1))
		vote_bar.add_theme_stylebox_override("fill", _flat_box(MUSTARD, INK, 0, 1))
	var top := root.get_node_or_null("TopBarHUD") as CanvasLayer
	if top:
		_add_hud_label(top, "BroadcastTag", "  MEYDAN BULTENI  /  CANLI  ", Vector2(28, 18), OXIDE)

static func apply_player_hud(player: Node) -> void:
	var hud := player.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		return
	for path in ["WeaponPanel", "SusMeterPanel", "CCTVPanel", "MissionPanel"]:
		var panel := hud.get_node_or_null(path) as Control
		if panel:
			panel.add_theme_stylebox_override("panel", _panel_box(GOLD, Color(0.02, 0.035, 0.05, 0.76), 0, 7))
	var weapon := hud.get_node_or_null("WeaponPanel") as PanelContainer
	if weapon:
		weapon.custom_minimum_size = Vector2(430, 122)
		var category := weapon.get_node_or_null("Margin/VBox/CategoryLabel") as Label
		if category:
			category.add_theme_color_override("font_color", OXIDE)
			category.add_theme_font_size_override("font_size", 13)
		for slot_name in ["Slot1", "Slot2", "Slot3", "Slot4"]:
			var slot := weapon.get_node_or_null("Margin/VBox/SlotRow/" + slot_name) as PanelContainer
			if slot:
				slot.add_theme_stylebox_override("panel", _flat_box(PAPER_DARK, INK, 0, 2))
	var sus_bar := hud.get_node_or_null("SusMeterPanel/VBox/SusProgressBar") as ProgressBar
	if sus_bar:
		sus_bar.add_theme_stylebox_override("background", _flat_box(PAPER_DARK, INK, 0, 1))
		sus_bar.add_theme_stylebox_override("fill", _flat_box(OXIDE, INK, 0, 1))
	var action := hud.get_node_or_null("ActionPrompt") as Label
	if action:
		action.add_theme_color_override("font_color", IVORY)
		action.add_theme_font_size_override("font_size", 18)
		action.add_theme_constant_override("outline_size", 7)
		action.add_theme_color_override("font_outline_color", INK)
	var mission := hud.get_node_or_null("MissionPanel/MissionLabel") as Label
	if mission:
		mission.add_theme_color_override("font_color", INK)
		mission.add_theme_font_size_override("font_size", 15)
	var pause_card := hud.get_node_or_null("PausePanel/CenterBox/Card") as PanelContainer
	if pause_card:
		pause_card.add_theme_stylebox_override("panel", _panel_box(OXIDE, IVORY, 0, 18))
	var summary_card := hud.get_node_or_null("SummaryPanel/CenterBox/Panel") as PanelContainer
	if summary_card:
		summary_card.add_theme_stylebox_override("panel", _panel_box(OXIDE, IVORY, 0, 18))
	for path in ["PausePanel/CenterBox/Card/VBox/ResumeButton", "PausePanel/CenterBox/Card/VBox/QuitButton", "SummaryPanel/CenterBox/Panel/VBox/QuitButton"]:
		var button := hud.get_node_or_null(path) as Button
		if button:
			_apply_button(button, OLIVE if "Resume" in path else OXIDE)

static func _all_buttons(root: Node) -> Array[Button]:
	var result: Array[Button] = []
	for node in root.find_children("*", "Button", true, false):
		result.append(node as Button)
	return result

static func _all_labels(root: Node) -> Array[Label]:
	var result: Array[Label] = []
	for node in root.find_children("*", "Label", true, false):
		result.append(node as Label)
	return result

static func _first_label_with_text(root: Node, fragment: String) -> Label:
	for label in _all_labels(root):
		if fragment in label.text:
			return label
	return null

static func _button_tone(text: String) -> Color:
	if "BAŞLAT" in text or "HAZIR" in text:
		return OLIVE
	if "MENÜ" in text or "ÇIK" in text or "DEĞİL" in text:
		return OXIDE
	return MUSTARD

static func _apply_button(button: Button, tone: Color) -> void:
	button.add_theme_color_override("font_color", IVORY)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", _flat_box(tone.darkened(0.22), tone, 0, 2))
	button.add_theme_stylebox_override("hover", _flat_box(tone, IVORY, 0, 3))
	button.add_theme_stylebox_override("pressed", _flat_box(tone.darkened(0.45), INK, 0, 2))
	button.add_theme_stylebox_override("focus", _flat_box(tone.darkened(0.22), MUSTARD, 0, 3))

static func _panel_box(accent: Color, fill: Color, radius: int, shadow: int) -> StyleBoxFlat:
	var box := _flat_box(fill, accent, radius, 4)
	box.shadow_color = Color(0.04, 0.03, 0.02, 0.66)
	box.shadow_size = shadow
	box.shadow_offset = Vector2(7, 8)
	box.content_margin_left = 20.0
	box.content_margin_top = 16.0
	box.content_margin_right = 20.0
	box.content_margin_bottom = 16.0
	return box

static func _flat_box(fill: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_width_left = width
	box.border_width_top = width
	box.border_width_right = width
	box.border_width_bottom = width
	box.border_color = border
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	return box

static func _add_corner_stamp(panel: Control, text: String, tone: Color) -> void:
	if panel == null or panel.has_node("RoomStamp"):
		return
	var stamp := Label.new()
	stamp.name = "RoomStamp"
	stamp.text = text
	stamp.add_theme_font_size_override("font_size", 11)
	stamp.add_theme_color_override("font_color", IVORY)
	stamp.add_theme_color_override("font_outline_color", INK)
	stamp.add_theme_constant_override("outline_size", 3)
	stamp.position = Vector2(24, 16)
	stamp.modulate = tone
	stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(stamp)

static func _add_hud_label(layer: CanvasLayer, node_name: String, text: String, position: Vector2, tone: Color) -> void:
	if layer.has_node(node_name):
		return
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", IVORY)
	label.add_theme_color_override("font_outline_color", tone.darkened(0.5))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(label)
