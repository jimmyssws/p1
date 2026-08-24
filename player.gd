extends CharacterBody3D

const SPEED = 1.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var progress_bar = $HUD/ProgressBar
@onready var anim_player = $AnimationPlayer
@onready var role_panel = $HUD/RoleCardPanel if has_node("HUD/RoleCardPanel") else null
@onready var role_title = $HUD/RoleCardPanel/RoleTitle if has_node("HUD/RoleCardPanel/RoleTitle") else null
@onready var role_desc = $HUD/RoleCardPanel/RoleDesc if has_node("HUD/RoleCardPanel/RoleDesc") else null
@onready var action_prompt = $HUD/ActionPrompt if has_node("HUD/ActionPrompt") else null

var task_progress: float = 0.0
var current_role: String = "GUARD" 
var is_game_over: bool = false # Oyunun bitip bitmediğini veya sersemleme durumunu tutar
var assassin_cooldown: float = 0.0 # Suikastçı saldırı bekleme süresi

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
		
	position = Vector3(0, 5, 0)
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Sunucu bu fonksiyonu çağırarak oyuncuya rolünü ve modelini yükler
@rpc("any_peer", "call_local")
func assign_role(role_name: String):
	current_role = role_name
	
	# Modelleri temizle
	if has_node("PresidentModel"): $PresidentModel.hide()
	if has_node("AssassinModel"): $AssassinModel.hide()
	if has_node("MeshInstance3D"): $MeshInstance3D.hide()
	
	if current_role == "PRESIDENT":
		if has_node("PresidentModel"):
			$PresidentModel.show()
			$AnimationPlayer.root_node = $PresidentModel.get_path()
	elif current_role == "ASSASSIN":
		if has_node("AssassinModel"):
			$AssassinModel.show()
			$AnimationPlayer.root_node = $AssassinModel.get_path()
	elif current_role == "GUARD":
		if has_node("AssassinModel"):
			$AssassinModel.show()
			$AnimationPlayer.root_node = $AssassinModel.get_path()

	if is_multiplayer_authority():
		_display_role_card(role_name)

# Oyuncunun ekranına 4.5 saniye boyunca şık bir rol kartı gösterir
func _display_role_card(role_name: String):
	if not role_panel or not role_title or not role_desc: return
	
	if role_name == "PRESIDENT":
		role_title.text = "🏛️ SENİN ROLÜN: BAŞKAN"
		role_desc.text = "Görevin: Miting kürsüsüne (TaskBox) git, konuşmayı tamamla!"
	elif role_name == "ASSASSIN":
		role_title.text = "🗡️ SENİN ROLÜN: SUİKASTÇI"
		role_desc.text = "Görevin: Sivil gibi davran, gizlice yaklaşıp [E] ile Başkanı indir!"
	elif role_name == "GUARD":
		role_title.text = "🛡️ SENİN ROLÜN: KORUMA"
		role_desc.text = "Görevin: Başkanı koru, şüphelilerin üstünü [E] ile ara!"
		
	role_panel.show()
	await get_tree().create_timer(4.5).timeout
	if role_panel:
		role_panel.hide()

# Sersemletme / Ceza fonksiyonu (Ağ üzerinden herkes birbirini sersemletebilir)
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
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# --- 🗡️ SUİKASTÇI SALDIRI & İNFAZ MEKANİĞİ ---
	if current_role == "ASSASSIN" and event.is_action_pressed("interact"):
		if assassin_cooldown > 0:
			_show_temp_prompt("⏳ Bıçak Hazır Değil! (%.1f sn)" % assassin_cooldown)
			return
			
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target is CharacterBody3D:
				if "current_role" in target:
					# 1. Hedef BAŞKAN ise -> SUİKASTÇI KAZANDI!
					if target.current_role == "PRESIDENT":
						get_node("/root/main").rpc("net_game_over", "BAŞKAN SUİKASTE UĞRADI!
🗡️ SUİKASTÇI KAZANDI!")
					# 2. Hedef KORUMA ise -> Korumayı 4 saniye sersemletir!
					elif target.current_role == "GUARD":
						target.rpc("apply_stun_effect", 4.0, "SUİKASTÇI SALDIRISINA UĞRADINIZ!
4 Saniye Sersemsiniz!")
						assassin_cooldown = 4.0
						_show_temp_prompt("💥 KORUMAYI SERSEMLETTİNİZ! (4 sn)")
				else:
					# 3. Hedef Masum SİVİL (NPC) ise -> Sivili indirir, ama 4 sn bekleme alır
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
	
	# Cooldown sayacı
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
		anim_player.play("walk")
		
		var target_angle = atan2(direction.x, direction.z)
		
		if has_node("PresidentModel") and $PresidentModel.visible:
			$PresidentModel.global_rotation.y = lerp_angle($PresidentModel.global_rotation.y, target_angle, 15 * delta)
		elif has_node("AssassinModel") and $AssassinModel.visible:
			$AssassinModel.global_rotation.y = lerp_angle($AssassinModel.global_rotation.y, target_angle, 15 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		anim_player.play("idle")
		
		if has_node("PresidentModel") and $PresidentModel.visible:
			$PresidentModel.global_rotation.y = lerp_angle($PresidentModel.global_rotation.y, global_rotation.y + PI, 10 * delta)
		elif has_node("AssassinModel") and $AssassinModel.visible:
			$AssassinModel.global_rotation.y = lerp_angle($AssassinModel.global_rotation.y, global_rotation.y + PI, 10 * delta)

	move_and_slide()

	# --- 🏛️ BAŞKAN MİTİNG GÖREV KONTROLÜ ---
	if current_role == "PRESIDENT":
		if Input.is_action_pressed("interact") and raycast.is_colliding() and raycast.get_collider().name == "TaskBox":
			progress_bar.show()
			task_progress += 20.0 * delta # 5 saniyede mitingi tamamlar
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
			task_progress += 33.0 * delta # 3 saniyede arar
			progress_bar.value = task_progress
			
			if task_progress >= 100.0:
				task_progress = 0.0
				progress_bar.hide()
				
				if "current_role" in suspect:
					# Suikastçı yakalandı!
					if suspect.current_role == "ASSASSIN":
						get_node("/root/main").rpc("net_game_over", "SUİKASTÇI YAKALANDI!
🛡️ KORUMALAR KAZANDI!")
					else:
						apply_stun_effect(3.0, "MASUM BİRİNİ ARADINIZ!
3 Saniye Cezalısınız!")
				else:
					# Masum NPC Sivil arandı
					apply_stun_effect(3.0, "MASUM VATANDAŞI TACİZ ETTİNİZ!
3 Saniye Cezalısınız!")
		else:
			if not Input.is_action_pressed("interact") and not is_game_over:
				task_progress = 0.0
				progress_bar.hide()
