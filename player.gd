extends CharacterBody3D

const SPEED = 3.5
const JUMP_VELOCITY = 6.2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var progress_bar = $HUD/ProgressBar
@onready var role_panel = $HUD/RoleCardPanel if has_node("HUD/RoleCardPanel") else null
@onready var role_title = $HUD/RoleCardPanel/RoleTitle if has_node("HUD/RoleCardPanel/RoleTitle") else null
@onready var role_desc = $HUD/RoleCardPanel/RoleDesc if has_node("HUD/RoleCardPanel/RoleDesc") else null
@onready var action_prompt = $HUD/ActionPrompt if has_node("HUD/ActionPrompt") else null
@onready var weapon_panel = $HUD/WeaponPanel if has_node("HUD/WeaponPanel") else null
@onready var slot_category = $HUD/WeaponPanel/Margin/VBox/CategoryLabel if has_node("HUD/WeaponPanel/Margin/VBox/CategoryLabel") else null
@onready var slot1_panel = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot1 if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot1") else null
@onready var slot1_label = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot1/Label if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot1/Label") else null
@onready var slot2_panel = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot2 if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot2") else null
@onready var slot2_label = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot2/Label if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot2/Label") else null
@onready var slot3_panel = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot3 if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot3") else null
@onready var slot3_label = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot3/Label if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot3/Label") else null
@onready var slot4_panel = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot4 if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot4") else null
@onready var slot4_label = $HUD/WeaponPanel/Margin/VBox/SlotRow/Slot4/Label if has_node("HUD/WeaponPanel/Margin/VBox/SlotRow/Slot4/Label") else null
@onready var scan_panel = $HUD/ScanResultPanel if has_node("HUD/ScanResultPanel") else null
@onready var scan_title = $HUD/ScanResultPanel/ScanTitle if has_node("HUD/ScanResultPanel/ScanTitle") else null
@onready var scan_items = $HUD/ScanResultPanel/ScanItems if has_node("HUD/ScanResultPanel/ScanItems") else null
@onready var char_model = $CharacterModel if has_node("CharacterModel") else null
@onready var anim_player = $CharacterModel/AnimMesh/AnimationPlayer if has_node("CharacterModel/AnimMesh/AnimationPlayer") else null
@onready var body_mesh = $CharacterModel/Body if has_node("CharacterModel/Body") else null
@onready var tie_mesh = $CharacterModel/Tie if has_node("CharacterModel/Tie") else null
@onready var sunglasses_mesh = $CharacterModel/Sunglasses if has_node("CharacterModel/Sunglasses") else null

# 🖐️ Viewmodels (Elde Görünen 3D Silahlar)
@onready var hand_anchor = $Camera3D/HandAnchor if has_node("Camera3D/HandAnchor") else null
# 🖐️ FPS Eli & Kolu (Viewmodel Kolu)
@onready var fps_arm = $Camera3D/HandAnchor/FPSArm if has_node("Camera3D/HandAnchor/FPSArm") else null
@onready var fps_sleeve = $Camera3D/HandAnchor/FPSArm/Forearm if has_node("Camera3D/HandAnchor/FPSArm/Forearm") else null
@onready var fps_hand = $Camera3D/HandAnchor/FPSArm/Hand if has_node("Camera3D/HandAnchor/FPSArm/Hand") else null
@onready var vm_drone_remote = $Camera3D/HandAnchor/DroneRemoteModel if has_node("Camera3D/HandAnchor/DroneRemoteModel") else null

var _hand_def_pos: Vector3 = Vector3(0.32, -0.26, -0.48)
var _hand_def_rot: Vector3 = Vector3.ZERO
var _bob_timer: float = 0.0
var _mouse_sway: Vector2 = Vector2.ZERO

@onready var vm_knife = $Camera3D/HandAnchor/KnifeModel if has_node("Camera3D/HandAnchor/KnifeModel") else null
@onready var vm_pistol = $Camera3D/HandAnchor/PistolModel if has_node("Camera3D/HandAnchor/PistolModel") else null
@onready var vm_taser = $Camera3D/HandAnchor/TaserModel if has_node("Camera3D/HandAnchor/TaserModel") else null
@onready var vm_detector = $Camera3D/HandAnchor/DetectorModel if has_node("Camera3D/HandAnchor/DetectorModel") else null
@onready var vm_megaphone = $Camera3D/HandAnchor/MegaphoneModel if has_node("Camera3D/HandAnchor/MegaphoneModel") else null

# 🎯 Mission HUD (sadece Başkan için)
@onready var mission_panel = $HUD/MissionPanel if has_node("HUD/MissionPanel") else null
@onready var mission_label = $HUD/MissionPanel/MissionLabel if has_node("HUD/MissionPanel/MissionLabel") else null

# 🎖️ Köşe Rol Göstergesi
@onready var role_indicator = $HUD/RoleIndicator if has_node("HUD/RoleIndicator") else null

# ⏸️ Pause Menüsü
@onready var pause_panel = $HUD/PausePanel if has_node("HUD/PausePanel") else null
@onready var pause_resume_btn = $HUD/PausePanel/VBox/ResumeButton if has_node("HUD/PausePanel/VBox/ResumeButton") else null
@onready var pause_quit_btn = $HUD/PausePanel/VBox/QuitButton if has_node("HUD/PausePanel/VBox/QuitButton") else null

var is_paused: bool = false
# 🖱️ Fare Hassasiyeti Ayarı
var base_sensitivity: float = 0.0035
var mouse_sensitivity: float = 1.0
@onready var sens_slider = $HUD/PausePanel/VBox/SensContainer/SensSlider if has_node("HUD/PausePanel/VBox/SensContainer/SensSlider") else null
@onready var sens_val_label = $HUD/PausePanel/VBox/SensContainer/SensHeader/SensValLabel if has_node("HUD/PausePanel/VBox/SensContainer/SensHeader/SensValLabel") else null


# 💼 Çelik Çanta Kalkanı (Başkan)
var has_briefcase_shield: bool = true
var anthem_cooldown: float = 0.0
@onready var vm_briefcase = $Camera3D/HandAnchor/BriefcaseModel if has_node("Camera3D/HandAnchor/BriefcaseModel") else null

# 🚁 Drone Sistemi (Koruma)
var drone_anchor: Node3D = null
var drone_camera: Camera3D = null
var drone_mesh: MeshInstance3D = null
var drone_mode: bool = false
var drone_battery: float = 45.0
const DRONE_BATTERY_MAX = 45.0
const DRONE_SPEED_H = 10.0
const DRONE_SPEED_V = 5.0

# 🗺️ Minimap
@onready var minimap_ctrl = $HUD/Minimap if has_node("HUD/Minimap") else null

# 📊 Özet
@onready var summary_panel = $HUD/SummaryPanel if has_node("HUD/SummaryPanel") else null
@onready var summary_winner = $HUD/SummaryPanel/VBox/WinnerLabel if has_node("HUD/SummaryPanel/VBox/WinnerLabel") else null
@onready var summary_role   = $HUD/SummaryPanel/VBox/RoleLabel if has_node("HUD/SummaryPanel/VBox/RoleLabel") else null
@onready var summary_time   = $HUD/SummaryPanel/VBox/TimeLabel if has_node("HUD/SummaryPanel/VBox/TimeLabel") else null
@onready var summary_quit   = $HUD/SummaryPanel/VBox/QuitButton if has_node("HUD/SummaryPanel/VBox/QuitButton") else null

var task_progress: float = 0.0
var speech_checkpoint: float = 0.0
var last_speech_broadcast: int = -1
var current_role: String = "GUARD" 
var guard_class: int = 1 # 1: Dedektör Uzmanı, 2: Dron Operatörü, 3: Taktik Telsiz
var radio_cooldown: float = 0.0
var tea_cooldown: float = 0.0
var disguise_cooldown: float = 0.0
var penalty_slow_timer: float = 0.0
var is_game_over: bool = false

var is_downed: bool = false
var is_mimic_pose: bool = false
var is_weapon_exposed: bool = false
@onready var third_person_weapon = $CharacterModel/HandWeapon if has_node("CharacterModel/HandWeapon") else null
var downed_timer: float = 0.0
var frisk_progress: float = 0.0


# Silah & Ekipman Değişkenleri
var selected_slot: int = 1 # 1 veya 2
var pistol_ammo: int = 1   # Suikastçının tek mermisi
var assassin_cooldown: float = 0.0

var stampede_cooldown: float = 0.0

func _execute_assassin_stampede():
	if stampede_cooldown > 0:
		_show_temp_prompt("⏳ İzdiham Dinleniyor! (%.1f sn)" % stampede_cooldown)
		return
	stampede_cooldown = 30.0
	_show_temp_prompt("🚨 İZDİHAM BAŞLATILDI! Kalabalık Turnikeleri Yarıyor!")
	get_node("/root/main").rpc("trigger_crowd_stampede", Vector3(0, 0, 15), Vector3(0, 0, -5))

var taser_cooldown: float = 0.0
var scan_cooldown: float = 0.0

# Başkan Yetenek Değişkenleri
var sprint_active: bool = false
var sprint_cooldown: float = 0.0
var megaphone_cooldown: float = 0.0

# 🏛️ 3 Aşamalı Başkan Görev Sistemi
# mission_state: 0=Kürsü, 1=Halk, 2=Basın, 3=Tümü Tamam
var mission_state: int = 0
var mission_done: Array = [false, false, false]

# Görev Zone Sınırları (harita koordinatlarına göre)
# Görev 0: TaskBox yakını → raycast ile zaten tanımlı
# Görev 1: Bariyer zone → z aralığı -24..-19, x: -16..+16
# Görev 2: Kırmızı Basın Çadırı (Tent_Press_Right) → x:20..28, z:-12..-4
const BARRIER_ZONE_Z_MIN = -24.0
const BARRIER_ZONE_Z_MAX = -18.0
const BARRIER_ZONE_X_ABS = 17.0

const PRESS_ZONE_X_MIN = 19.0
const PRESS_ZONE_X_MAX = 29.0
const PRESS_ZONE_Z_MIN = -13.0
const PRESS_ZONE_Z_MAX = -3.0

# 🔊 Ses Sistemi
var sfx_knife: AudioStreamPlayer3D = null
var sfx_gunshot: AudioStreamPlayer3D = null
var sfx_taser: AudioStreamPlayer3D = null
var sfx_scan: AudioStreamPlayer3D = null
var sfx_task_complete: AudioStreamPlayer = null
var sfx_footstep: AudioStreamPlayer = null
var sfx_heartbeat: AudioStreamPlayer = null
var sfx_hit_impact: AudioStreamPlayer = null
var sfx_clang: AudioStreamPlayer = null
var sfx_warning: AudioStreamPlayer = null
var _warning_overlay_node: ColorRect = null
var _warning_timer: float = 0.0
var _aim_check_timer: float = 0.0


# 💥 Geri Bildirim Sistemi
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0
var _camera_origin: Vector3 = Vector3.ZERO
var _hit_flash_node: ColorRect = null
var _footstep_timer: float = 0.0
var _heartbeat_active: bool = false
var _heartbeat_interval: float = 1.0
var _heartbeat_timer: float = 0.0

# Komik Sivil Eşya Havuzu
const SILLY_ITEMS = [
	"🔌 Buharlı Ütü", "💨 Saç Kurutma Makinesi", "🥤 Gazoz Kapağı", "🔑 Paslı Ev Anahtarı",
	"🥄 Çay Kaşığı", "🪥 Diş Fırçası", "📻 Eski Radyo", "👛 Boş Cüzdan", "🥔 Yarım Patates",
	"🧀 Kaşar Peyniri", "🧲 Mıknatıs", "🥫 Salça Kutusu", "🪙 5 Lira Bozukluk", "📎 Paslı Ataş",
	"🍌 Yarım Muz", "📱 Tuşlu Telefon", "🪞 Çatlak Ayna", "🔋 Biten Pil"
]

func _enter_tree():
	var id = name.to_int()
	set_multiplayer_authority(id)
	$MultiplayerSynchronizer.set_multiplayer_authority(id)

func _ready():
	add_to_group("players")
	floor_snap_length = 0.35
	floor_max_angle = 0.85
	floor_constant_speed = true
	if has_node("HUD/ProgressBar"): $HUD/ProgressBar.hide()
	if has_node("HUD/GameOverPanel"): $HUD/GameOverPanel.hide()
	if scan_panel: scan_panel.hide()
	if action_prompt: action_prompt.text = ""
	if mission_panel: mission_panel.hide()
	if pause_panel: pause_panel.hide()
	if role_indicator: role_indicator.hide()
	if summary_panel: summary_panel.hide()

	if minimap_ctrl:
		minimap_ctrl.player_ref = self

	if multiplayer.has_multiplayer_peer() and not is_multiplayer_authority():
		if hand_anchor: hand_anchor.hide()
		return
		
	if char_model:
		char_model.hide()
		
	position = Vector3(0, 3, 0)
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_setup_sounds()
	_setup_pause_menu()
	_setup_drone()
	_update_weapon_hud()

func _setup_pause_menu():
	_load_mouse_settings()
	if sens_slider:
		sens_slider.value_changed.connect(_on_sensitivity_changed)
	if pause_resume_btn:
		pause_resume_btn.pressed.connect(_toggle_pause)
	if pause_quit_btn:
		pause_quit_btn.pressed.connect(_quit_to_menu)
	if summary_quit:
		summary_quit.pressed.connect(_quit_to_menu)


func _load_mouse_settings():
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		mouse_sensitivity = cfg.get_value("controls", "mouse_sensitivity", 1.0)
	if sens_slider:
		sens_slider.value = mouse_sensitivity
	_update_sens_label(mouse_sensitivity)

func _on_sensitivity_changed(val: float):
	mouse_sensitivity = val
	_update_sens_label(val)
	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("controls", "mouse_sensitivity", val)
	cfg.save("user://settings.cfg")

func _update_sens_label(val: float):
	if sens_val_label:
		sens_val_label.text = "%.2fx (%%%d)" % [val, int(val * 100)]

func _toggle_pause():
	is_paused = not is_paused
	if is_paused:
		pause_panel.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		pause_panel.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _quit_to_menu():
	if drone_mode: _deactivate_drone()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://menu.tscn")

func _setup_drone():
	drone_anchor = Node3D.new()
	drone_anchor.name = "DroneAnchor"
	drone_anchor.top_level = true
	add_child(drone_anchor)

	drone_camera = Camera3D.new()
	drone_camera.name = "DroneCamera"
	drone_anchor.add_child(drone_camera)

	drone_mesh = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = Vector3(0.35, 0.08, 0.35)
	drone_mesh.mesh = bm
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	mat.metallic = 0.7
	drone_mesh.set_surface_override_material(0, mat)
	drone_anchor.add_child(drone_mesh)

func _activate_drone():
	if current_role != "GUARD":
		_show_temp_prompt("❌ Drone sadece Koruma rolüne özel!")
		return
	if drone_battery <= 2.0:
		_show_temp_prompt("❌ Drone bataryası bitti! Bekle...")
		return
	drone_mode = true
	if is_multiplayer_authority() and char_model: char_model.show()
	if drone_mesh: drone_mesh.show()
	drone_anchor.global_position = global_position + Vector3(0, 4, 0)
	drone_anchor.rotation = Vector3.ZERO
	drone_camera.rotation = Vector3.ZERO
	camera.clear_current()
	drone_camera.make_current()
	progress_bar.show()
	if minimap_ctrl: minimap_ctrl.show_drone = true
	_show_temp_prompt("🚁 DRONE AKTİF — WASD: Uç, Q: Alçal, E: Yüksel, [F]: Geri Dön, [C]: CCTV Sabitle")

func _deactivate_drone():
	drone_mode = false
	if is_multiplayer_authority() and char_model: char_model.hide()
	if drone_mesh: drone_mesh.hide()
	drone_camera.clear_current()
	camera.make_current()
	progress_bar.hide()
	task_progress = 0.0
	if minimap_ctrl: minimap_ctrl.show_drone = false
	_show_temp_prompt("🚁 Drone çağrıldı, sahaya dönüldü. (Batarya: %.0f sn)" % drone_battery)

func _process_drone(delta):
	drone_battery = max(0.0, drone_battery - delta)
	progress_bar.value = (drone_battery / DRONE_BATTERY_MAX) * 100.0
	if minimap_ctrl: minimap_ctrl.drone_pos = drone_anchor.global_position

	if drone_battery <= 0.0:
		_deactivate_drone()
		_show_temp_prompt("❌ DRON BATARYASI BİTTİ! Sahaya dönüldü.")
		return

	var is_boost = Input.is_key_pressed(KEY_SHIFT)
	var spd_h = DRONE_SPEED_H * (1.8 if is_boost else 1.0)
	var spd_v = DRONE_SPEED_V * (1.6 if is_boost else 1.0)

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (drone_anchor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	drone_anchor.position += direction * spd_h * delta

	# ⬆️ Yüksel: [Space] veya [E]
	if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_E):
		drone_anchor.position.y += spd_v * delta
	# ⬇️ Alçal: [Q] veya [CTRL] veya [C]
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_C):
		drone_anchor.position.y -= spd_v * delta

	drone_anchor.position.y = clamp(drone_anchor.position.y, 2.5, 38.0)

	if action_prompt:
		action_prompt.text = "🚁 DRON | [WASD] Uç | [Space/E] ⬆️ Yüksel | [Q/Ctrl] ⬇️ Alçal | [Shift] ⚡ Hız | [2/F] İptal | 🔋 %.0f sn" % drone_battery


func _setup_sounds():
	sfx_knife = AudioStreamPlayer3D.new()
	sfx_knife.stream = load("res://sounds/knife.wav")
	sfx_knife.unit_size = 6.0
	add_child(sfx_knife)

	sfx_gunshot = AudioStreamPlayer3D.new()
	sfx_gunshot.stream = load("res://sounds/gunshot.wav")
	sfx_gunshot.volume_db = 8.0
	sfx_gunshot.unit_size = 25.0
	add_child(sfx_gunshot)

	sfx_taser = AudioStreamPlayer3D.new()
	sfx_taser.stream = load("res://sounds/taser.wav")
	sfx_taser.unit_size = 10.0
	add_child(sfx_taser)

	sfx_scan = AudioStreamPlayer3D.new()
	sfx_scan.stream = load("res://sounds/scan.wav")
	sfx_scan.unit_size = 5.0
	add_child(sfx_scan)

	sfx_task_complete = AudioStreamPlayer.new()
	sfx_task_complete.stream = load("res://sounds/task_complete.wav")
	sfx_task_complete.volume_db = 3.0
	add_child(sfx_task_complete)

	sfx_footstep = AudioStreamPlayer.new()
	sfx_footstep.stream = load("res://sounds/footstep.wav")
	sfx_footstep.volume_db = -4.0
	add_child(sfx_footstep)

	sfx_heartbeat = AudioStreamPlayer.new()
	sfx_heartbeat.stream = load("res://sounds/heartbeat.wav")
	sfx_heartbeat.volume_db = -6.0
	add_child(sfx_heartbeat)

	sfx_hit_impact = AudioStreamPlayer.new()
	sfx_hit_impact.stream = load("res://sounds/hit_impact.wav")
	sfx_hit_impact.volume_db = 2.0
	add_child(sfx_hit_impact)

	sfx_clang = AudioStreamPlayer.new()
	sfx_clang.stream = load("res://sounds/metal_clang.wav")
	sfx_clang.volume_db = 4.0
	add_child(sfx_clang)

	sfx_warning = AudioStreamPlayer.new()
	sfx_warning.stream = load("res://sounds/sniper_warning.wav")
	sfx_warning.volume_db = 2.0
	add_child(sfx_warning)

	_setup_warning_overlay()
	_setup_feedback()

func _setup_warning_overlay():
	_warning_overlay_node = ColorRect.new()
	_warning_overlay_node.color = Color(1, 0.1, 0.1, 0)
	_warning_overlay_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warning_overlay_node.anchors_preset = Control.PRESET_FULL_RECT
	var hud = get_node_or_null("HUD")
	if hud:
		hud.add_child(_warning_overlay_node)
		_warning_overlay_node.hide()

func _setup_feedback():
	_hit_flash_node = ColorRect.new()
	_hit_flash_node.color = Color(1, 0, 0, 0)
	_hit_flash_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hit_flash_node.anchors_preset = Control.PRESET_FULL_RECT
	var hud = get_node_or_null("HUD")
	if hud:
		hud.add_child(_hit_flash_node)
		_hit_flash_node.z_index = 10
	_camera_origin = Vector3.ZERO

func _apply_character_role_visuals(role_name: String):
	if fps_sleeve:
		var arm_mat = StandardMaterial3D.new()
		if role_name == "PRESIDENT":
			arm_mat.albedo_color = Color(0.08, 0.18, 0.45)
			arm_mat.roughness = 0.4
		elif role_name == "GUARD":
			arm_mat.albedo_color = Color(0.04, 0.04, 0.05)
			arm_mat.roughness = 0.3
		else:
			arm_mat.albedo_color = Color(0.22, 0.24, 0.28)
			arm_mat.roughness = 0.6
		fps_sleeve.set_surface_override_material(0, arm_mat)

	var torso = get_node_or_null("CharacterModel/AnimMesh/character/root/torso")
	var leg_l = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-left")
	var leg_r = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-right")
	var arm_l = get_node_or_null("CharacterModel/AnimMesh/character/root/arm-left")
	var arm_r = get_node_or_null("CharacterModel/AnimMesh/character/root/arm-right")
	
	var shirt_mat = StandardMaterial3D.new()
	var pants_mat = StandardMaterial3D.new()
	
	if role_name == "PRESIDENT":
		# 👑 Cumhurbaşkanı: Asil Lacivert Takım Elbise & Altın Detay
		shirt_mat.albedo_color = Color(0.08, 0.18, 0.45)
		shirt_mat.roughness = 0.4
		pants_mat.albedo_color = Color(0.06, 0.14, 0.38)
		pants_mat.roughness = 0.5
	elif role_name == "GUARD":
		# 🛡️ Özel Koruma: Simsiyah Taktik Takım Elbise & Siyah Pantolon
		shirt_mat.albedo_color = Color(0.03, 0.03, 0.04)
		shirt_mat.roughness = 0.3
		pants_mat.albedo_color = Color(0.02, 0.02, 0.03)
		pants_mat.roughness = 0.4
	elif role_name == "ASSASSIN":
		# 🗡️ Suikastçı: Kalabalık Arasına Karışan Gri/Füme Sivil Kıyafet
		shirt_mat.albedo_color = Color(0.35, 0.35, 0.42)
		shirt_mat.roughness = 0.7
		pants_mat.albedo_color = Color(0.2, 0.2, 0.25)
		pants_mat.roughness = 0.8
		
	if torso: torso.set_surface_override_material(0, shirt_mat)
	if arm_l: arm_l.set_surface_override_material(0, shirt_mat)
	if arm_r: arm_r.set_surface_override_material(0, shirt_mat)
	if leg_l: leg_l.set_surface_override_material(0, pants_mat)
	if leg_r: leg_r.set_surface_override_material(0, pants_mat)

@rpc("any_peer", "call_local")
func assign_role(role_name: String, g_class: int = 0):
	current_role = role_name
	if role_name == "GUARD" and g_class > 0:
		guard_class = g_class
	
	if current_role == "PRESIDENT":
		global_position = Vector3(0, 2.8, -32.0)
		mission_state = 0
		mission_done = [false, false, false]
	elif current_role == "GUARD":
		global_position = Vector3(randf_range(-6, 6), 2.0, -18.0)
	elif current_role == "ASSASSIN":
		global_position = Vector3(randf_range(-12, 12), 2.0, randf_range(5, 20))
	
	_apply_character_role_visuals(role_name)

	if is_multiplayer_authority():
		if char_model: char_model.hide()
		_update_weapon_hud()
		_display_role_card(role_name)
		_update_role_indicator(role_name)
		if current_role == "PRESIDENT":
			_update_mission_hud()
			if mission_panel: mission_panel.show()
		else:
			if mission_panel: mission_panel.hide()

func _update_weapon_hud():
	# Eldeki tüm 3D silah modellerini gizle
	if vm_knife: vm_knife.hide()
	if vm_pistol: vm_pistol.hide()
	if vm_taser: vm_taser.hide()
	if vm_detector: vm_detector.hide()
	if vm_megaphone: vm_megaphone.hide()
	if vm_briefcase: vm_briefcase.hide()
	if vm_drone_remote: vm_drone_remote.hide()
	if fps_arm: fps_arm.show()
	
	if not weapon_panel or not slot1_panel or not slot2_panel or not slot3_panel: return
	weapon_panel.show()
	
	# Kenney UI Dokulu Yuva Stili
	var _set_slot = func(panel: PanelContainer, label: Label, text: String, is_active: bool, is_disabled: bool = false):
		if not panel or not label: return
		panel.show()
		label.text = text
		var sb = StyleBoxTexture.new()
		sb.texture_margin_left = 8.0
		sb.texture_margin_top = 6.0
		sb.texture_margin_right = 8.0
		sb.texture_margin_bottom = 8.0
		
		if is_active:
			sb.texture = load("res://ui_kenney/blue_button00.png")
			label.add_theme_color_override("font_color", Color(1, 1, 1))
		elif is_disabled:
			sb.texture = load("res://ui_kenney/grey_button00.png")
			sb.modulate_color = Color(0.6, 0.6, 0.6, 0.6)
			label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
		else:
			sb.texture = load("res://ui_kenney/yellow_button00.png")
			label.add_theme_color_override("font_color", Color(0.18, 0.15, 0.05))
		panel.add_theme_stylebox_override("panel", sb)

	if current_role == "ASSASSIN":
		if slot_category: slot_category.text = "🗡️ SUİKASTÇI CEPHANESİ & TAKTİKLERİ"
		_set_slot.call(slot1_panel, slot1_label, "[1] 🔪 Bıçak", selected_slot == 1)
		_set_slot.call(slot2_panel, slot2_label, "[2] 🔫 Tabanca (%d)" % pistol_ammo, selected_slot == 2, pistol_ammo <= 0)
		_set_slot.call(slot3_panel, slot3_label, "[3] 📢 İzdiham", selected_slot == 3)
		if slot4_panel: slot4_panel.hide()
		
		if selected_slot == 1 and vm_knife: vm_knife.show()
		elif selected_slot == 2 and vm_pistol: vm_pistol.show()
		
	elif current_role == "GUARD":
		var taser_txt = "[1] ⚡ Taser" if taser_cooldown <= 0 else "[1] ⏳ %.0fs" % taser_cooldown
		_set_slot.call(slot1_panel, slot1_label, taser_txt, selected_slot == 1, taser_cooldown > 0)
		
		if guard_class == 1:
			if slot_category: slot_category.text = "🛡️ KORUMA 1 (DEDEKTÖR UZMANI)"
			_set_slot.call(slot2_panel, slot2_label, "[2] 📡 Dedektör", selected_slot == 2, scan_cooldown > 0)
			if selected_slot == 2 and vm_detector: vm_detector.show()
		elif guard_class == 2:
			if slot_category: slot_category.text = "🛡️ KORUMA 2 (DRON OPERATÖRÜ)"
			var drone_txt = "[2] 🚁 Dron Gönder" if not drone_mode else "[2] 🛑 Dronu İndir"
			_set_slot.call(slot2_panel, slot2_label, drone_txt, selected_slot == 2 or drone_mode)
			if selected_slot == 2 and vm_drone_remote: vm_drone_remote.show()
		elif guard_class == 3:
			if slot_category: slot_category.text = "🛡️ KORUMA 3 (GÜVENLİK ANONSÇUSU)"
			var mega_txt = "[2] 📢 'Herkes Dursun!'" if radio_cooldown <= 0 else "[2] ⏳ %.0fs" % radio_cooldown
			_set_slot.call(slot2_panel, slot2_label, mega_txt, selected_slot == 2, radio_cooldown > 0)
			if selected_slot == 2 and vm_megaphone: vm_megaphone.show()
			
		if slot3_panel: slot3_panel.hide()
		if slot4_panel: slot4_panel.hide()
		if selected_slot == 1 and vm_taser: vm_taser.show()
		
	elif current_role == "PRESIDENT":
		if slot_category: slot_category.text = "🏛️ BAŞKAN YETENEKLERİ & ZIRHI"
		var sprint_txt = "[1] 🏃 Depar" if sprint_cooldown <= 0 else "[1] ⏳ %.0fs" % sprint_cooldown
		var canta_txt = "[3] 💼 Çelik Çanta" if has_briefcase_shield else "[3] 💥 Kırıldı"
		var tea_txt = "[4] 🍵 Çay Fırlat" if tea_cooldown <= 0 else "[4] ⏳ %.0fs" % tea_cooldown
		
		_set_slot.call(slot1_panel, slot1_label, sprint_txt, selected_slot == 1, sprint_cooldown > 0)
		_set_slot.call(slot2_panel, slot2_label, "[2] 📢 Megafon", selected_slot == 2)
		_set_slot.call(slot3_panel, slot3_label, canta_txt, selected_slot == 3, not has_briefcase_shield)
		if slot4_panel and slot4_label:
			_set_slot.call(slot4_panel, slot4_label, tea_txt, selected_slot == 4, tea_cooldown > 0)
		
		if selected_slot == 2 and vm_megaphone: vm_megaphone.show()
		elif selected_slot == 3 and vm_briefcase and has_briefcase_shield: vm_briefcase.show()
	else:
		if weapon_panel: weapon_panel.hide()
# 🎯 Mission HUD'unu güncelle
func _update_mission_hud():
	if not mission_label: return
	var icons = []
	var labels = ["🎙️ Kürsü", "🤝 Halk", "🎥 Basın"]
	for i in range(3):
		if mission_done[i]:
			icons.append("✅ %s" % labels[i])
		elif i == mission_state:
			icons.append("⏳ %s" % labels[i])
		else:
			icons.append("❌ %s" % labels[i])
	mission_label.text = "  ".join(icons)

func _display_role_card(role_name: String):
	if not role_panel or not role_title or not role_desc: return
	
	if role_name == "PRESIDENT":
		role_title.text = "🏛️ SENİN ROLÜN: BAŞKAN"
		role_desc.text = "3 Görev: Kürsü → Halk → Basın. [E] basılı tutarak tamamla!"
	elif role_name == "ASSASSIN":
		role_title.text = "🗡️ SENİN ROLÜN: SUİKASTÇI"
		role_desc.text = "[1] Bıçak & [2] Tek Mermili Tabanca. Sivil gibi davran, Başkanı indir!"
	elif role_name == "GUARD":
		if guard_class == 1:
			role_title.text = "🛡️ SENİN ROLÜN: KORUMA 1 — DEDEKTÖR UZMANI"
			role_desc.text = "[1] Taser (7.5m) & [2] Metal Dedektörü. Şüphelileri tara, Başkanı koru!"
		elif guard_class == 2:
			role_title.text = "🛡️ SENİN ROLÜN: KORUMA 2 — DRON OPERATÖRÜ"
			role_desc.text = "[1] Taser & [2] Gözetleme Dronu (45sn batarya). Havadan izle, silahı yakala!"
		elif guard_class == 3:
			role_title.text = "🛡️ SENİN ROLÜN: KORUMA 3 — TAKTİK TELSİZ"
			role_desc.text = "[1] Taser & [2] Radar İhbarı & [3] Megafon. Suikastçıyı aydınlat, durdur!"
		
	role_panel.show()
	await get_tree().create_timer(2.0).timeout
	if role_panel:
		role_panel.hide()

func _update_role_indicator(role_name: String):
	if not role_indicator: return
	var role_txt = "🏛️ BAŞKAN"
	var col = Color(0.35, 0.75, 1.0)
	match role_name:
		"PRESIDENT":
			role_txt = "👑 BAŞKAN"
			col = Color(0.95, 0.8, 0.2)
		"GUARD":
			var c_name = "DEDEKTÖR"
			if guard_class == 2: c_name = "DRON"
			elif guard_class == 3: c_name = "MEGAFON"
			role_txt = "🛡️ KORUMA %d (%s)" % [guard_class, c_name]
			col = Color(0.3, 0.9, 0.45)
		"ASSASSIN":
			role_txt = "🗡️ SUİKASTÇI"
			col = Color(0.95, 0.35, 0.35)
			
	role_indicator.text = role_txt
	role_indicator.add_theme_color_override("font_color", col)
	role_indicator.show()
	
	# TopHeader içindeki RoleLabel'ı da güncelle
	var top_role_lbl = get_node_or_null("/root/main/TopBarHUD/TopHeader/Margin/HBox/LeftBox/RoleBadge/RoleLabel")
	if top_role_lbl:
		top_role_lbl.text = "  %s  " % role_txt
		top_role_lbl.add_theme_color_override("font_color", col)


@rpc("any_peer", "call_local")
func apply_stun_effect(duration: float, message: String):
	is_game_over = true
	progress_bar.hide()
	task_progress = 0.0
	
	if has_node("HUD/GameOverPanel"):
		$HUD/GameOverPanel/WinnerLabel.text = message
		$HUD/GameOverPanel.show()
		
		await get_tree().create_timer(duration).timeout
		
		if $HUD/GameOverPanel/WinnerLabel.text == message:
			$HUD/GameOverPanel.hide()
			is_game_over = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func local_game_over(message: String):
	is_game_over = true
	if drone_mode: _deactivate_drone()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if summary_panel:
		if summary_winner: summary_winner.text = message
		if summary_role:
			var role_txt = "Rolün: "
			match current_role:
				"PRESIDENT": role_txt += "🏛️ BAŞKAN"
				"GUARD":     role_txt += "🛡️ KORUMA"
				"ASSASSIN":  role_txt += "🗡️ SUİKASTÇI"
			summary_role.text = role_txt
		if summary_time:
			var elapsed = 120
			var timer_node = get_node_or_null("/root/main/TopBarHUD/TopPanel/TimerLabel")
			if timer_node:
				var parts = timer_node.text.replace("⏱️ ", "").split(":")
				if parts.size() == 2:
					elapsed = 120 - (parts[0].to_int() * 60 + parts[1].to_int())
			summary_time.text = "Süre: %d dakika %d saniye" % [elapsed / 60, elapsed % 60]
		summary_panel.show()
	elif has_node("HUD/GameOverPanel"):
		$HUD/GameOverPanel/WinnerLabel.text = message
		$HUD/GameOverPanel.show()


func _input(event):
	if multiplayer.has_multiplayer_peer() and not is_multiplayer_authority(): return

	# 🖱️ Tıklayınca Fareyi Ekrana Kilitle
	if event is InputEventMouseButton and event.pressed and not is_paused and not is_game_over:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# 🖱️ Fare Hareketi ile Bakış Açısı
	if event is InputEventMouseMotion and not is_paused:
		var sens = base_sensitivity * mouse_sensitivity
		if drone_mode and drone_anchor and drone_camera:
			drone_anchor.rotate_y(-event.relative.x * sens)
			drone_camera.rotate_x(-event.relative.y * sens)
			drone_camera.rotation.x = clamp(drone_camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		elif camera:
			rotate_y(-event.relative.x * sens)
			camera.rotate_x(-event.relative.y * sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	# ⏸️ ESC ile Duraklatma
	if event.is_action_pressed("ui_cancel"):
		if is_game_over: return
		if drone_mode:
			_deactivate_drone()
			return
		_toggle_pause()

		# --- 🎮 GAMEPLAY & TEST TUŞLARI ---
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			current_role = "PRESIDENT"
			global_position = Vector3(0, 2.8, -32.0)
			mission_state = 0
			mission_done = [false, false, false]
			has_briefcase_shield = true
			if drone_mode: _deactivate_drone()
			_update_weapon_hud()
			_update_role_indicator("PRESIDENT")
			_update_mission_hud()
			if mission_panel: mission_panel.show()
			_show_temp_prompt("👑 TEST: BAŞKAN SEÇİLDİ (Kürsü Görevi Aktif)")
		elif event.keycode == KEY_F2:
			if current_role == "GUARD":
				guard_class = (guard_class % 3) + 1
			else:
				current_role = "GUARD"
				guard_class = 1
			selected_slot = 1
			if drone_mode: _deactivate_drone()
			_update_weapon_hud()
			_update_role_indicator("GUARD")
			if mission_panel: mission_panel.hide()
			var c_name = "DEDEKTÖR"
			if guard_class == 2: c_name = "DRON"
			elif guard_class == 3: c_name = "MEGAFON (HERKES DURSUN)"
			_show_temp_prompt("🛡️ TEST: KORUMA %d (%s) SEÇİLDİ!" % [guard_class, c_name])
		elif event.keycode == KEY_F3:
			current_role = "ASSASSIN"
			pistol_ammo = 1
			selected_slot = 1
			if drone_mode: _deactivate_drone()
			_update_weapon_hud()
			_update_role_indicator("ASSASSIN")
			if mission_panel: mission_panel.hide()
			_show_temp_prompt("🗡️ TEST: SUİKASTÇI SEÇİLDİ (Gizli Silah Hazır)")
		elif event.keycode == KEY_F:
			if current_role == "GUARD" and guard_class == 2:
				if drone_mode: _deactivate_drone()
				else: _activate_drone()
		elif event.keycode == KEY_R and is_game_over:
			var mn = get_node_or_null("/root/main")
			if mn and mn.has_method("restart_match"):
				mn.rpc("restart_match")
		elif event.keycode == KEY_C:
			is_mimic_pose = not is_mimic_pose
			if is_mimic_pose:
				_show_temp_prompt("🎭 SİVİL TAKLİDİ AKTİF (Miting Dinleme Pozu) — [WASD] veya [C] ile Çık!")
			else:
				_show_temp_prompt("🏃 Normal Yürüyüşe Döndün.")
		elif event.keycode == KEY_G:
			if current_role == "ASSASSIN":
				_execute_assassin_drop_weapon()


	# --- 🔢 SİLAH SEÇİMİ (1, 2, 3, 4) ---
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			selected_slot = 1
			_update_weapon_hud()
		elif event.keycode == KEY_2:
			selected_slot = 2
			_update_weapon_hud()
			if current_role == "GUARD" and guard_class == 2:
				if drone_mode: _deactivate_drone()
				else: _activate_drone()
		elif event.keycode == KEY_3:
			selected_slot = 3
			_update_weapon_hud()
			if current_role == "ASSASSIN":
				_execute_assassin_stampede()
		elif event.keycode == KEY_4:
			selected_slot = 4
			_update_weapon_hud()
			if current_role == "PRESIDENT":
				_execute_president_throw_tea()

		# --- Dron modundayken E tuşunun veya sol tıkın dronu kapatmasını / aksiyon almasını engelle ---
	if drone_mode:
		return

	# --- 🏛️ BAŞKAN AKSİYONLARI ---
	if current_role == "PRESIDENT" and (event.is_action_pressed("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)):
		var in_task_zone = (mission_state == 0 and raycast and raycast.is_colliding() and ("TaskBox" in raycast.get_collider().name))
		if not in_task_zone:
			if selected_slot == 1:
				_execute_president_sprint()
			elif selected_slot == 2:
				_execute_president_rally_call()
			elif selected_slot == 3:
				if has_briefcase_shield:
					_show_temp_prompt("💼 Çelik Çanta Kalkanı Aktif! (1 Darbe Engeller)")
			elif selected_slot == 4:
				_execute_president_throw_tea()

	# --- 🗡️ SUİKASTÇI AKSİYONLARI ---
	if current_role == "ASSASSIN" and (event.is_action_pressed("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)):
		var is_looking_at_wc = false
		if raycast and raycast.is_colliding():
			var col = raycast.get_collider()
			if col and ("PortableWC" in col.name or "WC" in col.name):
				if global_position.distance_to(col.global_position) < 4.0:
					is_looking_at_wc = true
					_execute_assassin_disguise()
		if not is_looking_at_wc:
			if selected_slot == 1:
				_execute_assassin_knife()
			elif selected_slot == 2:
				_execute_assassin_pistol()
			elif selected_slot == 3:
				_execute_assassin_stampede()

	# --- 🛡️ KORUMA AKSİYONLARI ---
	if current_role == "GUARD" and (event.is_action_pressed("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)):
		if selected_slot == 1:
			_execute_guard_taser()
		elif selected_slot == 2:
			if guard_class == 1:
				_execute_guard_detector()
			elif guard_class == 2:
				if drone_mode: _deactivate_drone()
				else: _activate_drone()
			elif guard_class == 3:
				_execute_guard_freeze_command()


# 🏃 Başkan Depar
func _execute_president_sprint():
	if sprint_cooldown > 0:
		_show_temp_prompt("⏳ Depar Dinleniyor! (%.1f sn)" % sprint_cooldown)
		return
	sprint_active = true
	sprint_cooldown = 10.0
	_show_temp_prompt("🏃 ADRENALİN DEPARI AKTİF! (3 sn Hızlı Koşu)")
	await get_tree().create_timer(3.0).timeout
	sprint_active = false

# 📢 Başkan Megafon Miting Çağrısı
func _execute_president_rally_call():
	if megaphone_cooldown > 0:
		_show_temp_prompt("⏳ Megafon Dinleniyor! (%.1f sn)" % megaphone_cooldown)
		return
	megaphone_cooldown = 10.0
	_animate_hand_action()
	_show_temp_prompt("📢 'SEVGİLİ VATANDAŞLARIM!' (+1.8% Seçim Oyu)")
	var mn = get_node_or_null("/root/main")
	if mn:
		if mn.has_method("adjust_poll_score"):
			mn.adjust_poll_score(1.8, "📢 Miting Coşkusu (+1.8%)")
		if mn.has_method("trigger_crowd_panic"):
			mn.rpc("trigger_crowd_panic", Vector3(0, 0, -12), 30.0)
	_update_weapon_hud()

# 🔪 Suikastçı Bıçak İnfazı & Gelişmiş Savurma Efekti
func _execute_assassin_knife():
	_animate_knife_slash()
	if sfx_knife: sfx_knife.play()
	trigger_camera_shake(0.35, 0.18)
	set_weapon_exposed(true)
	if raycast.is_colliding():
		var col = raycast.get_collider()
		if col:
			if col.has_method("die_and_drop"):
				col.rpc("die_and_drop", "BIÇAK")
			elif col.has_method("apply_stun"):
				col.rpc("apply_stun", 10.0)
				_show_temp_prompt("🔪 SİVİL BIÇAKLANDI! Silahın açığa çıktı! [G] ile Bıçağı Yere At!")
				var mn = get_node_or_null("/root/main")
				if mn and mn.has_method("trigger_crowd_panic"):
					mn.rpc("trigger_crowd_panic", global_position, 20.0)
	else:
		_show_temp_prompt("🗡️ Bıçak Savruldu! Silahın açığa çıktı! [G] ile Gizle!")

# 🔫 Suikastçı Tabanca Ateşi & 3D Mermi İzi (Tracer)
func _execute_assassin_pistol():
	if pistol_ammo <= 0:
		_show_temp_prompt("❌ Merminiz bitti! (Tek atımlıktı)")
		return
		
	pistol_ammo -= 1
	_update_weapon_hud()
	_animate_gun_recoil()
	if sfx_gunshot: sfx_gunshot.play()
	trigger_camera_shake(0.75, 0.35)
	
	# Merminin çıkış noktası ve hedef çarpma koordinatı
	var muzzle_pos = camera.global_position + (-camera.global_basis.z * 0.4) + (camera.global_basis.x * 0.2) + (-camera.global_basis.y * 0.15)
	var target_pos = camera.global_position + (-camera.global_basis.z * 50.0)
	if raycast.is_colliding():
		target_pos = raycast.get_collision_point()
		
	_spawn_bullet_tracer(muzzle_pos, target_pos, false)
	if multiplayer.has_multiplayer_peer():
		rpc("net_spawn_bullet_tracer", muzzle_pos, target_pos, false)
	
	# 🔥 Silahı HEMEN hem yerelde hem ağda açığa çıkar!
	set_weapon_exposed(true)
	_show_temp_prompt("⚠️ SİLAH ATEŞLENDİ! SİLAH ELİNDE AÇIĞA ÇIKTI! [G] İLE YERE AT!")
	
	var mn = get_node_or_null("/root/main")
	if mn and mn.has_method("trigger_crowd_panic"):
		mn.rpc("trigger_crowd_panic", global_position, 35.0)
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target is CharacterBody3D:
			if "current_role" in target:
				if target.current_role == "PRESIDENT":
					if target.has_method("defend_against_bullet") and target.defend_against_bullet():
						_show_temp_prompt("💥 MERMİ BAŞKANIN ÇELİK ÇANTASINA ÇARPTI VE SEKTİ! [G] ile Kaç!")
						return
					if mn and mn.has_method("net_game_over"):
						mn.rpc("net_game_over", "BAŞKAN UZAKTAN VURULDU!
🔫 SUİKASTÇI KAZANDI!")
				elif target.current_role == "GUARD":
					target.rpc("apply_stun_effect", 6.0, "MERMİYLE VURULDUNUZ!
6 Saniye Ağır Yaralısınız!")
			else:
				if target.has_method("apply_stun"):
					target.rpc("apply_stun", 12.0)
				_show_temp_prompt("💥 SİVİLİ VURDUN! Silahın elinde açığa çıktı! [G] ile Silahı At!")

# 🔫 3. Şahıs Silah Görünürlüğü (Ateş Edince Açığa Çıkma)
func set_weapon_exposed(exposed: bool):
	is_weapon_exposed = exposed
	if third_person_weapon:
		third_person_weapon.visible = exposed
	if multiplayer.has_multiplayer_peer():
		rpc("net_set_weapon_exposed", exposed)

# ⚡ Koruma Taser (Menzil: 7.5m, Bayılma: 4.5s)
func _execute_guard_taser():
	if taser_cooldown > 0:
		_show_temp_prompt("⏳ Taser Şarj Oluyor! (%.1f sn)" % taser_cooldown)
		return
		
	taser_cooldown = 4.0
	_animate_gun_recoil(true)
	if sfx_taser: sfx_taser.play()
	trigger_camera_shake(0.3, 0.2)
	_update_weapon_hud()
	
	var muzzle_pos = camera.global_position + (-camera.global_basis.z * 0.4) + (camera.global_basis.x * 0.2) + (-camera.global_basis.y * 0.15)
	var target_pos = camera.global_position + (-camera.global_basis.z * 8.0)
	if raycast.is_colliding():
		target_pos = raycast.get_collision_point()
		
	_spawn_bullet_tracer(muzzle_pos, target_pos, true)
	if multiplayer.has_multiplayer_peer():
		rpc("net_spawn_bullet_tracer", muzzle_pos, target_pos, true)
	
	if not raycast.is_colliding():
		_show_temp_prompt("⚡ Taser Boşa Ateşlendi!")
		return
		
	var dist = global_position.distance_to(raycast.get_collision_point())
	if dist > 7.5:
		_show_temp_prompt("❌ Hedef çok uzakta! (Taser Menzili: 7.5m, Mesafe: %.1fm)" % dist)
		return
		
	var target = raycast.get_collider()
	if not target: return
	
	if target.is_in_group("players"):
		if target.get("current_role") == "ASSASSIN":
			target.rpc("apply_player_stun", 4.5)
			_show_temp_prompt("⚡ ŞÜPHELİ YERE İNDİRİLDİ! 4.5 SN İÇİNDE [E] İLE ARA!")
		else:
			_show_temp_prompt("⚠️ Korumaya veya Başkana taser sıkamazsın!")
	elif target.is_in_group("npcs") or target.has_method("apply_stun"):
		if target.has_method("apply_stun"):
			target.rpc("apply_stun", 4.5)
		_show_temp_prompt("⚡ SİVİL YERE İNDİRİLDİ! 4.5 SN İÇİNDE [E] İLE ARA!")


# 📡 Koruma Metal Dedektörü
func _execute_guard_detector():
	if scan_cooldown > 0:
		_show_temp_prompt("⏳ Dedektör Soğuyor! (%.1f sn)" % scan_cooldown)
		return
		
	if raycast.is_colliding():
		var dist = global_position.distance_to(raycast.get_collision_point())
		if dist > 4.0:
			_show_temp_prompt("❌ Taramak için şüpheliye yaklaşın! (4m)")
			return
			
		var target = raycast.get_collider()
		if target is CharacterBody3D:
			scan_cooldown = 3.0
			_animate_hand_action()
			if sfx_scan: sfx_scan.play()
			_show_scan_results(target)

func _show_scan_results(target):
	if not scan_panel or not scan_title or not scan_items: return
	
	if "current_role" in target:
		if target.current_role == "ASSASSIN":
			scan_title.text = "🚨 ALARM! TEHLİKELİ METAL BULUNDU!"
			scan_items.text = "Üzerinde Bulunanlar: 🔫 9mm Ruhsatsız Tabanca, 🔪 Gizli Susturuculu Bıçak, 🪙 1 Lira"
		elif target.current_role == "PRESIDENT":
			scan_title.text = "👑 DEVLET PROTOKOLÜ TESPİT EDİLDİ"
			scan_items.text = "Üzerinde Bulunanlar: 🏅 Cumhurbaşkanlığı Mührü, 💳 Altın Kart, 🖊️ Dolma Kalem"
		elif target.current_role == "GUARD":
			scan_title.text = "🛡️ KORUMA MESLEKTAŞI TESPİT EDİLDİ"
			scan_items.text = "Üzerinde Bulunanlar: 📻 Telsiz, ⚡ Yedek Taser Bataryası, 🕶️ Yedek Siyah Gözlük"
	else:
		var picked = []
		var shuffled = SILLY_ITEMS.duplicate()
		shuffled.shuffle()
		for i in range(3):
			picked.append(shuffled[i])
		scan_title.text = "✅ SİVİL TARAMASI (Tehlike Yok)"
		scan_items.text = "Üzerinden Çıkanlar: %s, %s, %s" % [picked[0], picked[1], picked[2]]
		
	scan_panel.show()
	await get_tree().create_timer(4.0).timeout
	if scan_panel:
		scan_panel.hide()

# Eldeki 3D model için minik vuruş/geri tepme animasyonu
func _animate_hand_action():
	if not hand_anchor: return
	var orig_z = -0.48
	hand_anchor.position.z = orig_z + 0.08
	await get_tree().create_timer(0.08).timeout
	if hand_anchor:
		hand_anchor.position.z = orig_z

func _show_temp_prompt(msg: String):
	if action_prompt:
		action_prompt.text = msg
		await get_tree().create_timer(2.0).timeout
		if action_prompt.text == msg:
			action_prompt.text = ""

# 🏛️ Başkanın şu anki görevi için E basılı tutma mantığı
func _handle_president_task(delta):
	if current_role != "PRESIDENT" or is_game_over: return
	
	var in_zone = false
	var target_label = ""
	
	match mission_state:
		0:
			if raycast.is_colliding():
				var col = raycast.get_collider()
				if col and ("TaskBox" in col.name or "Podium" in col.name):
					in_zone = true
					target_label = "🎙️ Kürsü Konuşması Yap"
		1:
			if global_position.distance_to(Vector3(0, 0, -18.0)) < 4.0:
				in_zone = true
				target_label = "🤝 Halkı Selamla"
		2:
			if global_position.distance_to(Vector3(26, 0, -18.0)) < 5.0:
				in_zone = true
				target_label = "🎥 Basın Röportajı Ver"
				
	if in_zone:
		if Input.is_action_pressed("interact"):
			progress_bar.show()
			task_progress += 8.0 * delta # ~12.5 sn toplam süre
			progress_bar.value = task_progress
			if action_prompt:
				action_prompt.text = "%s ([E] Basılı Tut: %d%%)" % [target_label, int(task_progress)]
				
			# 🎙️ Kürsü Konuşması Checkpoint & Vaat Yayınları (%25, %50, %75)
			if mission_state == 0:
				if task_progress >= 25.0 and last_speech_broadcast < 0:
					last_speech_broadcast = 0
					speech_checkpoint = 25.0
					var mn = get_node_or_null("/root/main")
					if mn and mn.has_method("show_campaign_promise"):
						mn.rpc("show_campaign_promise", 0)
					_show_temp_prompt("🎙️ 1. SEÇİM MÜJDESİ AÇIKLANDI! (%25 Checkpoint Kaydedildi)")
				elif task_progress >= 50.0 and last_speech_broadcast < 1:
					last_speech_broadcast = 1
					speech_checkpoint = 50.0
					var mn = get_node_or_null("/root/main")
					if mn and mn.has_method("show_campaign_promise"):
						mn.rpc("show_campaign_promise", 1)
					_show_temp_prompt("🎙️ 2. SEÇİM MÜJDESİ AÇIKLANDI! (%50 Checkpoint Kaydedildi)")
				elif task_progress >= 75.0 and last_speech_broadcast < 2:
					last_speech_broadcast = 2
					speech_checkpoint = 75.0
					var mn = get_node_or_null("/root/main")
					if mn and mn.has_method("show_campaign_promise"):
						mn.rpc("show_campaign_promise", 2)
					_show_temp_prompt("🎙️ 3. SEÇİM MÜJDESİ AÇIKLANDI! (%75 Checkpoint Kaydedildi)")
				
			if task_progress >= 100.0:
				task_progress = 0.0
				speech_checkpoint = 0.0
				last_speech_broadcast = -1
				progress_bar.hide()
				mission_done[mission_state] = true
				_update_mission_hud()
				if sfx_task_complete: sfx_task_complete.play()

				match mission_state:
					0:
						var mn = get_node_or_null("/root/main")
						if mn and mn.has_method("show_campaign_promise"):
							mn.rpc("show_campaign_promise", 3)
						_show_temp_prompt("✅ KÜRSÜ KONUŞMASI TAMAMLANDI! Şimdi bariyere git ve halkı selamla!")
						mission_state = 1
					1:
						_show_temp_prompt("✅ HALKI SELAMLADIN! Şimdi kırmızı basın çadırına git!")
						mission_state = 2
					2:
						mission_state = 3
						mission_done[2] = true
						_update_mission_hud()
						get_node("/root/main").rpc("net_game_over",
							"MİTİNG 3 GÖREV TAMAMLANDI!
🏛️ BAŞKAN VE KORUMALAR KAZANDI!")
		else:
			if not is_game_over:
				progress_bar.hide()
				# Checkpoint'e geri döndür (0'a sıfırlama!)
				if mission_state == 0:
					task_progress = speech_checkpoint
				else:
					task_progress = 0.0
				if action_prompt:
					action_prompt.text = "%s için [E] Basılı Tut!" % target_label
var _last_hint: String = ""
var _hint_cooldown: float = 0.0

func _show_hint_once(msg: String):
	if _hint_cooldown > 0: return
	if _last_hint == msg: return
	_last_hint = msg
	_hint_cooldown = 4.0
	if action_prompt:
		action_prompt.text = msg

func _physics_process(delta):
	if multiplayer.has_multiplayer_peer() and not is_multiplayer_authority(): return

	if is_downed:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
	# 🖐️ Eldeki Silah ve Kol için Prosedürel Yürüme Sallantısı (Weapon Bobbing)
	if hand_anchor and is_on_floor() and velocity.length() > 0.5:
		_bob_timer += delta * velocity.length()
		var bob_y = sin(_bob_timer * 1.8) * 0.008
		var sway_x = cos(_bob_timer * 0.9) * 0.006
		hand_anchor.position.y = _hand_def_pos.y + bob_y
		hand_anchor.position.x = _hand_def_pos.x + sway_x
	elif hand_anchor:
		hand_anchor.position.y = lerp(hand_anchor.position.y, _hand_def_pos.y, 8.0 * delta)
		hand_anchor.position.x = lerp(hand_anchor.position.x, _hand_def_pos.x, 8.0 * delta)

		return

	if drone_mode:
		_process_drone(delta)
		return

	if is_paused:
		return

	# Sivil taklidi yapıyorsa WASD hareketini engelle, sahneye baksın
	if is_mimic_pose:
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir.length_squared() > 0.01:
			is_mimic_pose = false
			_show_temp_prompt("🏃 Yürüyüşe Döndün.")
		else:
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0.0
			velocity.x = 0.0
			velocity.z = 0.0
			var stage_pos = Vector3(0, 0, -28.0)
			var to_stage = (stage_pos - global_position).normalized()
			to_stage.y = 0
			if char_model and to_stage.length_squared() > 0.1:
				char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, atan2(to_stage.x, to_stage.z), 8.0 * delta)
			move_and_slide()
	# 🖐️ Eldeki Silah ve Kol için Prosedürel Yürüme Sallantısı (Weapon Bobbing)
	if hand_anchor and is_on_floor() and velocity.length() > 0.5:
		_bob_timer += delta * velocity.length()
		var bob_y = sin(_bob_timer * 1.8) * 0.008
		var sway_x = cos(_bob_timer * 0.9) * 0.006
		hand_anchor.position.y = _hand_def_pos.y + bob_y
		hand_anchor.position.x = _hand_def_pos.x + sway_x
	elif hand_anchor:
		hand_anchor.position.y = lerp(hand_anchor.position.y, _hand_def_pos.y, 8.0 * delta)
		hand_anchor.position.x = lerp(hand_anchor.position.x, _hand_def_pos.x, 8.0 * delta)

			_update_player_animation()
			return

	if not is_on_floor():
		velocity.y -= gravity * delta

	# Zıplama
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed = SPEED
	if sprint_active:
		current_speed *= 1.8
	if penalty_slow_timer > 0.0:
		current_speed *= 0.45

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	if char_model:
		if direction.length_squared() > 0.01:
			var target_rot = atan2(-direction.x, -direction.z)
			char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, target_rot, 12 * delta)
		else:
			char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, global_rotation.y, 10 * delta)

	move_and_slide()
	# 🖐️ Eldeki Silah ve Kol için Prosedürel Yürüme Sallantısı (Weapon Bobbing)
	if hand_anchor and is_on_floor() and velocity.length() > 0.5:
		_bob_timer += delta * velocity.length()
		var bob_y = sin(_bob_timer * 1.8) * 0.008
		var sway_x = cos(_bob_timer * 0.9) * 0.006
		hand_anchor.position.y = _hand_def_pos.y + bob_y
		hand_anchor.position.x = _hand_def_pos.x + sway_x
	elif hand_anchor:
		hand_anchor.position.y = lerp(hand_anchor.position.y, _hand_def_pos.y, 8.0 * delta)
		hand_anchor.position.x = lerp(hand_anchor.position.x, _hand_def_pos.x, 8.0 * delta)

	_update_player_animation()

	# --- 💥 GERİ BİLDİRİM ---
	var is_moving = velocity.length() > 0.3
	_update_footsteps(delta, is_moving)
	_update_heartbeat(delta)
	_process_camera_shake(delta)

	# --- 🏛️ 3 AŞAMALI BAŞKAN GÖREV SİSTEMİ ---
	_handle_president_task(delta)
	_process_sniper_aiming(delta)

func _trigger_campaign_anthem():
	if anthem_cooldown > 0.0:
		if action_prompt: action_prompt.text = "⏳ Seçim Şarkısı Beklemede (%.1fs)" % anthem_cooldown
		return
		
	anthem_cooldown = 18.0
	if action_prompt: action_prompt.text = "🕺 SEÇİM ŞARKISI ÇALIYOR! MİTİNG COŞTU!"
	
	# Meydandaki NPC'leri coştur
	var main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_method("trigger_crowd_cheer"):
		main_node.rpc("trigger_crowd_cheer", global_position, 25.0)

@rpc("any_peer", "call_local")
func block_attack_with_shield() -> bool:
	if current_role == "PRESIDENT" and has_briefcase_shield:
		has_briefcase_shield = false
		_update_weapon_hud()
		if sfx_task_complete: sfx_task_complete.play()
		if action_prompt: action_prompt.text = "🛡️ ÇELİK ÇANTA SALDIRIYI BLOKLADI! HIZLA KAÇ!"
		sprint_active = true
		get_tree().create_timer(3.5).timeout.connect(func(): sprint_active = false)
		return true
	return false


@rpc("any_peer", "call_local")
func apply_player_stun(duration: float = 4.5):
	is_downed = true
	downed_timer = duration
	rotation_degrees.z = 85.0
	if is_multiplayer_authority():
		trigger_hit_flash(0.6, 0.25)
		trigger_camera_shake(0.8, 0.5)


# 📻 Koruma 3: Taktik Telsiz / Radar İhbarı (Şüpheliyi Ekranda ve Haritada Aydınlat)
func _execute_tactical_radio():
	if radio_cooldown > 0:
		_show_temp_prompt("⏳ Telsiz Dinleniyor! (%.1f sn)" % radio_cooldown)
		return
	radio_cooldown = 15.0
	_show_temp_prompt("📻 TELSİZ İHBARI: Miting meydanındaki hareketli şüpheliler tarandı!")
	if sfx_scan: sfx_scan.play()
	
	# Meydanda koşan veya şüpheli hareket edenleri tespit et
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p and p.get("current_role") == "ASSASSIN":
			var dist = global_position.distance_to(p.global_position)
			_show_temp_prompt("🚨 TELSİZ ALARMI: Şüpheli Şahıs %.1fm Mesafede Tespit Edildi!" % dist)


# 📢 Koruma 3: Megafon 'HERKES DURSUN!' Emri (Kademeli Sivil Dondurma & Suikastçı Yakalama)
func _execute_guard_freeze_command():
	if radio_cooldown > 0:
		_show_temp_prompt("⏳ Megafon Dinleniyor! (%.1f sn)" % radio_cooldown)
		return
	radio_cooldown = 18.0
	_show_temp_prompt("📢 'ŞÜPHELİ HAREKET VAR! HERKES OLDUĞU YERDE DURSUUUN!'")
	_animate_hand_action()
	
	var mn = get_node_or_null("/root/main")
	if mn and mn.has_method("net_trigger_guard_freeze"):
		mn.rpc("net_trigger_guard_freeze")


# 🦹‍♂️ Suikastçı: WC'de Kılık Değiştirme (Kıyafet Rengi Değiştir)
@rpc("any_peer", "call_local")
func net_apply_disguise(color_idx: int):
	var colors = [
		Color(0.2, 0.35, 0.55), # Lacivert Takım
		Color(0.18, 0.45, 0.25), # Zümrüt Yeşili
		Color(0.48, 0.22, 0.22), # Bordo Takım
		Color(0.55, 0.45, 0.2),  # Hardal/Kahve Takım
		Color(0.28, 0.28, 0.32), # Koyu Füme
		Color(0.7, 0.7, 0.75)   # Açık Gri Takım
	]
	var selected_col = colors[color_idx % colors.size()]
	var torso = get_node_or_null("CharacterModel/AnimMesh/character/root/torso")
	var leg_l = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-left")
	var leg_r = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-right")
	var s_mat = StandardMaterial3D.new()
	s_mat.albedo_color = selected_col
	s_mat.roughness = 0.7
	var p_mat = StandardMaterial3D.new()
	p_mat.albedo_color = selected_col.darkened(0.25)
	p_mat.roughness = 0.85
	if torso: torso.set_surface_override_material(0, s_mat)
	if leg_l: leg_l.set_surface_override_material(0, p_mat)
	if leg_r: leg_r.set_surface_override_material(0, p_mat)
func _execute_assassin_disguise():
	if disguise_cooldown > 0:
		_show_temp_prompt("⏳ WC Dolu! (%.1f sn bekle)" % disguise_cooldown)
		return
	disguise_cooldown = 20.0
	_show_temp_prompt("🎭 KILIK DEĞİŞTİRİLDİ! Yeni bir sivil kıyafetine büründün!")
	var rand_idx = randi() % 6
	rpc("net_apply_disguise", rand_idx)

# 🍵 Başkan: Halka Keyif Çayı Fırlatma (Halk Kalkanı & +%2.5 Oy)
func _execute_president_throw_tea():
	if tea_cooldown > 0:
		_show_temp_prompt("⏳ Çay Kolisi Hazırlanıyor! (%.1f sn)" % tea_cooldown)
		return
	tea_cooldown = 6.0
	_show_temp_prompt("🍵 KEYİF ÇAYI FIRLATILDI! (+2.5% Seçim Oyu!)")
	_animate_hand_action()
	trigger_camera_shake(0.2, 0.12)
	
	var throw_dir = -camera.global_transform.basis.z.normalized() if camera else Vector3(0, 0, -1)
	var mn = get_node_or_null("/root/main")
	if mn:
		if mn.has_method("adjust_poll_score"):
			mn.adjust_poll_score(2.5, "🍵 Keyif Çayı Dağıtıldı (+2.5%)")
		if mn.has_method("trigger_crowd_cheer"):
			mn.rpc("trigger_crowd_cheer", global_position, 20.0)
		if mn.has_method("spawn_flying_tea"):
			mn.rpc("spawn_flying_tea", global_position + Vector3(0, 1.2, 0), throw_dir)
	_update_weapon_hud()


# 🔫 3. Şahıs Silah Görünürlüğü (Ateş Edince Açığa Çıkma)
@rpc("any_peer", "call_local")
func net_set_weapon_exposed(exposed: bool):
	is_weapon_exposed = exposed
	if third_person_weapon:
		third_person_weapon.visible = exposed

# 🗑️ Suikastçı: Silahı Yere Atıp Masum Sivile Dönme (G Tuşu)
func _execute_assassin_drop_weapon():
	if not is_weapon_exposed:
		_show_temp_prompt("ℹ️ Silahın zaten gizli, açığa çıkmadın.")
		return
	rpc("net_set_weapon_exposed", false)
	pistol_ammo = 0
	_show_temp_prompt("🗑️ SİLAHI YERE ATTIN! Elin temizlendi, tekrar masum sivil gibi gizlendin.")
	_update_weapon_hud()



func _on_volume_slider_changed(val: float):
	Global.set_volume(val)

# ===================================================
# 💥 GERİ BİLDİRİM SİSTEMİ
# ===================================================

# 📷 Kamera Titremesi — intensity: 0.0-1.0, duration sn
func trigger_camera_shake(intensity: float = 0.4, duration: float = 0.3):
	if not is_multiplayer_authority(): return
	_shake_intensity = intensity
	_shake_timer = duration

# 🔴 Ekran Kırmızı Flash (vurulma hissi)
func trigger_hit_flash(alpha: float = 0.45, duration: float = 0.18):
	if not is_multiplayer_authority(): return
	if not _hit_flash_node: return
	_hit_flash_node.color = Color(1, 0.05, 0.05, alpha)
	if sfx_hit_impact and not sfx_hit_impact.playing:
		sfx_hit_impact.play()
	get_tree().create_timer(duration).timeout.connect(func():
		if _hit_flash_node:
			_hit_flash_node.color = Color(1, 0, 0, 0)
	)

# 💓 Kalp Atışı — Başkan tehlikede (suikastçı 18m içinde)
func _update_heartbeat(delta: float):
	if not is_multiplayer_authority(): return
	if current_role != "PRESIDENT" or is_game_over:
		if _heartbeat_active:
			_heartbeat_active = false
			if sfx_heartbeat: sfx_heartbeat.volume_db = -80.0
		return

	var assassin_nearby = false
	var closest_dist = 999.0
	for node in get_tree().get_nodes_in_group("players"):
		if node and node != self and node.get("current_role") == "ASSASSIN":
			var d = global_position.distance_to(node.global_position)
			if d < closest_dist:
				closest_dist = d

	if closest_dist < 18.0:
		assassin_nearby = true
		var t = clamp(1.0 - (closest_dist / 18.0), 0.0, 1.0)
		_heartbeat_interval = lerp(1.2, 0.45, t)
		if sfx_heartbeat:
			sfx_heartbeat.volume_db = lerp(-12.0, 0.0, t)
	elif mission_state == 2 and not mission_done[2]:
		assassin_nearby = true
		_heartbeat_interval = 1.0
		if sfx_heartbeat: sfx_heartbeat.volume_db = -10.0

	_heartbeat_active = assassin_nearby

	if _heartbeat_active:
		_heartbeat_timer -= delta
		if _heartbeat_timer <= 0.0:
			_heartbeat_timer = _heartbeat_interval
			if sfx_heartbeat and not sfx_heartbeat.playing:
				sfx_heartbeat.play()
	else:
		if sfx_heartbeat: sfx_heartbeat.volume_db = -80.0

# 👣 Adım Sesi — yürürken periyodik
func _update_footsteps(delta: float, is_moving: bool):
	if not is_multiplayer_authority(): return
	if not is_moving or not is_on_floor() or drone_mode:
		_footstep_timer = 0.0
		return
	var step_interval = 0.38 if sprint_active else 0.52
	_footstep_timer += delta
	if _footstep_timer >= step_interval:
		_footstep_timer = 0.0
		if sfx_footstep and not sfx_footstep.playing:
			sfx_footstep.pitch_scale = randf_range(0.88, 1.12)
			sfx_footstep.play()

const CAMERA_BASE_POS = Vector3(0, 1.55, -0.1)

# 🎥 Kamera Titremesi İşleme (_physics_process'te çağrılır)
func _process_camera_shake(delta: float):
	if not is_multiplayer_authority() or not camera: return
	if _shake_timer > 0:
		_shake_timer -= delta
		var shake = _shake_intensity * (_shake_timer / 0.3)
		camera.position = CAMERA_BASE_POS + Vector3(
			randf_range(-shake, shake) * 0.06,
			randf_range(-shake, shake) * 0.06,
			0.0
		)
	else:
		_shake_intensity = 0.0
		camera.position = CAMERA_BASE_POS


func _update_player_animation():
	if not anim_player: return
	var horiz_speed = Vector3(velocity.x, 0, velocity.z).length()
	if not is_on_floor():
		if anim_player.current_animation != "jump":
			anim_player.play("jump")
	elif horiz_speed > 0.2:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
		anim_player.speed_scale = clamp(horiz_speed / 2.5, 0.8, 2.5)
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		anim_player.speed_scale = 1.0

func _process_sniper_aiming(delta: float):
	if not is_multiplayer_authority(): return
	
	if current_role == "ASSASSIN" and selected_slot == 2 and pistol_ammo > 0:
		_aim_check_timer -= delta
		if _aim_check_timer <= 0.0:
			_aim_check_timer = 0.18
			if raycast and raycast.is_colliding():
				var col = raycast.get_collider()
				if col and is_instance_valid(col) and col.get("current_role") == "PRESIDENT":
					col.rpc("on_sniper_aim_detected", global_position)
					
	if _warning_timer > 0.0:
		_warning_timer -= delta
		if _warning_overlay_node:
			var pulse = (sin(Time.get_ticks_msec() * 0.025) + 1.0) * 0.5
			_warning_overlay_node.color = Color(1.0, 0.2, 0.1, pulse * 0.45)
			_warning_overlay_node.show()
		if _warning_timer <= 0.0:
			if _warning_overlay_node: _warning_overlay_node.hide()

@rpc("any_peer", "call_local")
func on_sniper_aim_detected(from_pos: Vector3):
	if not is_multiplayer_authority() or current_role != "PRESIDENT": return
	_warning_timer = 1.8
	if sfx_warning and not sfx_warning.playing:
		sfx_warning.play()
	_show_temp_prompt("🚨 DİKKAT! SANA NİŞAN ALINIYOR! [3] ÇELİK ÇANTAYI KALDIR!")

func defend_against_bullet() -> bool:
	if selected_slot == 3 or has_briefcase_shield:
		has_briefcase_shield = false
		if sfx_clang: sfx_clang.play()
		trigger_camera_shake(0.9, 0.45)
		_show_temp_prompt("🛡️ ÇELİK ÇANTA MERMİYİ ENGELLEDİ! ZIRH KIRILDI!")
		var mn = get_node_or_null("/root/main")
		if mn and mn.has_method("adjust_poll_score"):
			mn.rpc("adjust_poll_score", 4.5, "🛡️ Çelik Çanta Savunması (+4.5%)")
		_update_weapon_hud()
		return true
	return false


# 🔪 Gerçekçi Çok Aşamalı Bıçak Savurma / Kesme Animasyonu
func _animate_knife_slash():
	if not hand_anchor: return
	var tw = create_tween().set_parallel(false)
	
	# 1. Hazırlık: Geriye çekilip havaya kalkış (0.04s)
	tw.tween_property(hand_anchor, "position", Vector3(0.42, -0.12, -0.34), 0.04).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees", Vector3(20, 25, -20), 0.04)
	
	# 2. Şimşek Hızında Çapraz Kesme / Savurma (0.08s)
	tw.tween_property(hand_anchor, "position", Vector3(-0.16, -0.36, -0.62), 0.08).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees", Vector3(-40, -55, 45), 0.08)
	
	# 3. İleri Saplama / Takip (0.05s)
	tw.tween_property(hand_anchor, "position", Vector3(0.08, -0.26, -0.58), 0.05).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees", Vector3(-10, -15, 10), 0.05)
	
	# 4. Dinlenme Pozisyonuna Yumuşak Geri Dönüş (0.16s)
	tw.tween_property(hand_anchor, "position", _hand_def_pos, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees", _hand_def_rot, 0.16)
	
	_spawn_knife_slash_arc()

# 🌟 Bıçak Kavis İzi Efekti (Slash Arc Ribbon Effect)
func _spawn_knife_slash_arc():
	if not camera: return
	var arc = MeshInstance3D.new()
	var t_mesh = TorusMesh.new()
	t_mesh.inner_radius = 0.28
	t_mesh.outer_radius = 0.42
	arc.mesh = t_mesh
	
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(0.85, 0.95, 1.0, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.85, 1.0)
	mat.emission_energy_multiplier = 4.0
	arc.material_override = mat
	
	arc.position = Vector3(0.08, -0.15, -0.45)
	arc.rotation_degrees = Vector3(35, -45, 65)
	arc.scale = Vector3(0.3, 0.3, 0.3)
	camera.add_child(arc)
	
	var arc_tw = arc.create_tween()
	arc_tw.tween_property(arc, "scale", Vector3(1.2, 1.2, 1.2), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	arc_tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.14)
	arc_tw.tween_callback(arc.queue_free)

# 🔫 Silah Geri Tepme (Recoil) Animasyonu
func _animate_gun_recoil(is_taser: bool = false):
	if not hand_anchor: return
	var tw = create_tween().set_parallel(false)
	var kick_z = 0.12 if not is_taser else 0.08
	var kick_rot = -18.0 if not is_taser else -10.0
	
	tw.tween_property(hand_anchor, "position:z", _hand_def_pos.z + kick_z, 0.04).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees:x", kick_rot, 0.04)
	
	tw.tween_property(hand_anchor, "position:z", _hand_def_pos.z, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(hand_anchor, "rotation_degrees:x", _hand_def_rot.x, 0.15)

# 💥 3D Parlayan Mermi Çizgisi & Namlu Alevi (Tracer & Impact)
func _spawn_bullet_tracer(start_pos: Vector3, target_pos: Vector3, is_taser: bool = false):
	var root_scene = get_tree().current_scene
	if not root_scene: return
	
	# 1. Namlu Alevi Işığı
	var flash = OmniLight3D.new()
	flash.global_position = start_pos
	flash.light_color = Color(0.1, 0.85, 1.0) if is_taser else Color(1.0, 0.8, 0.3)
	flash.light_energy = 5.0
	flash.omni_range = 4.0
	root_scene.add_child(flash)
	
	var flash_tw = flash.create_tween()
	flash_tw.tween_property(flash, "light_energy", 0.0, 0.05)
	flash_tw.tween_callback(flash.queue_free)
	
	# 2. 3D Parlayan Mermi Modeli
	var tracer = MeshInstance3D.new()
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = 0.03 if not is_taser else 0.045
	cap_mesh.height = 0.75 if not is_taser else 0.5
	tracer.mesh = cap_mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.2, 0.9, 1.0) if is_taser else Color(1.0, 0.85, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.9, 1.0) if is_taser else Color(1.0, 0.75, 0.15)
	mat.emission_energy_multiplier = 6.0
	tracer.material_override = mat
	
	tracer.global_position = start_pos
	tracer.look_at(target_pos, Vector3.UP)
	tracer.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	root_scene.add_child(tracer)
	
	var dist = start_pos.distance_to(target_pos)
	var speed = 95.0 if not is_taser else 50.0
	var travel_time = clamp(dist / speed, 0.03, 0.35)
	
	var tw = tracer.create_tween()
	tw.tween_property(tracer, "global_position", target_pos, travel_time).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback(func():
		_spawn_bullet_impact_sparks(target_pos, is_taser)
		tracer.queue_free()
	)

# ⚡ Mermi Çarpma Kıvılcımları & Toz Efekti
func _spawn_bullet_impact_sparks(impact_pos: Vector3, is_taser: bool = false):
	var root_scene = get_tree().current_scene
	if not root_scene: return
	
	for i in range(6):
		var spark = MeshInstance3D.new()
		var s_box = BoxMesh.new()
		s_box.size = Vector3(0.04, 0.04, 0.04)
		spark.mesh = s_box
		
		var s_mat = StandardMaterial3D.new()
		s_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		s_mat.albedo_color = Color(0.1, 0.9, 1.0) if is_taser else Color(1.0, 0.8, 0.2)
		spark.material_override = s_mat
		spark.global_position = impact_pos
		root_scene.add_child(spark)
		
		var rand_dir = Vector3(randf_range(-0.6, 0.6), randf_range(0.2, 0.8), randf_range(-0.6, 0.6))
		var sp_tw = spark.create_tween()
		sp_tw.tween_property(spark, "global_position", impact_pos + rand_dir, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		sp_tw.parallel().tween_property(spark, "scale", Vector3.ZERO, 0.18)
		sp_tw.tween_callback(spark.queue_free)

@rpc("any_peer", "call_remote", "unreliable")
func net_spawn_bullet_tracer(start_pos: Vector3, target_pos: Vector3, is_taser: bool = false):
	_spawn_bullet_tracer(start_pos, target_pos, is_taser)
