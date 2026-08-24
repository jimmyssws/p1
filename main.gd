extends Node3D

var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")
var npc_scene = preload("res://npc.tscn")
var connected_players = []

var match_seconds: int = 180
var match_timer_active: bool = false

var sfx_crowd_ambient: AudioStreamPlayer = null
var sfx_crowd_panic: AudioStreamPlayer = null

@onready var host_btn = $CanvasLayer/LobbyPanel/HostButton if has_node("CanvasLayer/LobbyPanel/HostButton") else null
@onready var join_btn = $CanvasLayer/LobbyPanel/JoinButton if has_node("CanvasLayer/LobbyPanel/JoinButton") else null
@onready var ip_input = $CanvasLayer/LobbyPanel/IpInput if has_node("CanvasLayer/LobbyPanel/IpInput") else null
@onready var timer_label = $TopBarHUD/TopPanel/TimerLabel if has_node("TopBarHUD/TopPanel/TimerLabel") else null
@onready var status_label = $TopBarHUD/TopPanel/StatusLabel if has_node("TopBarHUD/TopPanel/StatusLabel") else null


var ambient_player: AudioStreamPlayer3D = null
var sfx_alarm: AudioStreamPlayer = null
var sfx_cheer: AudioStreamPlayer = null

func _setup_ambient_audio():
	ambient_player = AudioStreamPlayer3D.new()
	var murmur_stream = load("res://sounds/npc_murmur.wav") as AudioStreamWAV
	if murmur_stream:
		murmur_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		murmur_stream.loop_end = murmur_stream.data.size() / 2
		ambient_player.stream = murmur_stream
		ambient_player.unit_size = 12.0
		ambient_player.max_distance = 28.0
		ambient_player.volume_db = 4.0
		ambient_player.position = Vector3(0, 1.0, -5.0) # Meydanın tam ortası
		ambient_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
		ambient_player.autoplay = true
		add_child(ambient_player)
		ambient_player.play()
		
	sfx_alarm = AudioStreamPlayer.new()
	var alarm_stream = load("res://sounds/alarm_siren.wav") as AudioStreamWAV
	if alarm_stream:
		sfx_alarm.stream = alarm_stream
		sfx_alarm.volume_db = 6.0
		add_child(sfx_alarm)

	sfx_cheer = AudioStreamPlayer.new()
	var cheer_stream = load("res://sounds/cheer_applause.wav") as AudioStreamWAV
	if cheer_stream:
		sfx_cheer.stream = cheer_stream
		sfx_cheer.volume_db = 5.0
		add_child(sfx_cheer)

func _ready():
	_setup_ambient_audio()
	if host_btn:
		host_btn.pressed.connect(_on_host_pressed)
	if join_btn:
		join_btn.pressed.connect(_on_join_pressed)
	if has_node("TopBarHUD"):
		$TopBarHUD.hide()

	if DisplayServer.get_name() == "headless" or "--server" in OS.get_cmdline_args():
		Global.network_mode = "HOST"

	if Global.network_mode == "HOST":
		_on_host_pressed()
	elif Global.network_mode == "JOIN":
		_on_join_pressed()


func _on_host_pressed():
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()
	if has_node("TopBarHUD"):
		$TopBarHUD.show()
		
	_add_player(multiplayer.get_unique_id())
	_spawn_npcs(65)
	_start_match_timer()
	_setup_crowd_sounds()

func _setup_crowd_sounds():
	sfx_crowd_ambient = AudioStreamPlayer.new()
	var amb_stream = load("res://sounds/crowd_ambient.wav") as AudioStreamWAV
	if amb_stream:
		amb_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sfx_crowd_ambient.stream = amb_stream
	sfx_crowd_ambient.volume_db = -7.0
	add_child(sfx_crowd_ambient)
	sfx_crowd_ambient.play()

	sfx_crowd_panic = AudioStreamPlayer.new()
	sfx_crowd_panic.stream = load("res://sounds/crowd_panic.wav")
	sfx_crowd_panic.volume_db = 1.0
	add_child(sfx_crowd_panic)


func _on_join_pressed():
	var target_ip = "127.0.0.1"
	if Global.join_ip != "" and Global.join_ip != "127.0.0.1":
		target_ip = Global.join_ip
	elif ip_input and ip_input.text.strip_edges() != "":
		target_ip = ip_input.text.strip_edges()

	peer.create_client(target_ip, 9999)
	multiplayer.multiplayer_peer = peer
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()
	if has_node("TopBarHUD"):
		$TopBarHUD.show()

func _start_match_timer():
	match_seconds = 180
	match_timer_active = true
	_run_timer_loop()

func _run_timer_loop():
	while match_timer_active and match_seconds > 0:
		await get_tree().create_timer(1.0).timeout
		match_seconds -= 1
		rpc("sync_timer", match_seconds)
		
		if match_seconds <= 0:
			match_timer_active = false
			rpc("net_game_over", "SÜRE DOLDU! MİTİNG GÜVENLE TAMAMLANDI!
🏛️ BAŞKAN VE KORUMALAR KAZANDI!")

@rpc("any_peer", "call_local")
func sync_timer(seconds_left: int):
	var mins = seconds_left / 60
	var secs = seconds_left % 60
	if timer_label:
		timer_label.text = "⏱️ %02d:%02d" % [mins, secs]
		if seconds_left <= 20:
			timer_label.modulate = Color(1, 0.2, 0.2)

func _add_player(id):
	connected_players.append(id)
	
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)
	_redistribute_roles()

func _redistribute_roles():
	if not multiplayer.is_server(): return
	
	var players_to_assign = connected_players.duplicate()
	
	var president_id = players_to_assign[0]
	var pres_node = get_node_or_null(str(president_id))
	if pres_node:
		pres_node.rpc("assign_role", "PRESIDENT")
	players_to_assign.erase(president_id)
	
	if players_to_assign.size() > 0:
		var assassin_id = players_to_assign[randi() % players_to_assign.size()]
		var ass_node = get_node_or_null(str(assassin_id))
		if ass_node:
			ass_node.rpc("assign_role", "ASSASSIN")
		players_to_assign.erase(assassin_id)
		
	for guard_id in players_to_assign:
		var guard_node = get_node_or_null(str(guard_id))
		if guard_node:
			guard_node.rpc("assign_role", "GUARD")

@rpc("any_peer", "call_local")
func net_game_over(message: String):
	match_timer_active = false
	for child in get_children():
		if child.has_method("local_game_over"):
			child.local_game_over(message)

@rpc("any_peer", "call_local")
func trigger_crowd_panic(epicenter: Vector3, radius: float):
	if sfx_crowd_panic and not sfx_crowd_panic.playing:
		sfx_crowd_panic.play()
	for child in get_children():
		if child.has_method("on_panic_triggered"):
			child.on_panic_triggered(epicenter, radius)

func _spawn_npcs(amount):
	for i in range(amount):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_" + str(i)
		
		# Organik kümelenme dağılımı:
		var spawn_pos = Vector3.ZERO
		var roll = randf()
		if roll < 0.45:
			# 1. Sahne önü miting kalabalığı
			spawn_pos = Vector3(randf_range(-12, 12), 1.2, randf_range(-18, -4))
		elif roll < 0.65:
			# 2. Büfe ve çadır etrafı
			spawn_pos = Vector3(randf_range(16, 28), 1.2, randf_range(-14, 8))
		elif roll < 0.80:
			# 3. Portatif WC kuyruğu & kenar çitler
			var left_wc = randf() < 0.5
			spawn_pos = Vector3(-26 + randf_range(-2, 3), 1.2, 12 + randf_range(0, 6)) if left_wc else Vector3(26 + randf_range(-3, 2), 1.2, 12 + randf_range(0, 6))
		else:
			# 4. Ağaç altları ve giriş turnikeleri
			spawn_pos = Vector3(randf_range(-24, 24), 1.2, randf_range(14, 26))
			
		npc.position = spawn_pos
		add_child(npc, true)

# İzdiham anında tüm sivilleri kapıdan içeri koşturan fonksiyon
@rpc("any_peer", "call_local")
func trigger_crowd_stampede(start_gate: Vector3, target_area: Vector3):
	for child in get_children():
		if child.has_method("on_stampede_triggered"):
			child.on_stampede_triggered(start_gate, target_area)

@rpc("any_peer", "call_local")
func trigger_crowd_cheer(source_pos: Vector3, radius: float):
	if sfx_cheer: sfx_cheer.play()
	for child in get_children():
		if child.has_method("trigger_cheer"):
			var dist = child.global_position.distance_to(source_pos)
			if dist <= radius:
				child.trigger_cheer(5.0)

const FUNNY_PROMISES = [
	"🔴 MİTİNG MÜJDESİ: 'Gençlere her ay 500 GB bedava internet ve RTX 5090!'",
	"🔴 MİTİNG MÜJDESİ: 'Pazartesi günleri resmi tatil ilan edilecek!'",
	"🔴 MİTİNG MÜJDESİ: 'Lahmacun ve çiğ köfte fiyatı 5 TL'ye sabitlenecek!'",
	"🔴 MİTİNG MÜJDESİ: 'Tüm vizeler kalkıyor, her mahalleye go-kart pisti!'",
	"🔴 MİTİNG MÜJDESİ: 'Sabah uyanma saati kanunla 11:00'e çekilecek!'",
	"🔴 MİTİNG MÜJDESİ: 'Oyun içi skinler ve VP devlet desteğiyle ücretsiz olacak!'"
]

@onready var news_ticker = $TopBarHUD/NewsTicker if has_node("TopBarHUD/NewsTicker") else null
@onready var news_label = $TopBarHUD/NewsTicker/HBox/Label if has_node("TopBarHUD/NewsTicker/HBox/Label") else ($TopBarHUD/NewsTicker/Label if has_node("TopBarHUD/NewsTicker/Label") else null)

const FUNNY_PROMISES_STAGES = [
	"🔴 MİTİNG MÜJDESİ [%25]: 'Her haneye 1 Gigabit bedava fiber internet ve 2'şer kilo çay dağıtılacak!'",
	"🔴 MİTİNG MÜJDESİ [%50]: 'Emeklilere her ay çeyrek altın ve sınırsız bedava belediye otobüsü sözü!'",
	"🔴 MİTİNG MÜJDESİ [%75]: 'Gençlere vergisiz iPhone, her mahalleye go-kart pisti ve bedava döner-ayran!'",
	"🔴 SON DAKİKA [%100]: 'TARİHİ KÜRSÜ KONUŞMASI TAMAMLANDI! MEYDAN COŞKUYLA AYAKTA!'"
]

@rpc("any_peer", "call_local")
func show_campaign_promise(stage_idx: int = 0):
	if not news_ticker or not news_label: return
	var idx = clamp(stage_idx, 0, FUNNY_PROMISES_STAGES.size() - 1)
	news_label.text = FUNNY_PROMISES_STAGES[idx]
	news_ticker.show()
	if sfx_cheer and stage_idx == 3: sfx_cheer.play()
	get_tree().create_timer(7.0).timeout.connect(func(): if news_ticker: news_ticker.hide())

@rpc("any_peer", "call_local")
func trigger_entrance_alarm():
	if sfx_alarm: sfx_alarm.play()
	var top_panel = get_node_or_null("TopBarHUD/TopPanel/StatusLabel")
	if top_panel:
		top_panel.text = "🚨 GİRİŞ KAPISINDA SİLAH ALARMI!"
	if news_ticker and news_label:
		news_label.text = "🚨 GÜVENLİK ALARMI: Turnikelerden ruhsatsız silahlı şahıs geçti!"
		news_ticker.show()
		await get_tree().create_timer(5.0).timeout
		if news_ticker: news_ticker.hide()

@rpc("any_peer", "call_local")
func restart_match():
	get_tree().reload_current_scene()


@rpc("any_peer", "call_local")
func net_trigger_guard_freeze():
	if sfx_alarm: sfx_alarm.play()
	if news_ticker and news_label:
		news_label.text = "📢 GÜVENLİK ANONS EMRİ: 'ŞÜPHELİ HAREKET VAR, HERKES DURSUUN!'"
		news_ticker.show()
		get_tree().create_timer(4.0).timeout.connect(func(): if news_ticker: news_ticker.hide())
	
	var npcs = get_tree().get_nodes_in_group("npcs")
	for n in npcs:
		if n and n.has_method("on_guard_freeze_command"):
			n.rpc("on_guard_freeze_command")

# 🍵 Başkanın Fırlattığı Çay Paketi RPC & Kalabalık İtişmesi
@rpc("any_peer", "call_local")
func spawn_flying_tea(start_pos: Vector3, dir: Vector3):
	var tea_node = RigidBody3D.new()
	tea_node.name = "TeaPacket"
	tea_node.position = start_pos + Vector3(0, 1.2, 0)
	
	var mesh_inst = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = Vector3(0.35, 0.45, 0.25)
	mesh_inst.mesh = bm
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.55, 0.22, 1) # Rize Çayı Yeşili
	mat.metallic = 0.2
	mat.roughness = 0.4
	mesh_inst.set_surface_override_material(0, mat)
	tea_node.add_child(mesh_inst)
	
	var col = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = Vector3(0.35, 0.45, 0.25)
	col.shape = bs
	tea_node.add_child(col)
	
	add_child(tea_node)
	tea_node.linear_velocity = (dir + Vector3(0, 0.45, 0)).normalized() * 14.0
	
	# Çayın düştüğü yere sivilleri koştur
	get_tree().create_timer(1.0).timeout.connect(func():
		if is_instance_valid(tea_node):
			var land_pos = tea_node.global_position
			var npcs = get_tree().get_nodes_in_group("npcs")
			for n in npcs:
				if n and is_instance_valid(n) and n.global_position.distance_to(land_pos) < 16.0:
					if n.has_method("on_stampede_triggered"):
						n.on_stampede_triggered(n.global_position, land_pos)
		get_tree().create_timer(6.0).timeout.connect(func():
			if is_instance_valid(tea_node): tea_node.queue_free()
		)
	)
