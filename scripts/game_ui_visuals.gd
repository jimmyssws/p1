class_name GameUIVisuals
extends RefCounted

# Tüm oyun içi HUD ve pause panel görsel katmanı.
# Node yolu veya gameplay state'i değiştirmez.

const WHITE  := Color(1.0, 1.0, 1.0, 1.0)
const OFF    := Color(0.75, 0.75, 0.75, 1.0)
const DIM    := Color(0.45, 0.45, 0.45, 1.0)
const GOLD   := Color(0.90, 0.68, 0.22, 1.0)
const RED    := Color(0.82, 0.20, 0.18, 1.0)
const GREEN  := Color(0.25, 0.78, 0.35, 1.0)
const BLUE   := Color(0.20, 0.60, 0.92, 1.0)
const INK    := Color(0.0,  0.0,  0.0,  1.0)

# ── Lobi ─────────────────────────────────────────────────────────────────────

static func apply_lobby(canvas: CanvasLayer) -> void:
	var center := canvas.get_node_or_null("LobbyCenter") as CenterContainer
	if center == null: return
	center.anchor_left   = 0.55
	center.anchor_top    = 0.10
	center.anchor_right  = 0.97
	center.anchor_bottom = 0.90
	var panel := center.get_child(0) as PanelContainer
	if panel:
		panel.add_theme_stylebox_override("panel", _dark_panel())
		panel.custom_minimum_size = Vector2(0, 460)
	for label in _all_labels(canvas):
		label.add_theme_color_override("font_color", WHITE)
		label.add_theme_color_override("font_outline_color", INK)
		label.add_theme_constant_override("outline_size", 2)
	for button in _all_buttons(canvas):
		_style_button(button, GOLD)
	var title := _first_label_with(canvas, "MİTİNG")
	if title:
		title.text = "LOBI"
		title.add_theme_font_size_override("font_size", 26)
		title.add_theme_color_override("font_color", GOLD)

# ── Maç HUD ──────────────────────────────────────────────────────────────────

static func apply_match_hud(root: Node) -> void:
	var header := root.get_node_or_null("TopBarHUD/TopHeader") as PanelContainer
	if header:
		header.add_theme_stylebox_override("panel", _topbar_box())
		header.custom_minimum_size.y = 48
	var timer := root.find_child("TimerLabel", true, false) as Label
	if timer:
		timer.add_theme_color_override("font_color", WHITE)
		timer.add_theme_color_override("font_outline_color", INK)
		timer.add_theme_constant_override("outline_size", 3)
		timer.add_theme_font_size_override("font_size", 20)

# ── Oyuncu HUD ───────────────────────────────────────────────────────────────

static func apply_player_hud(player: Node) -> void:
	var hud := player.get_node_or_null("HUD") as CanvasLayer
	if hud == null: return

	# WeaponPanel — slot'lar
	_style_weapon_panel(hud)

	# ActionPrompt — iyi okunuyor
	var action := hud.get_node_or_null("ActionPrompt") as Label
	if action:
		action.add_theme_font_size_override("font_size", 17)
		action.add_theme_color_override("font_color", WHITE)
		action.add_theme_color_override("font_outline_color", INK)
		action.add_theme_constant_override("outline_size", 6)

	# MissionPanel
	var mission := hud.get_node_or_null("MissionPanel") as Control
	if mission:
		mission.add_theme_stylebox_override("panel", _mission_box())
	var ml := hud.get_node_or_null("MissionPanel/MissionLabel") as Label
	if ml:
		ml.add_theme_color_override("font_color", WHITE)
		ml.add_theme_color_override("font_outline_color", INK)
		ml.add_theme_constant_override("outline_size", 4)
		ml.add_theme_font_size_override("font_size", 14)

	# SusMeterPanel
	var sus_panel := hud.get_node_or_null("SusMeterPanel") as Control
	if sus_panel:
		sus_panel.add_theme_stylebox_override("panel", _hud_panel())
	var sus_bar := hud.get_node_or_null("SusMeterPanel/VBox/SusProgressBar") as ProgressBar
	if sus_bar:
		sus_bar.add_theme_stylebox_override("background", _bar_bg())
		sus_bar.add_theme_stylebox_override("fill", _bar_fill(RED))

	# Pause & Summary
	_style_pause(hud)
	_style_summary(hud)

# ── WeaponPanel ───────────────────────────────────────────────────────────────

static func _style_weapon_panel(hud: CanvasLayer) -> void:
	var wp := hud.get_node_or_null("WeaponPanel") as PanelContainer
	if wp == null: return
	wp.add_theme_stylebox_override("panel", _hud_panel())
	wp.custom_minimum_size = Vector2(380, 100)
	# CategoryLabel — başlık
	var cat := wp.get_node_or_null("Margin/VBox/CategoryLabel") as Label
	if cat:
		cat.add_theme_font_size_override("font_size", 11)
		cat.add_theme_color_override("font_color", Color(GOLD, 0.85))
		cat.add_theme_color_override("font_outline_color", INK)
		cat.add_theme_constant_override("outline_size", 3)
	# Slot'lar — arka plan kaldır, sade görünsün
	for slot_name in ["Slot1", "Slot2", "Slot3", "Slot4"]:
		var slot := wp.get_node_or_null("Margin/VBox/SlotRow/" + slot_name) as PanelContainer
		if slot:
			slot.add_theme_stylebox_override("panel", _slot_box())
		var lbl := wp.get_node_or_null("Margin/VBox/SlotRow/" + slot_name + "/Label") as Label
		if lbl:
			lbl.add_theme_font_size_override("font_size", 13)
			lbl.add_theme_color_override("font_color", WHITE)
			lbl.add_theme_color_override("font_outline_color", INK)
			lbl.add_theme_constant_override("outline_size", 3)

# ── Pause Panel ───────────────────────────────────────────────────────────────

static func _style_pause(hud: CanvasLayer) -> void:
	# Arka plan overlay
	var overlay := hud.get_node_or_null("PausePanel") as ColorRect
	if overlay:
		overlay.color = Color(0.0, 0.0, 0.0, 0.72)

	var card := hud.get_node_or_null("PausePanel/CenterBox/Card") as PanelContainer
	if card:
		card.add_theme_stylebox_override("panel", _pause_card_box())
		card.custom_minimum_size = Vector2(380, 0)

	# Başlık
	var title := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/PauseTitle") as Label
	if title:
		title.text = "DURAKLATILDI"
		title.add_theme_font_size_override("font_size", 22)
		title.add_theme_color_override("font_color", WHITE)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Kontroller etiketi
	var ctrl := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/ControlsLabel") as Label
	if ctrl:
		ctrl.add_theme_font_size_override("font_size", 12)
		ctrl.add_theme_color_override("font_color", Color(0.70, 0.70, 0.70, 1.0))
		ctrl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		ctrl.text = "WASD  Hareket    Boşluk  Zıpla    E  Etkileşim\n1/2/3/4  Yetenek    F1/F2/F3  Rol Değiştir (test)"

	# Dron etiketi
	var ctrl2 := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/ControlsLabel2") as Label
	if ctrl2:
		ctrl2.add_theme_font_size_override("font_size", 11)
		ctrl2.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55, 1.0))
		ctrl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Hassasiyet başlığı
	var stitle := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/SensContainer/SensHeader/SensTitle") as Label
	if stitle:
		stitle.add_theme_color_override("font_color", OFF)
		stitle.add_theme_font_size_override("font_size", 13)
		stitle.text = "Fare Hassasiyeti"

	var sval := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/SensContainer/SensHeader/SensValLabel") as Label
	if sval:
		sval.add_theme_color_override("font_color", GOLD)
		sval.add_theme_font_size_override("font_size", 13)

	# HSep
	var sep := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/HSep") as HSeparator
	if sep:
		sep.add_theme_color_override("color", Color(1.0, 1.0, 1.0, 0.10))

	# Butonlar
	var resume := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/ResumeButton") as Button
	if resume:
		resume.text = "Devam Et"
		_style_button(resume, Color(0.25, 0.78, 0.35, 1.0))

	var quit := hud.get_node_or_null("PausePanel/CenterBox/Card/VBox/QuitButton") as Button
	if quit:
		quit.text = "Ana Menüye Dön"
		_style_button(quit, Color(0.60, 0.60, 0.60, 1.0))

# ── Summary Panel ──────────────────────────────────────────────────────────────

static func _style_summary(hud: CanvasLayer) -> void:
	var overlay := hud.get_node_or_null("SummaryPanel") as ColorRect
	if overlay:
		overlay.color = Color(0.0, 0.0, 0.0, 0.75)
	var card := hud.get_node_or_null("SummaryPanel/CenterBox/Panel") as PanelContainer
	if card:
		card.add_theme_stylebox_override("panel", _pause_card_box())
	for path in ["SummaryPanel/CenterBox/Panel/VBox/QuitButton"]:
		var btn := hud.get_node_or_null(path) as Button
		if btn:
			_style_button(btn, GOLD)

# ── StyleBox fabrikaları ──────────────────────────────────────────────────────

static func _dark_panel() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.04, 0.045, 0.055, 0.90)
	b.border_width_left = 2
	b.border_color = Color(GOLD, 0.40)
	b.shadow_color = Color(0.0, 0.0, 0.0, 0.85)
	b.shadow_size = 24
	b.content_margin_left   = 22.0
	b.content_margin_top    = 18.0
	b.content_margin_right  = 22.0
	b.content_margin_bottom = 18.0
	return b

static func _topbar_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.0, 0.0, 0.0, 0.68)
	b.border_width_bottom = 1
	b.border_color = Color(1.0, 1.0, 1.0, 0.10)
	b.content_margin_left   = 14.0
	b.content_margin_top    = 6.0
	b.content_margin_right  = 14.0
	b.content_margin_bottom = 6.0
	return b

static func _hud_panel() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.0, 0.0, 0.0, 0.62)
	b.border_width_left = 2
	b.border_color = Color(1.0, 1.0, 1.0, 0.10)
	b.corner_radius_top_left     = 4
	b.corner_radius_top_right    = 4
	b.corner_radius_bottom_left  = 4
	b.corner_radius_bottom_right = 4
	b.content_margin_left   = 12.0
	b.content_margin_top    = 8.0
	b.content_margin_right  = 12.0
	b.content_margin_bottom = 8.0
	return b

static func _slot_box() -> StyleBoxFlat:
	# Slot arka planı: neredeyse şeffaf, küçük alt çizgi
	var b := StyleBoxFlat.new()
	b.bg_color = Color(1.0, 1.0, 1.0, 0.04)
	b.border_width_bottom = 1
	b.border_color = Color(1.0, 1.0, 1.0, 0.12)
	b.content_margin_left   = 8.0
	b.content_margin_top    = 4.0
	b.content_margin_right  = 8.0
	b.content_margin_bottom = 4.0
	return b

static func _mission_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.0, 0.0, 0.0, 0.55)
	b.content_margin_left   = 10.0
	b.content_margin_top    = 6.0
	b.content_margin_right  = 10.0
	b.content_margin_bottom = 6.0
	return b

static func _pause_card_box() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.07, 0.07, 0.08, 0.96)
	b.border_width_left   = 2
	b.border_width_top    = 0
	b.border_width_right  = 0
	b.border_width_bottom = 0
	b.border_color = Color(GOLD, 0.50)
	b.shadow_color = Color(0.0, 0.0, 0.0, 0.90)
	b.shadow_size  = 32
	b.shadow_offset = Vector2(0.0, 8.0)
	b.content_margin_left   = 36.0
	b.content_margin_top    = 32.0
	b.content_margin_right  = 36.0
	b.content_margin_bottom = 32.0
	return b

static func _bar_bg() -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = Color(0.15, 0.15, 0.15, 0.80)
	return b

static func _bar_fill(color: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	return b

# ── Buton stili ───────────────────────────────────────────────────────────────

static func _style_button(btn: Button, accent: Color) -> void:
	btn.custom_minimum_size.y = 42.0
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80, 1.0))
	btn.add_theme_color_override("font_hover_color", WHITE)
	# Normal: şeffaf
	var bn := StyleBoxFlat.new()
	bn.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	bn.draw_center = false
	bn.border_width_bottom = 1
	bn.border_color = Color(1.0, 1.0, 1.0, 0.08)
	bn.content_margin_left   = 4.0
	bn.content_margin_top    = 6.0
	bn.content_margin_right  = 4.0
	bn.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", bn)
	# Hover: sol accent çizgisi
	var bh := StyleBoxFlat.new()
	bh.bg_color = Color(accent.r, accent.g, accent.b, 0.10)
	bh.border_width_left = 3
	bh.border_color = Color(accent, 0.90)
	bh.content_margin_left   = 12.0
	bh.content_margin_top    = 6.0
	bh.content_margin_right  = 4.0
	bh.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("hover", bh)
	# Pressed
	var bp := StyleBoxFlat.new()
	bp.bg_color = Color(accent.r, accent.g, accent.b, 0.20)
	bp.border_width_left = 3
	bp.border_color = Color(accent, 1.0)
	bp.content_margin_left   = 12.0
	bp.content_margin_top    = 6.0
	bp.content_margin_right  = 4.0
	bp.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("pressed", bp)
	btn.add_theme_stylebox_override("focus", bn)

# ── Yardımcılar ───────────────────────────────────────────────────────────────

static func _all_buttons(root: Node) -> Array[Button]:
	var r : Array[Button] = []
	for n in root.find_children("*", "Button", true, false):
		r.append(n as Button)
	return r

static func _all_labels(root: Node) -> Array[Label]:
	var r : Array[Label] = []
	for n in root.find_children("*", "Label", true, false):
		r.append(n as Label)
	return r

static func _first_label_with(root: Node, fragment: String) -> Label:
	for l in _all_labels(root):
		if fragment in l.text:
			return l
	return null
