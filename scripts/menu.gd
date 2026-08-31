extends Control

@onready var host_btn = $CenterBox/MainPanel/VBox/Buttons/HostButton
@onready var solo_btn = $CenterBox/MainPanel/VBox/Buttons/SoloButton if has_node("CenterBox/MainPanel/VBox/Buttons/SoloButton") else null
@onready var join_toggle_btn = $CenterBox/MainPanel/VBox/Buttons/JoinToggleButton
@onready var join_section = $CenterBox/MainPanel/VBox/Buttons/JoinSection
@onready var ip_input = $CenterBox/MainPanel/VBox/Buttons/JoinSection/IpInput
@onready var join_confirm_btn = $CenterBox/MainPanel/VBox/Buttons/JoinSection/JoinConfirmButton
@onready var settings_btn = $CenterBox/MainPanel/VBox/Buttons/SettingsButton
@onready var quit_btn = $CenterBox/MainPanel/VBox/Buttons/QuitButton
@onready var quick_btn = $CenterBox/MainPanel/VBox/Buttons/ServerQuickButton
@onready var settings_panel = $SettingsPanel
@onready var close_settings_btn = $SettingsPanel/VBox/CloseButton
@onready var volume_slider = $SettingsPanel/VBox/VolRow/VolumeSlider
@onready var vol_label = $SettingsPanel/VBox/VolRow/VolValueLabel
@onready var sens_slider = $SettingsPanel/VBox/SensRow/SensSlider if has_node("SettingsPanel/VBox/SensRow/SensSlider") else null
@onready var sens_label = $SettingsPanel/VBox/SensRow/SensValLabel if has_node("SettingsPanel/VBox/SensRow/SensValLabel") else null
@onready var weather_option = $SettingsPanel/VBox/WeatherRow/WeatherOption if has_node("SettingsPanel/VBox/WeatherRow/WeatherOption") else null

const MAIN_SERVER_IP = "100.68.81.79"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_setup_button_sounds()
	if solo_btn:
		solo_btn.pressed.connect(_on_solo_pressed)
	host_btn.pressed.connect(_on_host_pressed)
	join_toggle_btn.pressed.connect(_on_join_toggle_pressed)
	join_confirm_btn.pressed.connect(_on_join_confirm_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	close_settings_btn.pressed.connect(_on_close_settings_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	if quick_btn:
		quick_btn.pressed.connect(_on_quick_server_pressed)
	if sens_slider:
		sens_slider.value_changed.connect(_on_sens_changed)
	if weather_option:
		weather_option.item_selected.connect(_on_weather_selected)
	_load_settings()

func _setup_button_sounds():
	var btns = [solo_btn, host_btn, join_toggle_btn, join_confirm_btn, settings_btn, quit_btn, quick_btn, close_settings_btn]
	for btn in btns:
		if btn and is_instance_valid(btn):
			btn.mouse_entered.connect(func(): _play_ui_sound("res://sounds/rollover1.ogg", -6.0))
			btn.pressed.connect(func(): _play_ui_sound("res://sounds/mouseclick1.ogg", 0.0))

func _play_ui_sound(path: String, vol: float = 0.0):
	var sfx = AudioStreamPlayer.new()
	var st = load(path) as AudioStream
	if st:
		sfx.stream = st
		sfx.volume_db = vol
		sfx.bus = "Master"
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(func(): sfx.queue_free())

func _on_solo_pressed():
	if get_node_or_null("/root/Global"):
		Global.network_mode = "SOLO"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quick_server_pressed():
	if get_node_or_null("/root/Global"):
		Global.server_ip = MAIN_SERVER_IP
		Global.network_mode = "JOIN"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_host_pressed():
	if get_node_or_null("/root/Global"):
		Global.network_mode = "HOST"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_join_toggle_pressed():
	join_section.visible = not join_section.visible
	if join_section.visible:
		ip_input.grab_focus()

func _on_join_confirm_pressed():
	var ip = ip_input.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	if get_node_or_null("/root/Global"):
		Global.server_ip = ip
		Global.network_mode = "JOIN"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed():
	settings_panel.show()

func _on_close_settings_pressed():
	settings_panel.hide()
	_save_settings()

func _on_volume_changed(val: float):
	vol_label.text = "%d%%" % int(val)
	var db = linear_to_db(val / 100.0) if val > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_sens_changed(val: float):
	if sens_label:
		sens_label.text = "%.2fx" % val

func _on_weather_selected(idx: int):
	var mode = "SUNNY" if idx == 0 else "RAINY"
	if get_node_or_null("/root/Global"):
		Global.weather_type = mode

func _on_quit_pressed():
	get_tree().quit()

func _load_settings():
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var vol = cfg.get_value("audio", "master_volume", 85.0)
		volume_slider.value = vol
		_on_volume_changed(vol)
		if sens_slider:
			var sens = cfg.get_value("controls", "mouse_sensitivity", 1.0)
			sens_slider.value = sens
			_on_sens_changed(sens)
		var weather = cfg.get_value("graphics", "weather_type", "SUNNY")
		if get_node_or_null("/root/Global"):
			Global.weather_type = weather
		if weather_option:
			weather_option.selected = 0 if weather == "SUNNY" else 1

func _save_settings():
	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("audio", "master_volume", volume_slider.value)
	if sens_slider:
		cfg.set_value("controls", "mouse_sensitivity", sens_slider.value)
	if get_node_or_null("/root/Global"):
		cfg.set_value("graphics", "weather_type", Global.weather_type)
	cfg.save("user://settings.cfg")