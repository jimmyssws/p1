extends CharacterBody3D

const SPEED = 1.0
var direction = Vector3.ZERO
var wander_timer = 0.0
@onready var anim_player = $AnimationPlayer

func _ready():

	# Rastgele bir yön seçerek başla
	_pick_random_direction()

func _physics_process(delta):
	# ÇOK ÖNEMLİ: Yapay zeka fiziğini sadece SERVER hesaplar, clientlar sadece izler
	if not multiplayer.is_server(): return 

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Zaman sayacı bittiyse yeni bir yöne dön
	wander_timer -= delta
	if wander_timer <= 0:
		_pick_random_direction()
		
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# NPC'nin yüzünü yürüdüğü yöne yumuşakça çevirme kodu:
		var target_angle = atan2(velocity.x, velocity.z)
		
		# EĞER TERS YÜRÜMEYE DEVAM EDERLERSE üstteki satırı şu şekilde değiştir:
		# var target_angle = atan2(velocity.x, velocity.z) + PI
		
		# NPC'nin içindeki modeli döndürüyoruz
		if has_node("AssassinModel"):
			$AssassinModel.global_rotation.y = lerp_angle($AssassinModel.global_rotation.y, target_angle, 10 * delta)
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	# NPC'nin hızı sıfırdan büyükse yürüyor demektir
	if velocity.length() > 0.1:
		anim_player.play("walk")
	else:
		anim_player.play("idle")

func _pick_random_direction():
	# Rastgele 360 derecelik bir açı seç
	var angle = randf() * PI * 2
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	wander_timer = randf_range(2.0, 5.0) # 2 ile 5 saniye arasında bir yöne yürüsün
	
	# %30 ihtimalle robot gibi sürekli yürümesin, olduğu yerde dursun/beklesin
	if randf() < 0.3:
		direction = Vector3.ZERO
