extends CharacterBody3D

const SPEED = 3.5
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var progress_bar = $HUD/ProgressBar
@onready var role_panel = $HUD/RoleCardPanel if has_node("HUD/RoleCardPanel") else null
@onready var role_title = $HUD/RoleCardPanel/RoleTitle if has_node("HUD/RoleCardPanel/RoleTitle") else null
@onready var role_desc = $HUD/RoleCardPanel/RoleDesc if has_node("HUD/RoleCardPanel/RoleDesc") else null
@onready var action_prompt = $HUD/ActionPrompt if has_node("HUD/ActionPrompt") else null
@onready var char_model = $CharacterModel if has_node("CharacterModel") else null
@onready var body_mesh = $CharacterModel/Body if has_node("CharacterModel/Body") else null
@onready var tie_mesh = $CharacterModel/Tie if has_node("CharacterModel/Tie") else null

var task_progress: float = 0.0
var current_role: String = "GUARD" 
var is_game_over: bool = false
var assassin_cooldown: float = 0.0

func _enter_tree():
	var id = name.to_int()
	set_multiplayer_authority(id)
	$MultiplayerSynchronizer.set_multiplayer_authority(id)

func _ready():
	if has_node("HUD/ProgressBar"): $HUD/ProgressBar.hide()
	if has_node("HUD/GameOverPanel"): $HUD/GameOverPanel.hide()
	if action_prompt: action_prompt.text = ""

	if not is_multiplayer_authority(): 
		return
		
	position = Vector3(0, 3, 0)
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

@rpc("any_peer", "call_local")
func assign_role(role_name: String):
	current_role = role_name
	
	if body_mesh:
		var mat = StandardMaterial3D.new()
		if current_role == "PRESIDENT":
			mat.albedo_color = Color(0.12, 0.25, 0.6) # Asil Başkan Laciverti
			if tie_mesh: tie_mesh.show()
		elif current_role == "ASSASSIN":
			mat.albedo_color = Color(0.2, 0.2, 0.25) # Sivil Koyu Ceket (Kamufle)
			if tie_mesh: tie_mesh.hide()
		elif current_role == "GUARD":
			mat.albedo_color = Color(0.18, 0.28, 0.22) # Koruma Koyu Haki/Gri
			if tie_mesh: tie_mesh.hide()
		body_mesh.set_surface_override_material(0, mat)

	if is_multiplayer_authority():
		_display_role_card(role_name)

func _display_role_card(role_name: String):
	if not role_panel or not role_title or not role_desc: return
	
	if role_name == "PRESIDENT":
		role_title.text = "🏛️ SENİN ROLÜN: BAŞKAN"
		role_desc.text = "Miting kürsüsüne (TaskBox) git, [E] ile konuşmayı tamamla!"
	elif role_name == "ASSASSIN":
		role_title.text = "🗡️ SENİN ROLÜN: SUİKASTÇI"
		role_desc.text = "Sivillerin arasına karış, gizlice yaklaşıp [E] ile Başkanı indir!"
	elif role_name == "GUARD":
		role_title.text = "🛡️ SENİN ROLÜN: KORUMA"
		role_desc.text = "Başkanı koru, şüphelilerin üstünü [E] ile ara!"
		
	role_panel.show()
	await get_tree().create_timer(4.5).timeout
	if role_panel:
		role_panel.hide()

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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if has_node("HUD/GameOverPanel"):
		$HUD/GameOverPanel/WinnerLabel.text = message
		$HUD/GameOverPanel.show()

func _input(event):
	if not is_multiplayer_authority(): return
	if is_game_over: return
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.004)
		camera.rotate_x(-event.relative.y * 0.004)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# --- 🗡️ SUİKASTÇI SALDIRI & İNFAZ ---
	if current_role == "ASSASSIN" and event.is_action_pressed("interact"):
		if assassin_cooldown > 0:
			_show_temp_prompt("⏳ Bıçak Hazır Değil! (%.1f sn)" % assassin_cooldown)
			return
			
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target is CharacterBody3D:
				if "current_role" in target:
					if target.current_role == "PRESIDENT":
						get_node("/root/main").rpc("net_game_over", "BAŞKAN SUİKASTE UĞRADI!
🗡️ SUİKASTÇI KAZANDI!")
					elif target.current_role == "GUARD":
						target.rpc("apply_stun_effect", 4.0, "SUİKASTÇI SALDIRISINA UĞRADINIZ!
4 Saniye Sersemsiniz!")
						assassin_cooldown = 4.0
						_show_temp_prompt("💥 KORUMAYI SERSEMLETTİNİZ! (4 sn)")
				else:
					target.queue_free()
					assassin_cooldown = 4.0
					_show_temp_prompt("⚠️ MASUM SİVİL VURULDU! (4 sn Bekleme)")

func _show_temp_prompt(msg: String):
	if action_prompt:
		action_prompt.text = msg
		await get_tree().create_timer(2.0).timeout
		if action_prompt.text == msg:
			action_prompt.text = ""

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if assassin_cooldown > 0:
		assassin_cooldown -= delta
		if assassin_cooldown < 0: assassin_cooldown = 0.0

	if is_game_over: return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if char_model:
			var target_angle = atan2(direction.x, direction.z)
			char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, target_angle, 15 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if char_model:
			char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, global_rotation.y, 10 * delta)

	move_and_slide()

	# --- 🏛️ BAŞKAN MİTİNG GÖREV KONTROLÜ ---
	if current_role == "PRESIDENT":
		if Input.is_action_pressed("interact") and raycast.is_colliding() and raycast.get_collider().name == "TaskBox":
			progress_bar.show()
			task_progress += 20.0 * delta
			progress_bar.value = task_progress
			
			if task_progress >= 100.0:
				get_node("/root/main").rpc("net_game_over", "MİTİNG TAMAMLANDI!
🏛️ BAŞKAN VE KORUMALAR KAZANDI!")
				task_progress = 0.0
				progress_bar.hide()
		else:
			if not Input.is_action_pressed("interact") and not is_game_over:
				progress_bar.hide()

	# --- 🛡️ KORUMA ÜST ARAMA KONTROLÜ ---
	if current_role == "GUARD":
		if Input.is_action_pressed("interact") and raycast.is_colliding() and (raycast.get_collider() is CharacterBody3D):
			var suspect = raycast.get_collider()
			
			progress_bar.show()
			task_progress += 33.0 * delta
			progress_bar.value = task_progress
			
			if task_progress >= 100.0:
				task_progress = 0.0
				progress_bar.hide()
				
				if "current_role" in suspect:
					if suspect.current_role == "ASSASSIN":
						get_node("/root/main").rpc("net_game_over", "SUİKASTÇI YAKALANDI!
🛡️ KORUMALAR KAZANDI!")
					else:
						apply_stun_effect(3.0, "MASUM BİRİNİ ARADINIZ!
3 Saniye Cezalısınız!")
				else:
					apply_stun_effect(3.0, "MASUM VATANDAŞI TACİZ ETTİNİZ!
3 Saniye Cezalısınız!")
		else:
			if not Input.is_action_pressed("interact") and not is_game_over:
				task_progress = 0.0
				progress_bar.hide()
