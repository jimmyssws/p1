extends CharacterBody3D

enum NpcState { WANDER, WATCH_STAGE, CHAT, PANIC, CHEER, GO_TO_WC }

const WALK_SPEED = 2.0
const RUN_SPEED = 4.8

var current_state = NpcState.WANDER
var direction = Vector3.ZERO
var state_timer = 0.0
var panic_source = Vector3.ZERO

@onready var char_model = $CharacterModel if has_node("CharacterModel") else null
@onready var body_mesh = $CharacterModel/Body if has_node("CharacterModel/Body") else null

const CIVILIAN_COLORS = [
	Color(0.2, 0.2, 0.25),  # Koyu Füme
	Color(0.35, 0.35, 0.4), # Açık Gri Ceket
	Color(0.15, 0.25, 0.35),# Koyu Mavi
	Color(0.35, 0.25, 0.2), # Kahve
	Color(0.25, 0.35, 0.3), # Haki
	Color(0.45, 0.2, 0.25)  # Bordo
]


var sfx_voice: AudioStreamPlayer3D = null
var voice_cooldown: float = 0.0
const GIBBERISH_SOUNDS = [
	"res://sounds/silly_chatter_1.wav",
	"res://sounds/silly_chatter_2.wav",
	"res://sounds/silly_chatter_3.wav"
]

func _setup_npc_voice():
	sfx_voice = AudioStreamPlayer3D.new()
	sfx_voice.unit_size = 10.0
	sfx_voice.max_distance = 35.0
	sfx_voice.volume_db = 6.0
	sfx_voice.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	add_child(sfx_voice)

func _play_random_gibberish():
	if not sfx_voice or voice_cooldown > 0.0: return
	voice_cooldown = randf_range(4.0, 12.0)
	var snd_path = GIBBERISH_SOUNDS[randi() % GIBBERISH_SOUNDS.size()]
	var stream = load(snd_path) as AudioStreamWAV
	if stream:
		sfx_voice.stream = stream
		sfx_voice.pitch_scale = randf_range(0.85, 1.25)
		sfx_voice.play()

func _ready():
	_setup_npc_voice()
	if body_mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = CIVILIAN_COLORS[randi() % CIVILIAN_COLORS.size()]
		mat.roughness = 0.7
		body_mesh.set_surface_override_material(0, mat)
		
	_decide_next_behavior()

func _physics_process(delta):
	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0.0:
			rotation_degrees.z = 0.0
			is_stunned = false
			current_state = NpcState.PANIC
			state_timer = 8.0
		return

	# 🛑 POLİS 'HERKES DURSUN!' EMRİ (Olduğu Yerde Çakılma)
	if is_police_frozen:
		freeze_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= 9.8 * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		if freeze_timer <= 0.0:
			is_police_frozen = false
			_decide_next_behavior()
		return

	if voice_cooldown > 0.0: voice_cooldown -= delta
	if not multiplayer.is_server(): return 

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	
	state_timer -= delta
	if state_timer <= 0 and current_state != NpcState.PANIC:
		_decide_next_behavior()
		
	var speed = RUN_SPEED if current_state == NpcState.PANIC else WALK_SPEED
	
	# 🛡️ Güçlendirilmiş Korumadan Kaçış & Yol Açma (Menzil: 5.5m, Hızlı Reaksiyon)
	var avoid_vec = Vector3.ZERO
	var is_avoiding = false
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p and is_instance_valid(p) and p.get("current_role") == "GUARD":
			var d_vec = global_position - p.global_position
			d_vec.y = 0
			var dist = d_vec.length()
			if dist < 5.2 and dist > 0.1:
				is_avoiding = true
				var push_factor = (5.2 - dist) / 5.2
				if p.get("sprint_active"):
					push_factor *= 2.8
				avoid_vec += d_vec.normalized() * push_factor * 3.2

	if current_state == NpcState.PANIC:
		var flee_dir = (global_position - panic_source)
		flee_dir.y = 0
		if flee_dir.length_squared() > 0.01:
			direction = flee_dir.normalized()
		if state_timer <= 0:
			current_state = NpcState.WANDER
			_decide_next_behavior()

	if is_avoiding and avoid_vec.length_squared() > 0.01:
		var avoid_dir = avoid_vec.normalized()
		var avoid_spd = RUN_SPEED * 1.3
		velocity.x = avoid_dir.x * avoid_spd
		velocity.z = avoid_dir.z * avoid_spd
		if char_model:
			var target_angle = atan2(avoid_dir.x, avoid_dir.z)
			char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 15.0 * delta)
		move_and_slide()
	elif direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if char_model:
			var target_angle = atan2(direction.x, direction.z)
			char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 10.0 * delta)
		move_and_slide()
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			move_and_slide()
func _decide_next_behavior():
	if current_state == NpcState.CHAT or randf() < 0.35:
		_play_random_gibberish()
	var roll = randf()
	
	if roll < 0.40:
		# 1. Sahne Önüne Toplan (Mitingi Dinle)
		current_state = NpcState.WATCH_STAGE
		var stage_front = Vector3(randf_range(-8, 8), 0, randf_range(-15, -9))
		var to_stage = (stage_front - global_position)
		to_stage.y = 0
		if to_stage.length() > 2.5:
			direction = to_stage.normalized()
			state_timer = randf_range(3.5, 6.5)
		else:
			direction = Vector3.ZERO
			state_timer = randf_range(4.0, 9.0)
			
	elif roll < 0.65:
		# 2. Rastgele Gezin
		current_state = NpcState.WANDER
		var angle = randf() * PI * 2
		direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		state_timer = randf_range(2.5, 5.0)
		
	elif roll < 0.85:
		# 3. Durup Sohbet Et
		current_state = NpcState.CHAT
		direction = Vector3.ZERO
		state_timer = randf_range(3.0, 7.0)
		
	else:
		# 4. 🚻 Portatif WC'ye Git & Kuyruğa Gir
		current_state = NpcState.GO_TO_WC
		var pick_wc = randf() < 0.5
		var wc_pos = Vector3(-26.0, 0, 14.5 + randf_range(0, 3.5)) if pick_wc else Vector3(26.0, 0, 14.5 + randf_range(0, 3.5))
		var to_wc = (wc_pos - global_position)
		to_wc.y = 0
		if to_wc.length() > 2.0:
			direction = to_wc.normalized()
			state_timer = randf_range(5.0, 8.0)
		else:
			direction = Vector3.ZERO
			state_timer = randf_range(4.0, 7.0) # Kuyrukta bekleme
@rpc("any_peer", "call_local")
func on_panic_triggered(source: Vector3, radius: float):
	if global_position.distance_to(source) <= radius:
		current_state = NpcState.PANIC
		panic_source = source
		state_timer = randf_range(2.5, 4.5)

@rpc("any_peer", "call_local")
func on_stampede_triggered(start_gate: Vector3, target_area: Vector3):
	current_state = NpcState.PANIC
	var rush_target = target_area + Vector3(randf_range(-6, 6), 0, randf_range(-4, 4))
	direction = (rush_target - global_position).normalized()
	state_timer = randf_range(4.0, 7.0)

func trigger_cheer(duration: float):
	current_state = NpcState.CHEER
	state_timer = duration
	direction = Vector3.ZERO

var is_stunned: bool = false
var is_police_frozen: bool = false
var freeze_timer: float = 0.0
var stun_time_left: float = 0.0

@rpc("any_peer", "call_local")
func apply_stun(duration: float = 4.5):
	is_stunned = true
	stun_time_left = duration
	rotation_degrees.z = 85.0 # Yere seril

func search_body() -> Dictionary:
	var items = ["🥪 Peynirli Sandviç", "🔑 Ev Anahtarı", "🧻 Islak Mendil", "🥤 Soğuk Çay", "📱 Eski Tuşlu Telefon"]
	return {
		"is_assassin": false,
		"found_item": items[randi() % items.size()]
	}


@rpc("any_peer", "call_local")
func on_guard_freeze_command():
	if is_stunned or current_state == NpcState.PANIC: return
	
	# Hızlı ve organik gecikme (0.1 sn - 0.7 sn)
	var delay = randf_range(0.1, 0.7)
	await get_tree().create_timer(delay).timeout
	if is_stunned or current_state == NpcState.PANIC: return
	
	# %85 ihtimalle olduğu yerde çakılır ve korumaya bakar
	if randf() < 0.85:
		is_police_frozen = true
		freeze_timer = 4.2
		direction = Vector3.ZERO
		velocity.x = 0.0
		velocity.z = 0.0
		_play_random_gibberish()
		
		# Korumaya doğru dön
		var guards = get_tree().get_nodes_in_group("players")
		for g in guards:
			if g and is_instance_valid(g) and g.get("current_role") == "GUARD":
				var look_vec = g.global_position - global_position
				look_vec.y = 0
				if look_vec.length_squared() > 0.1 and char_model:
					char_model.rotation.y = atan2(look_vec.x, look_vec.z)
				break
	else:
		# %15 Huysuz/İsyankar sivil: Yürümeye devam eder ve söylenir
		state_timer = 3.5
		_play_random_gibberish()
