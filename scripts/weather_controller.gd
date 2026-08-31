extends Node

# WeatherController for Miting Oyunu
# Otomatik olarak Volumetric Fog, Procedural 3D Yağmur Partikülleri ve Projektör Işınlarını yönetir.

var fog_environment: WorldEnvironment = null
var env: Environment = null
var sky_mat: ProceduralSkyMaterial = null

# Yağmur partikül düğümü
var rain_particles: GPUParticles3D = null

# Ayarlar
var is_raining: bool = false
var target_fog_density: float = 0.001
var current_fog_density: float = 0.001

func _ready() -> void:
	print("🌦️ [WeatherController] Hava durumu sistemi başlatılıyor...")
	_setup_environment()
	_create_rain_particle_system()
	set_process(true)
	
	var initial_mode = "SUNNY"
	var global_state := get_node_or_null("/root/Global")
	if global_state and "weather_type" in global_state and global_state.weather_type != "":
		initial_mode = global_state.weather_type
	apply_weather_mode(initial_mode)

func apply_weather_mode(mode: String) -> void:
	var upper_mode = mode.to_upper()
	if upper_mode != "RAINY" and upper_mode != "YAĞMURLU":
		is_raining = false
		target_fog_density = 0.001
		current_fog_density = 0.001
		if rain_particles:
			rain_particles.emitting = false
		
		if env:
			env.volumetric_fog_enabled = false
			env.fog_enabled = true
			env.fog_light_color = Color(0.92, 0.86, 0.80, 1.0)
			env.fog_density = 0.003
			
			if sky_mat:
				sky_mat.sky_top_color = Color(0.22, 0.48, 0.85, 1.0)
				sky_mat.sky_horizon_color = Color(0.94, 0.78, 0.65, 1.0)
				sky_mat.ground_bottom_color = Color(0.22, 0.25, 0.30, 1.0)
				sky_mat.ground_horizon_color = Color(0.75, 0.68, 0.58, 1.0)
		
		var sun = get_parent().get_node_or_null("DirectionalLight3D") if get_parent() else null
		if not sun and get_tree() and get_tree().root:
			sun = get_tree().root.find_child("DirectionalLight3D", true, false) as DirectionalLight3D
		if sun:
			sun.light_color = Color(1.0, 0.94, 0.84, 1.0)
			sun.light_energy = 2.0
		
		print("☀️ [WeatherController] Güneşli / Açık hava modu uygulandı.")
	else:
		is_raining = true
		target_fog_density = 0.025
		current_fog_density = 0.025
		if rain_particles:
			rain_particles.emitting = true
		
		if env:
			env.volumetric_fog_enabled = true
			env.volumetric_fog_density = current_fog_density
			env.volumetric_fog_albedo = Color(0.65, 0.72, 0.85, 1.0)
			env.volumetric_fog_emission = Color(0.05, 0.08, 0.12, 1.0)
			env.volumetric_fog_emission_energy = 0.4
			
			env.fog_enabled = true
			env.fog_light_color = Color(0.55, 0.65, 0.75, 1.0)
			env.fog_density = 0.008
			
			if sky_mat:
				sky_mat.sky_top_color = Color(0.08, 0.12, 0.22, 1.0)
				sky_mat.sky_horizon_color = Color(0.25, 0.30, 0.45, 1.0)
				sky_mat.ground_bottom_color = Color(0.05, 0.06, 0.09, 1.0)
				sky_mat.ground_horizon_color = Color(0.20, 0.25, 0.35, 1.0)
		
		var sun = get_parent().get_node_or_null("DirectionalLight3D") if get_parent() else null
		if not sun and get_tree() and get_tree().root:
			sun = get_tree().root.find_child("DirectionalLight3D", true, false) as DirectionalLight3D
		if sun:
			sun.light_color = Color(0.65, 0.75, 0.88, 1.0)
			sun.light_energy = 0.45
		
		print("🌧️ [WeatherController] Yağmurlu / Kötü Hava modu uygulandı.")

func _setup_environment() -> void:
	var world_env = fog_environment
	if not world_env and get_parent():
		world_env = get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
	if not world_env and get_tree() and get_tree().root:
		world_env = get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment

	if world_env and world_env.environment:
		env = world_env.environment
		if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
			sky_mat = env.sky.sky_material as ProceduralSkyMaterial
		
		print("🌫️ [WeatherController] Volumetric Fog ve Gece Atmosferi aktif edildi (Yoğunluk: ", current_fog_density, ")")

func _create_rain_particle_system() -> void:
	# Sıfırdan kod ile 3D yağmur partikül motoru oluştur
	rain_particles = GPUParticles3D.new()
	rain_particles.name = "RainParticles3D"
	rain_particles.amount = 3500
	rain_particles.lifetime = 1.2
	rain_particles.speed_scale = 1.6
	rain_particles.visibility_aabb = AABB(Vector3(-40, -10, -40), Vector3(80, 50, 80))
	
	# Yağmur çizgisi görseli (Ribbon / Quad)
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.03, 0.45)
	
	var rain_mat = StandardMaterial3D.new()
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.albedo_color = Color(0.8, 0.9, 1.0, 0.55)
	rain_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad_mesh.material = rain_mat
	rain_particles.draw_pass_1 = quad_mesh
	
	# Partikül emisyon alanı (Miting meydanının üstü)
	var process_mat = ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(35.0, 1.0, 35.0)
	process_mat.direction = Vector3(0.1, -1.0, 0.05)
	process_mat.spread = 5.0
	process_mat.initial_velocity_min = 28.0
	process_mat.initial_velocity_max = 34.0
	process_mat.gravity = Vector3(0, -9.8, 0)
	process_mat.color = Color(0.85, 0.92, 1.0, 0.6)
	
	rain_particles.process_material = process_mat
	rain_particles.position = Vector3(0, 18, 0)
	add_child(rain_particles)
	rain_particles.emitting = true
	print("🌧️ [WeatherController] 3D Yağmur Partikül Sistemi meydanın üstüne yerleştirildi.")

func _process(delta: float) -> void:
	# Kamerayı takip et (Yağmur her zaman oyuncunun üstünde yağsın)
	var cam = get_viewport().get_camera_3d()
	if cam and rain_particles:
		rain_particles.global_position.x = cam.global_position.x
		rain_particles.global_position.z = cam.global_position.z
	
	# Sisi pürüzsüz enterpole et
	if env and env.volumetric_fog_enabled:
		current_fog_density = lerp(current_fog_density, target_fog_density, delta * 0.5)
		env.volumetric_fog_density = current_fog_density

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			# R tuşu: Yağmurlu / Güneşli modları arasında geçiş yap
			var new_mode = "SUNNY" if is_raining else "RAINY"
			apply_weather_mode(new_mode)
			var global_state := get_node_or_null("/root/Global")
			if global_state:
				global_state.weather_type = new_mode
		elif event.keycode == KEY_F:
			# F tuşu: Yoğun sis modunu aç/kapat
			if target_fog_density > 0.03:
				target_fog_density = 0.005
			else:
				target_fog_density = 0.08
			print("🌫️ [Hava Durumu] Hedef Sis Yoğunluğu: ", target_fog_density)
		elif event.keycode == KEY_T:
			# T tuşu: Şimşek çaktıran fırtına mekaniği
			_trigger_lightning_storm()

func _trigger_lightning_storm() -> void:
	print("⚡ [Hava Durumu] Şimşek çakıyor!")
	if not env: return
	var orig_emission = env.volumetric_fog_emission_energy
	env.volumetric_fog_emission_energy = 2.5
	var tween = create_tween()
	tween.tween_property(env, "volumetric_fog_emission_energy", orig_emission, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
