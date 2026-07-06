extends CharacterBody3D

const SPEED = 1.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var progress_bar = $HUD/ProgressBar
@onready var anim_player = $AnimationPlayer

var task_progress = 0.0
var current_role: String = "GUARD" 
var is_game_over: bool = false # Oyunun bitip bitmediğini tutan kilit değişken

func _enter_tree():
	var id = name.to_int()
	set_multiplayer_authority(id)
	$MultiplayerSynchronizer.set_multiplayer_authority(id)

func _ready():
	# GÜVENLİ GİZLEME
	if has_node("HUD/ProgressBar"): $HUD/ProgressBar.hide()
	if has_node("HUD/GameOverPanel"): $HUD/GameOverPanel.hide()

	if not is_multiplayer_authority(): 
		return
		
	position = Vector3(0, 5, 0)
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Sunucu bu fonksiyonu çağırarak oyuncuya rolünü ve rengini yükler
@rpc("any_peer", "call_local")
func assign_role(role_name: String):
	current_role = role_name
	
	# Önce garanti olsun diye tüm modelleri gizliyoruz
	if has_node("PresidentModel"): $PresidentModel.hide()
	if has_node("AssassinModel"): $AssassinModel.hide()
	if has_node("MeshInstance3D"): $MeshInstance3D.hide()
	
	# Rolümüze göre modeli açıyoruz ve ANİMASYON BEYNİNİ O MODELE BAĞLIYORUZ
	if current_role == "PRESIDENT":
		if has_node("PresidentModel"):
			$PresidentModel.show()
			$AnimationPlayer.root_node = $PresidentModel.get_path() # Kemikleri Başkanda ara!
			
	elif current_role == "ASSASSIN":
		if has_node("AssassinModel"):
			$AssassinModel.show()
			$AnimationPlayer.root_node = $AssassinModel.get_path() # Kemikleri Suikastçıda ara!
			
	elif current_role == "GUARD":
		if has_node("AssassinModel"):
			$AssassinModel.show()
			$AnimationPlayer.root_node = $AssassinModel.get_path() # Kemikleri Korumada ara!
func local_game_over(message: String):
	is_game_over = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Fareyi serbest bırak
	
	if has_node("HUD/GameOverPanel"):
		$HUD/GameOverPanel/WinnerLabel.text = message
		$HUD/GameOverPanel.show() # Paneli ekrana getir

func _input(event):
	if not is_multiplayer_authority(): return
	if is_game_over: return # Oyun bittiyse etrafa bakmayı durdur
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# SUİKASTÇI SALDIRI KONTROLÜ
	if event.is_action_pressed("interact"):
		if raycast.is_colliding():
			var hit_object = raycast.get_collider()
			
			if current_role == "ASSASSIN" and hit_object is CharacterBody3D and hit_object.current_role == "PRESIDENT":
				# Merkez telsiz üzerinden oyunu bitiriyoruz
				get_node("/root/main").rpc("net_game_over", "BAŞKAN SUİKASTE UĞRADI!\nSUİKASTÇI KAZANDI!")

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if is_game_over: return # Oyun bittiyse yürümeyi ve fiziği durdur

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		# 1. Yürüme Hızı Ayarı
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		anim_player.play("walk")
		
		# 2. Yön Hesaplama (Eğer karakter yine geri geri yürürse, formülün sonuna + PI ekle)
		# Örnek: var target_angle = atan2(direction.x, direction.z) + PI
		var target_angle = atan2(direction.x, direction.z)
		
		# 3. Yüzünü Dönme İşlemi (Hangi model görünürse onu döndür)
		if has_node("PresidentModel") and $PresidentModel.visible:
			$PresidentModel.global_rotation.y = lerp_angle($PresidentModel.global_rotation.y, target_angle, 15 * delta)
		elif has_node("AssassinModel") and $AssassinModel.visible:
			$AssassinModel.global_rotation.y = lerp_angle($AssassinModel.global_rotation.y, target_angle, 15 * delta)
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		anim_player.play("idle")
		
		# Karakter durduğunda yüzünü yavaşça kameranın baktığı düz yöne (gövdeye) eşitle
		if has_node("PresidentModel") and $PresidentModel.visible:
			$PresidentModel.global_rotation.y = lerp_angle($PresidentModel.global_rotation.y, global_rotation.y + PI, 10 * delta)
		elif has_node("AssassinModel") and $AssassinModel.visible:
			$AssassinModel.global_rotation.y = lerp_angle($AssassinModel.global_rotation.y, global_rotation.y + PI, 10 * delta)

	move_and_slide()

	# BAŞKAN GÖREV KONTROLÜ
	if current_role == "PRESIDENT":
		if Input.is_action_pressed("interact") and raycast.is_colliding() and raycast.get_collider().name == "TaskBox":
			progress_bar.show()
			task_progress += 20.0 * delta
			progress_bar.value = task_progress
			
			if task_progress >= 100.0:
				get_node("/root/main").rpc("net_game_over", "MİTİNG TAMAMLANDI!\nBAŞKAN VE KORUMALAR KAZANDI!")
				task_progress = 0.0
				progress_bar.hide()
		else:
			progress_bar.hide()

	# --- KORUMA ÜST ARAMA KONTROLÜ ---
	if current_role == "GUARD":
		# E'ye basıyorsam, oyun bitmediyse ve önümde bir canlı varsa (oyuncu veya NPC)
		if Input.is_action_pressed("interact") and raycast.is_colliding() and (raycast.get_collider() is CharacterBody3D):
			var suspect = raycast.get_collider()
			
			progress_bar.show()
			task_progress += 33.0 * delta # 3 saniyede arar
			progress_bar.value = task_progress
			
			if task_progress >= 100.0:
				task_progress = 0.0
				progress_bar.hide()
				
				# ÖNEMLİ KONTROL: Baktığımız şey gerçek bir OYUNCU mu yoksa NPC mi?
				if "current_role" in suspect:
					# Eğer bulduğumuz kişi cidden Suikastçıysa Korumalar kazanır
					if suspect.current_role == "ASSASSIN":
						get_node("/root/main").rpc("net_game_over", "SUİKASTÇI YAKALANDI!\nKORUMALAR KAZANDI!")
					# Eğer yanlışlıkla BAŞKAN'ı aradıysak (büyük ayıp) veya diğer korumayı aradıysak
					else:
						_apply_wrong_search_penalty("MASUM BİRİNİ ARADINIZ!\n3 Saniye Cezalısınız!")
				else:
					# Eğer baktığımız şey bir NPC (Sivil) ise cezayı kes!
					_apply_wrong_search_penalty("MASUM VATANDAŞI TACİZ ETTİNİZ!\n3 Saniye Cezalısınız!")
		else:
			# Elini tuştan çekerse bar sıfırlansın
			if not Input.is_action_pressed("interact") and not is_game_over:
				task_progress = 0.0
				progress_bar.hide()
				
				# Yanlış arama yapan korumayı donduran ve ekranına uyarı basan fonksiyon
func _apply_wrong_search_penalty(penalty_message: String):
	is_game_over = true # Karakterin yürümesini ve etrafa bakmasını geçici olarak dondurur
	progress_bar.hide()
	task_progress = 0.0
	
	if has_node("HUD/GameOverPanel"):
		$HUD/GameOverPanel/WinnerLabel.text = penalty_message
		$HUD/GameOverPanel.show()
		
		# 3 saniye bekle ve sonra cezayı kaldır
		await get_tree().create_timer(3.0).timeout
		
		# Eğer o 3 saniye içinde ana oyun zaten bitmediyse karakteri çöz
		if $HUD/GameOverPanel/WinnerLabel.text == penalty_message:
			$HUD/GameOverPanel.hide()
			is_game_over = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
