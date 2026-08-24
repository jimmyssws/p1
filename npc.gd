extends CharacterBody3D

const SPEED = 2.0
var direction = Vector3.ZERO
var wander_timer = 0.0

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

func _ready():
	# Her sivile rastgele şık bir kıyafet rengi ver
	if body_mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = CIVILIAN_COLORS[randi() % CIVILIAN_COLORS.size()]
		mat.roughness = 0.7
		body_mesh.set_surface_override_material(0, mat)
		
	_pick_random_direction()

func _physics_process(delta):
	if not multiplayer.is_server(): return 

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	wander_timer -= delta
	if wander_timer <= 0:
		_pick_random_direction()
		
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if char_model:
			var target_angle = atan2(velocity.x, velocity.z)
			char_model.global_rotation.y = lerp_angle(char_model.global_rotation.y, target_angle, 10 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()

func _pick_random_direction():
	var angle = randf() * PI * 2
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	wander_timer = randf_range(2.0, 5.5)
	
	# %35 ihtimalle dursun/çevreyi izlesin
	if randf() < 0.35:
		direction = Vector3.ZERO
