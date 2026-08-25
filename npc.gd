extends CharacterBody3D

enum NpcArchetype { STAGE_FANATIC, WC_QUEUE, BENCH_RELAXER, ROAMER, QUEUE_ENTRANCE }
enum NpcState { IDLE_LISTEN, CHEER, WANDER, QUEUE_WAIT, CHAT, PANIC, ENTER_TURNSTILE }

const WALK_SPEED = 2.0
const RUN_SPEED = 4.8

var archetype: NpcArchetype = NpcArchetype.ROAMER
var current_state = NpcState.WANDER
var direction = Vector3.ZERO
var state_timer = 0.0
var panic_source = Vector3.ZERO

# Durum Değişkenleri
var is_stunned: bool = false
var is_police_frozen: bool = false
var freeze_timer: float = 0.0
var stun_time_left: float = 0.0
var is_drinking_tea: bool = false
var tea_cheer_timer: float = 0.0
var queue_target_pos: Vector3 = Vector3.ZERO
var cheer_jump_timer: float = 0.0

@onready var char_model = $CharacterModel if has_node("CharacterModel") else null
@onready var anim_player = $CharacterModel/AnimMesh/AnimationPlayer if has_node("CharacterModel/AnimMesh/AnimationPlayer") else null

const CIVILIAN_COLORS = [
	Color(0.2, 0.2, 0.25),  # Koyu Füme
	Color(0.35, 0.35, 0.4), # Açık Gri Ceket
	Color(0.15, 0.25, 0.35),# Koyu Mavi
	Color(0.35, 0.25, 0.2), # Kahve
	Color(0.25, 0.35, 0.3), # Haki
	Color(0.45, 0.2, 0.25), # Bordo
	Color(0.85, 0.75, 0.2), # Sarı Tişört
	Color(0.15, 0.45, 0.65),# Canlı Mavi
	Color(0.2, 0.55, 0.3)   # Yeşil
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
	sfx_voice.unit_size = 8.0
	sfx_voice.max_distance = 25.0
	sfx_voice.volume_db = -18.0
	sfx_voice.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	add_child(sfx_voice)

func _play_random_gibberish():
	if not sfx_voice or voice_cooldown > 0.0: return
	voice_cooldown = randf_range(5.0, 16.0)
	var snd_path = GIBBERISH_SOUNDS[randi() % GIBBERISH_SOUNDS.size()]
	var stream = load(snd_path) as AudioStreamWAV
	if stream:
		sfx_voice.stream = stream
		sfx_voice.pitch_scale = randf_range(0.85, 1.25)
		sfx_voice.play()

func set_archetype(arch: NpcArchetype, custom_target: Vector3 = Vector3.ZERO):
	archetype = arch
	queue_target_pos = custom_target
	match archetype:
		NpcArchetype.STAGE_FANATIC:
			current_state = NpcState.IDLE_LISTEN
			state_timer = randf_range(2.0, 6.0)
			direction = Vector3.ZERO
			_face_target(Vector3(0, 1.4, -29.5))
		NpcArchetype.WC_QUEUE:
			current_state = NpcState.QUEUE_WAIT
			state_timer = randf_range(4.0, 12.0)
			direction = Vector3.ZERO
			if queue_target_pos != Vector3.ZERO:
				global_position = queue_target_pos
			_face_target(Vector3(global_position.x, global_position.y, -18.0))
		NpcArchetype.BENCH_RELAXER:
			current_state = NpcState.CHAT
			state_timer = randf_range(5.0, 15.0)
			direction = Vector3.ZERO
		NpcArchetype.QUEUE_ENTRANCE:
			current_state = NpcState.ENTER_TURNSTILE
			state_timer = randf_range(15.0, 30.0)
			direction = Vector3(randf_range(-0.2, 0.2), 0, -1.0).normalized()
		NpcArchetype.ROAMER:
			current_state = NpcState.WANDER
			_pick_random_wander()

func _face_target(target: Vector3):
	if char_model:
		var look_vec = target - global_position
		look_vec.y = 0
		if look_vec.length_squared() > 0.1:
			char_model.rotation.y = atan2(look_vec.x, look_vec.z)

func _ready():
	add_to_group("npcs")
	_setup_npc_voice()
	_setup_npc_materials()

# 🎨 Statik Paylaşımlı Materyaller (130+ NPC'de 140+ FPS Sabitleme)
static var SHARED_SHIRT_MATS: Array[StandardMaterial3D] = []
static var SHARED_PANTS_MATS: Array[StandardMaterial3D] = []

static func _init_shared_materials():
	if SHARED_SHIRT_MATS.size() > 0: return
	for col in CIVILIAN_COLORS:
		var s_mat = StandardMaterial3D.new()
		s_mat.albedo_color = col
		s_mat.roughness = 0.75
		SHARED_SHIRT_MATS.append(s_mat)
		
		var p_mat = StandardMaterial3D.new()
		p_mat.albedo_color = col.darkened(0.25)
		p_mat.roughness = 0.85
		SHARED_PANTS_MATS.append(p_mat)

func _setup_npc_materials():
	_init_shared_materials()
	var torso = get_node_or_null("CharacterModel/AnimMesh/character/root/torso")
	var leg_l = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-left")
	var leg_r = get_node_or_null("CharacterModel/AnimMesh/character/root/leg-right")
	
	var shirt_mat = SHARED_SHIRT_MATS[randi() % SHARED_SHIRT_MATS.size()]
	var pants_mat = SHARED_PANTS_MATS[randi() % SHARED_PANTS_MATS.size()]
	
	if torso: torso.set_surface_override_material(0, shirt_mat)
	if leg_l: leg_l.set_surface_override_material(0, pants_mat)
	if leg_r: leg_r.set_surface_override_material(0, pants_mat)
	
	if anim_player:
		anim_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS

func _physics_process(delta):
	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0.0:
			rotation_degrees.z = 0.0
			is_stunned = false
			current_state = NpcState.PANIC
			state_timer = 6.0
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	if is_police_frozen:
		freeze_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_npc_animation()
		if freeze_timer <= 0.0:
			is_police_frozen = false
			_decide_next_behavior()
		return

	if is_drinking_tea:
		tea_cheer_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_npc_animation()
		if tea_cheer_timer <= 0.0:
			is_drinking_tea = false
			_decide_next_behavior()
		return

	state_timer -= delta
	if state_timer <= 0.0:
		_decide_next_behavior()

	var speed = WALK_SPEED
	if current_state == NpcState.PANIC:
		speed = RUN_SPEED

	_update_avoidance_cache(delta)
	var player_avoid = _get_player_avoidance()
	
	if current_state == NpcState.PANIC:
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if char_model:
				var target_angle = atan2(direction.x, direction.z)
				char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 12.0 * delta)
	elif current_state == NpcState.IDLE_LISTEN:
		velocity.x = 0.0
		velocity.z = 0.0
		_face_target(Vector3(0, 1.4, -29.5))
		cheer_jump_timer -= delta
		if cheer_jump_timer <= 0.0:
			cheer_jump_timer = randf_range(3.0, 8.0)
			if randf() < 0.35 and is_on_floor():
				velocity.y = randf_range(2.5, 4.0)
	elif current_state == NpcState.ENTER_TURNSTILE:
		var target_turnstile = Vector3(clamp(global_position.x, -4.5, 4.5), 0.5, 16.0)
		var to_target = (target_turnstile - global_position)
		to_target.y = 0
		if to_target.length() > 0.5:
			direction = to_target.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if char_model:
				var target_angle = atan2(direction.x, direction.z)
				char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 10.0 * delta)
		else:
			archetype = NpcArchetype.ROAMER
			current_state = NpcState.WANDER
			_pick_random_wander()
	elif current_state == NpcState.CHEER:
		velocity.x = 0.0
		velocity.z = 0.0
		_face_target(Vector3(0, 1.4, -29.5))
		if is_on_floor() and randf() < 0.15:
			velocity.y = randf_range(3.0, 4.5)
	elif player_avoid != Vector3.ZERO:
		var avoid_dir = (direction + player_avoid * 1.5).normalized()
		velocity.x = avoid_dir.x * speed
		velocity.z = avoid_dir.z * speed
		if char_model:
			var target_angle = atan2(avoid_dir.x, avoid_dir.z)
			char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 15.0 * delta)
	elif direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if char_model:
			var target_angle = atan2(direction.x, direction.z)
			char_model.rotation.y = lerp_angle(char_model.rotation.y, target_angle, 10.0 * delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
	_update_npc_animation()

func _update_npc_animation():
	if not anim_player: return
	var horiz_speed = Vector3(velocity.x, 0, velocity.z).length()
	if not is_on_floor() and velocity.y > 0.5:
		if anim_player.current_animation != "jump":
			anim_player.play("jump")
		anim_player.speed_scale = 1.4
	elif horiz_speed > 0.15:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
		anim_player.speed_scale = clamp(horiz_speed / 2.0, 0.8, 2.2)
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		anim_player.speed_scale = randf_range(0.9, 1.15)

var _cached_avoid: Vector3 = Vector3.ZERO
var _avoid_timer: float = 0.0

func _get_player_avoidance() -> Vector3:
	return _cached_avoid

func _update_avoidance_cache(delta: float):
	_avoid_timer -= delta
	if _avoid_timer > 0.0: return
	_avoid_timer = 0.25 # Saniyede 4 kez kontrol
	
	var avoid = Vector3.ZERO
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p and is_instance_valid(p):
			var dist = global_position.distance_to(p.global_position)
			if dist < 2.0 and dist > 0.05:
				avoid += (global_position - p.global_position).normalized() / dist
	avoid.y = 0
	_cached_avoid = avoid.normalized()

func _decide_next_behavior():
	if randf() < 0.06:
		_play_random_gibberish()
		
	if archetype == NpcArchetype.QUEUE_ENTRANCE:
		if global_position.z > 20.0:
			current_state = NpcState.ENTER_TURNSTILE
			state_timer = 25.0
		else:
			archetype = NpcArchetype.ROAMER
			current_state = NpcState.WANDER
			_pick_random_wander()
		return

	if archetype == NpcArchetype.STAGE_FANATIC:
		if randf() < 0.30:
			current_state = NpcState.CHEER
			state_timer = randf_range(2.5, 5.0)
		else:
			current_state = NpcState.IDLE_LISTEN
			state_timer = randf_range(3.0, 8.0)
		direction = Vector3.ZERO
		return
		
	if archetype == NpcArchetype.WC_QUEUE:
		current_state = NpcState.QUEUE_WAIT
		state_timer = randf_range(5.0, 12.0)
		direction = Vector3.ZERO
		return
		
	if archetype == NpcArchetype.BENCH_RELAXER:
		current_state = NpcState.CHAT
		state_timer = randf_range(4.0, 10.0)
		direction = Vector3.ZERO
		return

	# Roamer
	var roll = randf()
	if roll < 0.60:
		_pick_random_wander()
	else:
		current_state = NpcState.CHAT
		direction = Vector3.ZERO
		state_timer = randf_range(3.0, 6.0)

func _pick_random_wander():
	current_state = NpcState.WANDER
	var angle = randf() * PI * 2
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	state_timer = randf_range(2.5, 5.5)

@rpc("any_peer", "call_local")
func on_panic_triggered(source: Vector3, radius: float):
	if global_position.distance_to(source) <= radius:
		current_state = NpcState.PANIC
		panic_source = source
		var away_dir = (global_position - source).normalized()
		away_dir.x += randf_range(-0.5, 0.5)
		away_dir.z += randf_range(-0.5, 0.5)
		direction = away_dir.normalized()
		direction.y = 0
		state_timer = randf_range(6.0, 10.0)
		_play_random_gibberish()

@rpc("any_peer", "call_local")
func on_stampede_triggered(start_gate: Vector3, target_area: Vector3):
	current_state = NpcState.PANIC
	var rush_target = target_area + Vector3(randf_range(-12, 12), 0, randf_range(-8, 8))
	direction = (rush_target - global_position).normalized()
	direction.y = 0
	state_timer = randf_range(7.0, 12.0)
	_play_random_gibberish()

func trigger_cheer(duration: float):
	current_state = NpcState.CHEER
	state_timer = duration
	direction = Vector3.ZERO

@rpc("any_peer", "call_local")
func apply_stun(duration: float = 4.5):
	is_stunned = true
	stun_time_left = duration
	rotation_degrees.z = 85.0

func search_body() -> Dictionary:
	var items = [
		"🥪 Peynirli Sandviç",
		"🔑 Ev Anahtarı",
		"🧻 Islak Mendil",
		"🥤 Soğuk Çay",
		"📱 Eski Tuşlu Telefon",
		"☕ Dantelli Çay Altlığı",
		"🌻 Dürbünlü Çekirdek Paketi",
		"🥇 Çeyrek Altın"
	]
	return {
		"is_assassin": false,
		"found_item": items[randi() % items.size()]
	}

@rpc("any_peer", "call_local")
func on_guard_freeze_command():
	if is_stunned or current_state == NpcState.PANIC: return
	var delay = randf_range(0.1, 0.6)
	await get_tree().create_timer(delay).timeout
	if is_stunned or current_state == NpcState.PANIC: return
	
	if randf() < 0.85:
		is_police_frozen = true
		freeze_timer = 4.2
		direction = Vector3.ZERO
		velocity.x = 0.0
		velocity.z = 0.0
		_play_random_gibberish()
		
		var guards = get_tree().get_nodes_in_group("players")
		for g in guards:
			if g and is_instance_valid(g) and g.get("current_role") == "GUARD":
				var look_vec = g.global_position - global_position
				look_vec.y = 0
				if look_vec.length_squared() > 0.1 and char_model:
					char_model.rotation.y = atan2(look_vec.x, look_vec.z)
				break
	else:
		state_timer = 3.5
		_play_random_gibberish()
