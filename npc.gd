extends CharacterBody3D

# ============================================================
# NPC.GD — Miting Kalabalığı Yapay Zekası (v2.0)
# 5 Arketip: Sahne Fanatiği, WC Sırası, Bank Dinlencesi,
#            Gezer Sivil, Kapı Girişçisi
# ============================================================

enum NpcArchetype { STAGE_FANATIC, WC_QUEUE, BENCH_RELAXER, ROAMER, QUEUE_ENTRANCE }
enum NpcState { IDLE_LISTEN, CHEER, WANDER, QUEUE_WAIT, CHAT, PANIC, ENTER_TURNSTILE, FROZEN, STUNNED }

const WALK_SPEED   = 2.0
const RUN_SPEED    = 5.2
const GRAVITY      = 9.8

# Meydan sınırları
const BOUNDS_X     = 26.0
const BOUNDS_Z_MIN = -27.0
const BOUNDS_Z_MAX = 21.0

var archetype: NpcArchetype = NpcArchetype.ROAMER
var current_state: NpcState = NpcState.WANDER
var direction      = Vector3.ZERO
var state_timer    = 0.0
var panic_source   = Vector3.ZERO

# Durum bayrakları
var is_stunned:        bool  = false
var is_police_frozen:  bool  = false
var freeze_timer:      float = 0.0
var stun_time_left:    float = 0.0
var is_drinking_tea:   bool  = false
var tea_cheer_timer:   float = 0.0
var queue_target_pos:  Vector3 = Vector3.ZERO
var cheer_jump_timer:  float = 0.0
var voice_cooldown:    float = randf_range(2.0, 8.0)

# ------ Node referansları ------
@onready var char_model  = $CharacterModel if has_node("CharacterModel") else null
# GLB import → Godot otomatik "AnimationPlayer" node'u yaratır
@onready var anim_player = _find_anim_player()

func _find_anim_player() -> AnimationPlayer:
	# character_animated.glb'nin iç yolu: AnimMesh → AnimationPlayer
	var candidates = [
		"CharacterModel/AnimMesh/AnimationPlayer",
		"CharacterModel/AnimMesh/character/AnimationPlayer",
		"CharacterModel/AnimationPlayer",
	]
	for path in candidates:
		if has_node(path):
			return get_node(path)
	# Derinlemesine bul
	return _deep_find_anim(self)

func _deep_find_anim(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _deep_find_anim(child)
		if result:
			return result
	return null

# ------ Sivil renk paleti ------
const CIVILIAN_COLORS = [
	Color(0.20, 0.20, 0.25),
	Color(0.35, 0.35, 0.40),
	Color(0.15, 0.25, 0.35),
	Color(0.35, 0.25, 0.20),
	Color(0.25, 0.35, 0.30),
	Color(0.45, 0.20, 0.25),
	Color(0.85, 0.75, 0.20),
	Color(0.15, 0.45, 0.65),
	Color(0.20, 0.55, 0.30),
]

# ------ Ses sistemi ------
var sfx_voice: AudioStreamPlayer3D = null
const GIBBERISH_SOUNDS = [
	"res://sounds/silly_chatter_1.wav",
	"res://sounds/silly_chatter_2.wav",
	"res://sounds/silly_chatter_3.wav",
]

func _setup_npc_voice():
	sfx_voice = AudioStreamPlayer3D.new()
	sfx_voice.unit_size       = 8.0
	sfx_voice.max_distance    = 25.0
	sfx_voice.volume_db       = -18.0
	sfx_voice.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	add_child(sfx_voice)

func _play_random_gibberish():
	if not sfx_voice or voice_cooldown > 0.0: return
	voice_cooldown = randf_range(6.0, 18.0)
	var path = GIBBERISH_SOUNDS[randi() % GIBBERISH_SOUNDS.size()]
	var stream = load(path) as AudioStreamWAV
	if stream:
		sfx_voice.stream      = stream
		sfx_voice.pitch_scale = randf_range(0.85, 1.25)
		sfx_voice.play()

# ------ Materyal batching ------
static var SHARED_SHIRT_MATS: Array[StandardMaterial3D] = []
static var SHARED_PANTS_MATS: Array[StandardMaterial3D]  = []

static func _init_shared_materials():
	if SHARED_SHIRT_MATS.size() > 0: return
	var colors = [
		Color(0.20,0.20,0.25), Color(0.35,0.35,0.40), Color(0.15,0.25,0.35),
		Color(0.35,0.25,0.20), Color(0.25,0.35,0.30), Color(0.45,0.20,0.25),
		Color(0.85,0.75,0.20), Color(0.15,0.45,0.65), Color(0.20,0.55,0.30),
	]
	for col in colors:
		var s = StandardMaterial3D.new()
		s.albedo_color = col; s.roughness = 0.75
		SHARED_SHIRT_MATS.append(s)
		var p = StandardMaterial3D.new()
		p.albedo_color = col.darkened(0.25); p.roughness = 0.85
		SHARED_PANTS_MATS.append(p)

func _setup_npc_materials():
	_init_shared_materials()
	# GLB node yolları: AnimMesh/character/root/...
	var prefixes = [
		"CharacterModel/AnimMesh/character/root/",
		"CharacterModel/AnimMesh/",
		"CharacterModel/",
	]
	var torso_node  = null
	var leg_l_node  = null
	var leg_r_node  = null
	for pre in prefixes:
		if torso_node == null: torso_node = get_node_or_null(pre + "torso")
		if leg_l_node == null: leg_l_node = get_node_or_null(pre + "leg-left")
		if leg_r_node == null: leg_r_node = get_node_or_null(pre + "leg-right")

	var shirt_mat = SHARED_SHIRT_MATS[randi() % SHARED_SHIRT_MATS.size()]
	var pants_mat = SHARED_PANTS_MATS[randi() % SHARED_PANTS_MATS.size()]
	if torso_node: torso_node.set_surface_override_material(0, shirt_mat)
	if leg_l_node: leg_l_node.set_surface_override_material(0, pants_mat)
	if leg_r_node: leg_r_node.set_surface_override_material(0, pants_mat)

	if anim_player:
		anim_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS

# ============================================================
# READY
# ============================================================
func _ready():
	add_to_group("npcs")
	_setup_npc_voice()
	call_deferred("_setup_npc_materials")

# ============================================================
# ARKETİP ATAMA
# ============================================================
func set_archetype(arch: int, custom_target: Vector3 = Vector3.ZERO):
	archetype        = arch as NpcArchetype
	queue_target_pos = custom_target
	match archetype:
		NpcArchetype.STAGE_FANATIC:
			current_state = NpcState.IDLE_LISTEN
			state_timer   = randf_range(3.0, 7.0)
			direction     = Vector3.ZERO
			_face_target(Vector3(0, 1.4, -29.5))

		NpcArchetype.WC_QUEUE:
			current_state = NpcState.QUEUE_WAIT
			state_timer   = randf_range(5.0, 14.0)
			direction     = Vector3.ZERO
			if queue_target_pos != Vector3.ZERO:
				global_position = queue_target_pos
			_face_target(Vector3(global_position.x, global_position.y, -18.0))

		NpcArchetype.BENCH_RELAXER:
			current_state = NpcState.CHAT
			state_timer   = randf_range(6.0, 16.0)
			direction     = Vector3.ZERO

		NpcArchetype.QUEUE_ENTRANCE:
			current_state = NpcState.ENTER_TURNSTILE
			state_timer   = randf_range(12.0, 28.0)
			direction     = Vector3(randf_range(-0.15, 0.15), 0, -1.0).normalized()

		NpcArchetype.ROAMER:
			current_state = NpcState.WANDER
			_pick_random_wander()

func _face_target(target: Vector3):
	if char_model:
		var look_vec = (target - global_position)
		look_vec.y = 0
		if look_vec.length_squared() > 0.1:
			char_model.rotation.y = atan2(look_vec.x, look_vec.z)

# ============================================================
# PHYSICS PROCESS
# ============================================================
func _physics_process(delta: float):
	# Ses cooldown'u say
	if voice_cooldown > 0.0:
		voice_cooldown -= delta

	# Yerçekimi
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	# --- STUN (taser / bıçak) ---
	if is_stunned:
		stun_time_left -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		if stun_time_left <= 0.0:
			rotation_degrees.z = 0.0
			is_stunned   = false
			current_state = NpcState.PANIC
			state_timer   = randf_range(4.0, 7.0)
			_pick_panic_direction(global_position)
		return

	# --- MEGAFON DONMASI ---
	if is_police_frozen:
		freeze_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_play_anim("idle")
		if freeze_timer <= 0.0:
			is_police_frozen = false
			_decide_next_behavior()
		return

	# --- ÇAY İÇME (Başkan çay attı) ---
	if is_drinking_tea:
		tea_cheer_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_play_anim("idle")
		if tea_cheer_timer <= 0.0:
			is_drinking_tea = false
			_decide_next_behavior()
		return

	# --- DURUM TİMERI ---
	state_timer -= delta
	if state_timer <= 0.0:
		_decide_next_behavior()

	# --- HAREKET ---
	var speed = RUN_SPEED if current_state == NpcState.PANIC else WALK_SPEED

	# Oyuncu kaçınma (saniyede 4x güncellenir)
	_update_avoidance_cache(delta)
	var avoid = _get_player_avoidance()

	match current_state:
		NpcState.IDLE_LISTEN:
			velocity.x = 0.0
			velocity.z = 0.0
			_face_target(Vector3(0, 1.4, -29.5))
			# Ara sıra zıpla (coşku)
			cheer_jump_timer -= delta
			if cheer_jump_timer <= 0.0:
				cheer_jump_timer = randf_range(3.5, 9.0)
				if randf() < 0.30 and is_on_floor():
					velocity.y = randf_range(2.5, 4.0)

		NpcState.CHEER:
			velocity.x = 0.0
			velocity.z = 0.0
			_face_target(Vector3(0, 1.4, -29.5))
			if is_on_floor() and randf() < 0.12:
				velocity.y = randf_range(3.0, 4.5)

		NpcState.QUEUE_WAIT, NpcState.CHAT:
			velocity.x = 0.0
			velocity.z = 0.0

		NpcState.ENTER_TURNSTILE:
			# Turnikeden içeri akış — x sınırlı koridorda ileri git
			var target_z = 15.5
			if global_position.z > target_z + 0.5:
				direction = Vector3(randf_range(-0.1, 0.1), 0, -1.0).normalized()
				velocity.x = direction.x * speed * 0.7
				velocity.z = direction.z * speed * 0.7
				if char_model:
					char_model.rotation.y = lerp_angle(char_model.rotation.y, atan2(direction.x, direction.z), 10.0 * delta)
			else:
				# İçeri girdi — artık roamer
				archetype     = NpcArchetype.ROAMER
				current_state = NpcState.WANDER
				_pick_random_wander()

		NpcState.PANIC:
			if direction != Vector3.ZERO:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				if char_model:
					var ta = atan2(direction.x, direction.z)
					char_model.rotation.y = lerp_angle(char_model.rotation.y, ta, 14.0 * delta)

		NpcState.WANDER:
			if avoid != Vector3.ZERO:
				var blend = (direction + avoid * 1.8).normalized()
				velocity.x = blend.x * speed
				velocity.z = blend.z * speed
				if char_model:
					char_model.rotation.y = lerp_angle(char_model.rotation.y, atan2(blend.x, blend.z), 12.0 * delta)
			elif direction != Vector3.ZERO:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				if char_model:
					char_model.rotation.y = lerp_angle(char_model.rotation.y, atan2(direction.x, direction.z), 10.0 * delta)
			else:
				velocity.x = 0.0
				velocity.z = 0.0

		_:
			velocity.x = 0.0
			velocity.z = 0.0

	# --- MEYDAN SINIRI — merkeze yönlendir ---
	_apply_boundary_steering()

	move_and_slide()
	_update_npc_animation()

# ============================================================
# ANİMASYON
# ============================================================
func _play_anim(anim_name: String, speed: float = 1.0):
	if not anim_player: return
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)
	anim_player.speed_scale = speed

func _update_npc_animation():
	if not anim_player: return
	var horiz = Vector3(velocity.x, 0, velocity.z).length()

	if is_stunned:
		_play_anim("static", 1.0)
	elif not is_on_floor() and velocity.y > 0.8:
		_play_anim("jump", 1.4)
	elif horiz > 0.2:
		var spd_ratio = clamp(horiz / RUN_SPEED, 0.5, 1.0)
		_play_anim("walk", lerp(0.8, 2.0, spd_ratio))
	else:
		_play_anim("idle", randf_range(0.9, 1.1))

# ============================================================
# SINIR & KAÇINMA
# ============================================================
func _apply_boundary_steering():
	var pos = global_position
	var out_x   = abs(pos.x) > BOUNDS_X
	var out_zmin = pos.z < BOUNDS_Z_MIN
	var out_zmax = (archetype != NpcArchetype.QUEUE_ENTRANCE) and pos.z > BOUNDS_Z_MAX

	if out_x or out_zmin or out_zmax:
		# Meydanın ortasına doğru yumuşak çekiş
		var center = Vector3(randf_range(-8, 8), 0, randf_range(-16, -4))
		direction  = (center - pos).normalized()
		direction.y = 0
		state_timer = randf_range(2.0, 4.0)

var _cached_avoid: Vector3 = Vector3.ZERO
var _avoid_timer:  float   = 0.0

func _get_player_avoidance() -> Vector3:
	return _cached_avoid

func _update_avoidance_cache(delta: float):
	_avoid_timer -= delta
	if _avoid_timer > 0.0: return
	_avoid_timer = 0.2  # saniyede 5x

	var avoid   = Vector3.ZERO
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p and is_instance_valid(p):
			var d = global_position.distance_to(p.global_position)
			if d < 2.2 and d > 0.05:
				avoid += (global_position - p.global_position).normalized() * (2.2 - d)
	avoid.y = 0
	_cached_avoid = avoid.normalized() if avoid.length() > 0.01 else Vector3.ZERO

# ============================================================
# DURUM MAKİNESİ
# ============================================================
func _decide_next_behavior():
	# Küçük şans ile ses çıkar
	if randf() < 0.08:
		_play_random_gibberish()

	match archetype:
		NpcArchetype.QUEUE_ENTRANCE:
			if global_position.z > 19.0:
				current_state = NpcState.ENTER_TURNSTILE
				state_timer   = 22.0
			else:
				archetype     = NpcArchetype.ROAMER
				_pick_random_wander()
			return

		NpcArchetype.STAGE_FANATIC:
			var r = randf()
			if r < 0.35:
				current_state = NpcState.CHEER
				state_timer   = randf_range(2.0, 5.0)
			else:
				current_state = NpcState.IDLE_LISTEN
				state_timer   = randf_range(3.0, 8.0)
			direction = Vector3.ZERO
			return

		NpcArchetype.WC_QUEUE:
			current_state = NpcState.QUEUE_WAIT
			state_timer   = randf_range(5.0, 14.0)
			direction     = Vector3.ZERO
			return

		NpcArchetype.BENCH_RELAXER:
			current_state = NpcState.CHAT
			state_timer   = randf_range(5.0, 12.0)
			direction     = Vector3.ZERO
			return

		NpcArchetype.ROAMER:
			var r = randf()
			if r < 0.62:
				_pick_random_wander()
			elif r < 0.82:
				current_state = NpcState.CHAT
				direction     = Vector3.ZERO
				state_timer   = randf_range(3.0, 6.0)
			else:
				# Kısa durup çevreye baksın
				current_state = NpcState.IDLE_LISTEN
				direction     = Vector3.ZERO
				state_timer   = randf_range(1.5, 3.5)

func _pick_random_wander():
	current_state = NpcState.WANDER
	# Meydanın içine doğru eğimli rastgele yön
	var angle = randf_range(-PI, PI)
	direction  = Vector3(cos(angle), 0, sin(angle)).normalized()
	state_timer = randf_range(2.5, 5.5)

func _pick_panic_direction(source: Vector3):
	var away = (global_position - source).normalized()
	away.x   += randf_range(-0.7, 0.7)
	away.z   += randf_range(-0.7, 0.7)
	direction  = away.normalized()
	direction.y = 0

# ============================================================
# DIŞ TETİKLEYİCİLER (RPC & direkt çağrı)
# ============================================================

# 🚨 Panik (tabanca sesi, suikast, izdiham)
@rpc("any_peer", "call_local")
func on_panic_triggered(source: Vector3, radius: float):
	if global_position.distance_to(source) > radius: return
	current_state = NpcState.PANIC
	panic_source  = source
	_pick_panic_direction(source)
	state_timer = randf_range(3.5, 6.0)
	_play_random_gibberish()

# 🏃 İzdiham (Suikastçı Slot 3)
@rpc("any_peer", "call_local")
func on_stampede_triggered(start_gate: Vector3, target_area: Vector3):
	current_state = NpcState.PANIC
	var rush = target_area + Vector3(randf_range(-14, 14), 0, randf_range(-8, 8))
	direction = (rush - global_position).normalized()
	direction.y = 0
	state_timer = randf_range(7.0, 13.0)
	_play_random_gibberish()

# ⚡ Taser / Bıçak (bayılma)
@rpc("any_peer", "call_local")
func apply_stun(duration: float = 4.5):
	is_stunned     = true
	stun_time_left = duration
	velocity       = Vector3.ZERO
	rotation_degrees.z = 85.0
	_play_anim("static")

# 🔍 Üst Arama (E tuşu)
func search_body() -> Dictionary:
	var items = [
		"🥪 Peynirli Sandviç", "🔑 Ev Anahtarı", "🧻 Islak Mendil",
		"🥤 Soğuk Çay",        "📱 Eski Tuşlu Telefon", "☕ Dantelli Çay Altlığı",
		"🌻 Çekirdek Paketi",  "🥇 Çeyrek Altın",        "🧆 Soğuk Köfte",
		"🔋 Biten Pil",         "📎 Paslı Ataş",          "🥔 Yarım Patates"
	]
	return { "is_assassin": false, "found_item": items[randi() % items.size()] }

# 📢 Megafon / Dondurma komutu (Koruma 3)
@rpc("any_peer", "call_local")
func on_guard_freeze_command():
	if is_stunned or current_state == NpcState.PANIC: return
	# Kademeli gecikme (gerçekçilik)
	var delay = randf_range(0.05, 0.55)
	await get_tree().create_timer(delay).timeout
	if is_stunned or current_state == NpcState.PANIC: return

	if randf() < 0.82:  # %82 uyar, %18 hain sivil uymaz
		is_police_frozen = true
		freeze_timer     = 4.5
		direction        = Vector3.ZERO
		velocity.x       = 0.0
		velocity.z       = 0.0
		_play_random_gibberish()
		# En yakın korumaya dön
		var guards = get_tree().get_nodes_in_group("players")
		var nearest_guard: Node3D = null
		var best_dist = 999.0
		for g in guards:
			if g and is_instance_valid(g) and g.get("current_role") == "GUARD":
				var d = global_position.distance_to(g.global_position)
				if d < best_dist:
					best_dist = d
					nearest_guard = g
		if nearest_guard and char_model:
			var lv = nearest_guard.global_position - global_position
			lv.y = 0
			if lv.length_squared() > 0.1:
				char_model.rotation.y = atan2(lv.x, lv.z)
	else:
		# İsyancı sivil — kısa mıırıldanıp devam eder
		state_timer = randf_range(2.0, 4.0)

# 🍵 Başkan Çay Fırlatma — kovalayan coşku sürüsü
func trigger_cheer(duration: float):
	current_state = NpcState.CHEER
	state_timer   = duration
	_face_target(Vector3(0, 1.4, -28.0))
	# Sahneye doğru hafifçe yürü
	var to_stage  = (Vector3(0, 0, -20.0) - global_position).normalized()
	to_stage.y    = 0
	direction     = to_stage * 0.35
	_play_random_gibberish()

# 🔪 NPC Ölümü (Suikastçı bıçak/tabanca ile vurdu)
func die_and_drop(_weapon_type: String = "BIÇAK"):
	apply_stun(25.0)
	_play_random_gibberish()
