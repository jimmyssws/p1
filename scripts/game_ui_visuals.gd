class_name GameUIVisuals
extends RefCounted

# Shared presentation layer for the match lobby and the in-game HUD.
# It deliberately changes only theme overrides and optional decoration nodes:
# gameplay node paths, signals and scene ownership remain untouched.

const INK := Color("fff7e8")
const PAPER := Color("fff0c9")
const NIGHT := Color("17243b")
const NAVY := Color("0d1729")
const BLUE := Color("2d83d6")
const BLUE_DARK := Color("18518f")
const GOLD := Color("f3bd35")
const GOLD_DARK := Color("b87016")
const RED := Color("d9504f")
const RED_DARK := Color("8d2f39")
const GREEN := Color("43ae67")
const GREEN_DARK := Color("23703f")
const SLATE := Color("31435b")
const OUTLINE := Color("172335")

static func apply_lobby(canvas: CanvasLayer) -> void:
	var center := canvas.get_node_or_null("LobbyCenter") as CenterContainer
	if center == null:
		center = canvas.get_child(0) as CenterContainer
	if center == null:
		return
	var panel := center.get_child(0) as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _panel_box(BLUE, Color("1d3151"), 18, 22))
		panel.custom_minimum_size = Vector2(640, 470)
	var labels := _all_labels(canvas)
	for label in labels:
		label.add_theme_color_override("font_color", INK)
	for button in _all_buttons(canvas):
		_apply_button(button, _button_tone(button.text))
	var title := _first_label_with_text(canvas, "MİTİNG")
	if title:
		title.text = "MİTİNG MEYDANI / HAZIRLIK ODASI"
		title.add_theme_font_size_override("font_size", 24)
		title.add_theme_color_override("font_color", GOLD)
	_add_corner_stamp(panel, "CANLI ODA", RED)

static func apply_match_hud(root: Node) -> void:
	var header := root.get_node_or_null("TopBarHUD/TopHeader") as PanelContainer
	if header:
		header.add_theme_stylebox_override("panel", _panel_box(GOLD, Color("1a2d4a"), 12, 12))
		header.custom_minimum_size.y = 58
	var timer := root.find_child("TimerLabel", true, false) as Label
	if timer:
		timer.add_theme_color_override("font_color", GOLD)
		timer.add_theme_font_size_override("font_size", 20)
	var role_badge := root.get_node_or_null("TopBarHUD/TopHeader/Margin/HBox/RoleBadge") as PanelContainer
	if role_badge:
		role_badge.add_theme_stylebox_override("panel", _panel_box(BLUE, BLUE_DARK, 9, 0))
	var vote_bar := root.find_child("VoteProgressBar", true, false) as ProgressBar
	if vote_bar:
		vote_bar.add_theme_stylebox_override("background", _flat_box(RED_DARK, RED, 7, 1))
		vote_bar.add_theme_stylebox_override("fill", _flat_box(BLUE, Color("89d6ff"), 7, 1))
	var top := root.get_node_or_null("TopBarHUD") as CanvasLayer
	if top:
		_add_hud_label(top, "BroadcastTag", "  MİTİNG TV  /  CANLI  ", Vector2(28, 18), RED)

static func apply_player_hud(player: Node) -> void:
	var hud := player.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		return
	for path in ["WeaponPanel", "SusMeterPanel", "CCTVPanel", "MissionPanel"]:
		var panel := hud.get_node_or_null(path) as Control
		if panel:
			panel.add_theme_stylebox_override("panel", _panel_box(GOLD, Color("1c2e48"), 10, 10))
	var weapon := hud.get_node_or_null("WeaponPanel") as PanelContainer
	if weapon:
		weapon.custom_minimum_size = Vector2(420, 124)
		var category := weapon.get_node_or_null("Margin/VBox/CategoryLabel") as Label
		if category:
			category.add_theme_color_override("font_color", GOLD)
			category.add_theme_font_size_override("font_size", 13)
		for slot_name in ["Slot1", "Slot2", "Slot3", "Slot4"]:
			var slot := weapon.get_node_or_null("Margin/VBox/SlotRow/" + slot_name) as PanelContainer
			if slot:
				slot.add_theme_stylebox_override("panel", _flat_box(Color("263c5a"), Color("688cb4"), 8, 2))
	var action := hud.get_node_or_null("ActionPrompt") as Label
	if action:
		action.add_theme_color_override("font_color", PAPER)
		action.add_theme_font_size_override("font_size", 18)
		action.add_theme_constant_override("outline_size", 8)
		action.add_theme_color_override("font_outline_color", OUTLINE)
	var mission := hud.get_node_or_null("MissionPanel/MissionLabel") as Label
	if mission:
		mission.add_theme_color_override("font_color", INK)
		mission.add_theme_font_size_override("font_size", 15)
	var pause_card := hud.get_node_or_null("PausePanel/CenterBox/Card") as PanelContainer
	if pause_card:
		pause_card.add_theme_stylebox_override("panel", _panel_box(GOLD, Color("1d2f4c"), 16, 18))
	for path in ["PausePanel/CenterBox/Card/VBox/ResumeButton", "PausePanel/CenterBox/Card/VBox/QuitButton", "SummaryPanel/CenterBox/Panel/VBox/QuitButton"]:
		var button := hud.get_node_or_null(path) as Button
		if button:
			_apply_button(button, GREEN if "Resume" in path else RED)

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
		return GREEN
	if "MENÜ" in text or "ÇIK" in text or "DEĞİL" in text:
		return RED
	return GOLD

static func _apply_button(button: Button, tone: Color) -> void:
	var dark := tone.darkened(0.42)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", _flat_box(dark, tone, 10, 3))
	button.add_theme_stylebox_override("hover", _flat_box(tone.darkened(0.22), PAPER, 10, 5))
	button.add_theme_stylebox_override("pressed", _flat_box(dark.darkened(0.15), tone.darkened(0.12), 10, 1))
	button.add_theme_stylebox_override("focus", _flat_box(dark, PAPER, 10, 4))

static func _panel_box(accent: Color, fill: Color, radius: int, shadow: int) -> StyleBoxFlat:
	var box := _flat_box(fill, accent, radius, 2)
	box.shadow_color = Color(0.02, 0.04, 0.08, 0.7)
	box.shadow_size = shadow
	box.shadow_offset = Vector2(0, 6)
	box.content_margin_left = 18.0
	box.content_margin_top = 14.0
	box.content_margin_right = 18.0
	box.content_margin_bottom = 14.0
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
	stamp.add_theme_color_override("font_color", INK)
	stamp.add_theme_color_override("font_outline_color", OUTLINE)
	stamp.add_theme_constant_override("outline_size", 4)
	stamp.position = Vector2(22, 16)
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
	label.add_theme_color_override("font_color", INK)
	label.add_theme_color_override("font_outline_color", tone.darkened(0.45))
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(label)
