extends Control

@onready var bg = $Background
@onready var title_label = $CenterBox/VBox/TitleLabel
@onready var subtitle_label = $CenterBox/VBox/SubtitleLabel
@onready var host_btn = $CenterBox/VBox/Buttons/HostButton
@onready var server_quick_btn = $CenterBox/VBox/Buttons/ServerQuickButton if has_node("CenterBox/VBox/Buttons/ServerQuickButton") else null
@onready var join_section = $CenterBox/VBox/Buttons/JoinSection
@onready var ip_input = $CenterBox/VBox/Buttons/JoinSection/IpInput
@onready var join_confirm_btn = $CenterBox/VBox/Buttons/JoinSection/JoinConfirmButton
@onready var join_toggle_btn = $CenterBox/VBox/Buttons/JoinToggleButton
@onready var settings_btn = $CenterBox/VBox/Buttons/SettingsButton
@onready var quit_btn = $CenterBox/VBox/Buttons/QuitButton

# Settings Modal
@onready var settings_panel = $SettingsPanel
@onready var settings_close_btn = $SettingsPanel/VBox/CloseButton
@onready var volume_slider = $SettingsPanel/VBox/VolRow/VolumeSlider if has_node("SettingsPanel/VBox/VolRow/VolumeSlider") else null
@onready var vol_value_label = $SettingsPanel/VBox/VolRow/VolValueLabel if has_node("SettingsPanel/VBox/VolRow/VolValueLabel") else null

var join_open: bool = false

func _ready():
	if join_section: join_section.hide()
	if settings_panel: settings_panel.hide()

	_apply_theme()

	if host_btn: host_btn.pressed.connect(_on_host)
	if server_quick_btn: server_quick_btn.pressed.connect(_on_server_quick_join)
	if join_toggle_btn: join_toggle_btn.pressed.connect(_on_join_toggle)
	if join_confirm_btn: join_confirm_btn.pressed.connect(_on_join_confirm)
	if ip_input: ip_input.text_submitted.connect(func(_t): _on_join_confirm())
	if settings_btn: settings_btn.pressed.connect(_on_settings_toggle)
	if settings_close_btn: settings_close_btn.pressed.connect(_on_settings_toggle)
	if quit_btn: quit_btn.pressed.connect(get_tree().quit)

	if volume_slider:
		volume_slider.value = Global.master_volume * 100.0
		if vol_value_label: vol_value_label.text = "%d%%" % int(volume_slider.value)
		volume_slider.value_changed.connect(_on_volume_changed)

func _on_volume_changed(val: float):
	Global.set_volume(val / 100.0)
	if vol_value_label:
		vol_value_label.text = "%d%%" % int(val)

func _apply_theme():
	if title_label:
		title_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.1))
		title_label.add_theme_font_size_override("font_size", 52)
	if subtitle_label:
		subtitle_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.95))
		subtitle_label.add_theme_font_size_override("font_size", 16)

func _on_host():
	Global.network_mode = "HOST"
	get_tree().change_scene_to_file("res://main.tscn")

func _on_server_quick_join():
	Global.network_mode = "JOIN"
	Global.join_ip = "100.68.81.79"
	get_tree().change_scene_to_file("res://main.tscn")

func _on_join_toggle():
	join_open = not join_open
	if join_open:
		if join_section: join_section.show()
		if ip_input: ip_input.grab_focus()
		if join_toggle_btn: join_toggle_btn.text = "← Geri"
	else:
		if join_section: join_section.hide()
		if join_toggle_btn: join_toggle_btn.text = "🎮 IP ile Katıl"

func _on_join_confirm():
	var ip = "127.0.0.1"
	if ip_input and ip_input.text.strip_edges() != "":
		ip = ip_input.text.strip_edges()
	Global.network_mode = "JOIN"
	Global.join_ip = ip
	get_tree().change_scene_to_file("res://main.tscn")

func _on_settings_toggle():
	if settings_panel:
		settings_panel.visible = not settings_panel.visible

func _input(event):
	if event.is_action_pressed("ui_cancel") and settings_panel and settings_panel.visible:
		settings_panel.hide()
