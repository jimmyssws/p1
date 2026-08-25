extends Node3D

var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")
var npc_scene = preload("res://npc.tscn")
var connected_players = []

var match_seconds: int = 180
var match_timer_active: bool = false
var president_poll_pct: float = 46.0
var _trend_clear_timer: float = 0.0

@onready var pres_vote_label = $TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/PresVoteLabel if has_node("TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/PresVoteLabel") else null
@onready var opp_vote_label = $TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/OppVoteLabel if has_node("TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/OppVoteLabel") else null
@onready var vote_progress_bar = $TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/VoteProgressBar if has_node("TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/VoteProgressBar") else null
@onready var poll_trend_label = $TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/TrendBadge/TrendLabel if has_node("TopBarHUD/TopHeader/Margin/HBox/CenterPollBox/TrendBadge/TrendLabel") else null
@onready var timer_label = $TopBarHUD/TopHeader/Margin/HBox/LeftBox/TimerBadge/TimerLabel if has_node("TopBarHUD/TopHeader/Margin/HBox/LeftBox/TimerBadge/TimerLabel") else null
@onready var status_label = $TopBarHUD/TopHeader/Margin/HBox/RightBox/StatusBadge/StatusLabel if has_node("TopBarHUD/TopHeader/Margin/HBox/RightBox/StatusBadge/StatusLabel") else null

var sfx_crowd_ambient: AudioStreamPlayer = null
var sfx_crowd_panic: AudioStreamPlayer = null

@onready var host_btn = $CanvasLayer/LobbyPanel/HostButton if has_node("CanvasLayer/LobbyPanel/HostButton") else null
@onready var join_btn = $CanvasLayer/LobbyPanel/JoinButton if has_node("CanvasLayer/LobbyPanel/JoinButton") else null
@onready var ip_input = $CanvasLayer/LobbyPanel/IpInput if has_node("CanvasLayer/LobbyPanel/IpInput") else null

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
		ambient_player.position = Vector3(0, 1.0, -5.0)
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
	sync_poll_score(46.0, "📊 Canlı Anket Başladı")
	sync_timer(180)
	if host_btn:
		host_btn.pressed.connect(_on_host_pressed)
	if join_btn:
		join_btn.pressed.connect(_on_join_pressed)
	if has_node("TopBarHUD"):
		$TopBarHUD.show()

	var net_mode = Global.network_mode if get_node_or_null("/root/Global") else "HOST"
	if DisplayServer.get_name() == "headless" or "--server" in OS.get_cmdline_args():
		net_mode = "HOST"

	if net_mode == "HOST":
		_on_host_pressed()
	elif net_mode == "JOIN":
		_on_join_pressed()

func _process(delta):
	if _trend_clear_timer > 0.0:
		_trend_clear_timer -= delta
		if _trend_clear_timer <= 0.0:
			if poll_trend_label:
				poll_trend_label.text = "  📊 Canlı Anket  "

@rpc("any_peer", "call_local")
func adjust_poll_score(delta_pct: float, reason: String):
	president_poll_pct = clamp(president_poll_pct + delta_pct, 5.0, 95.0)
	sync_poll_score(president_poll_pct, reason)
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		rpc("sync_poll_score", president_poll_pct, reason)

@rpc("any_peer", "call_local")
func sync_poll_score(score: float, reason: String):
	president_poll_pct = score
	var opp_score = 100.0 - score
	if pres_vote_label:
		pres_vote_label.text = "🏛️ BAŞKAN %%%.1f" % score
	if opp_vote_label:
		opp_vote_label.text = "🦅 RAKİP %%%.1f" % opp_score
	if vote_progress_bar:
		vote_progress_bar.value = score
	if poll_trend_label and reason != "":
		poll_trend_label.text = "  %s  " % reason
		_trend_clear_timer = 3.5

@rpc("any_peer", "call_local")
func sync_timer(seconds_left: int):
	var mins = seconds_left / 60
	var secs = seconds_left % 60
	if timer_label:
		timer_label.text = "  ⏱️ %02d:%02d  " % [mins, secs]
		if seconds_left <= 20:
			timer_label.modulate = Color(1, 0.2, 0.2)

func _on_host_pressed():
	var err = peer.create_server(9999)
	if err == OK:
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
	if get_node_or_null("/root/Global") and Global.join_ip != "" and Global.join_ip != "127.0.0.1":
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
		
		# Başkan kürsüde değilse pasiflikten oy yavaşça erir (-0.15% / sn)
		var pres_active = false
		for p in get_tree().get_nodes_in_group("players"):
			if p and is_instance_valid(p) and p.get("current_role") == "PRESIDENT":
				if p.get("task_progress") > 0.0:
					pres_active = true
				break
		
		if not pres_active:
			president_poll_pct = max(15.0, president_poll_pct - 0.15)
			
		sync_poll_score(president_poll_pct, "")
		sync_timer(match_seconds)
		if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
			rpc("sync_poll_score", president_poll_pct, "")
			rpc("sync_timer", match_seconds)
		
		if match_seconds <= 0:
			match_timer_active = false
			_evaluate_time_up_winner()

func _evaluate_time_up_winner():
	if not multiplayer.is_server(): return
	if president_poll_pct >= 50.0:
		rpc("net_game_over", "🏛️ SEÇİM ZAFERİ!\nBaşkan %" + str(snapped(president_poll_pct, 0.1)) + " Oyla Yeniden Seçildi!\n👑 BAŞKAN VE KORUMALAR KAZANDI!")
	else:
		rpc("net_game_over", "🤡 KORKAK BAŞKAN SEÇİMİ KAYBETTİ!\nRakip Aday %" + str(snapped(100.0 - president_poll_pct, 0.1)) + " Oyla Zafer Kazandı!\n📢 PROVOKATÖR & MUHALEFET KAZANDI!")

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
		
	var available_classes = [1, 2, 3]
	available_classes.shuffle()
	var class_idx = 0
	for guard_id in players_to_assign:
		var guard_node = get_node_or_null(str(guard_id))
		if guard_node:
			var g_class = available_classes[class_idx % available_classes.size()]
			class_idx += 1
			guard_node.rpc("assign_role", "GUARD", g_class)

func _spawn_npcs(count: int = 65):
	for i in range(count):
		var npc = npc_scene.instantiate()
		var pos = Vector3.ZERO
		var roll = randf()
		if roll < 0.40:
			pos = Vector3(randf_range(-14, 14), 0.5, randf_range(-22, -8))
		elif roll < 0.65:
			pos = Vector3(randf_range(-24, 24), 0.5, randf_range(-8, 15))
		elif roll < 0.85:
			pos = Vector3(randf_range(-28, 28), 0.5, randf_range(15, 38))
		else:
			var side = -1.0 if randf() < 0.5 else 1.0
			pos = Vector3(side * randf_range(18, 26), 0.5, randf_range(-20, 20))
			
		npc.name = "NPC_%d" % i
		npc.position = pos
		add_child.call_deferred(npc, true)

@rpc("any_peer", "call_local")
func trigger_crowd_panic(source: Vector3, radius: float):
	if sfx_crowd_panic and not sfx_crowd_panic.playing:
		sfx_crowd_panic.play()
	for n in get_tree().get_nodes_in_group("npcs"):
		if n and is_instance_valid(n) and n.has_method("on_panic_triggered"):
			n.rpc("on_panic_triggered", source, radius)

@rpc("any_peer", "call_local")
func trigger_crowd_stampede(start_pos: Vector3, target_pos: Vector3):
	if sfx_crowd_panic: sfx_crowd_panic.play()
	for n in get_tree().get_nodes_in_group("npcs"):
		if n and is_instance_valid(n) and n.has_method("on_stampede_triggered"):
			n.rpc("on_stampede_triggered", start_pos, target_pos)

@rpc("any_peer", "call_local")
func trigger_crowd_cheer(source: Vector3, radius: float):
	for n in get_tree().get_nodes_in_group("npcs"):
		if n and is_instance_valid(n) and n.has_method("trigger_cheer"):
			if n.global_position.distance_to(source) <= radius:
				n.trigger_cheer(3.5)

@rpc("any_peer", "call_local")
func show_campaign_promise(promise_index: int):
	var ticker = get_node_or_null("TopBarHUD/NewsTicker")
	var ticker_lbl = get_node_or_null("TopBarHUD/NewsTicker/HBox/Label")
	if not ticker or not ticker_lbl: return
	
	var PROMISES = [
		"🔴 BAŞKAN MÜJDELEDİ: 'HER MAHALLEYE BEDAVA DÖNER VE ÇAY ÇEŞMESİ GELİYOR!'",
		"🔴 SEÇİM VAADİ: 'GELİR VERGİSİ %0'A İNDİRİLECEK, HER GENCE BEDAVA DRON VERİLECEK!'",
		"🔴 TARİHİ SÖZ: 'MİTİNG ALANI DÜNYANIN EN BÜYÜK MANGAL PARKI İLAN EDİLECEK!'"
	]
	
	var idx = clamp(promise_index, 0, PROMISES.size() - 1)
	ticker_lbl.text = PROMISES[idx]
	ticker.show()
	await get_tree().create_timer(7.0).timeout
	if ticker_lbl.text == PROMISES[idx]:
		ticker.hide()

@rpc("any_peer", "call_local")
func net_game_over(message: String):
	match_timer_active = false
	for p in get_tree().get_nodes_in_group("players"):
		if p and is_instance_valid(p) and p.has_method("local_game_over"):
			p.local_game_over(message)

@rpc("any_peer", "call_local")
func restart_match():
	match_seconds = 180
	match_timer_active = true
	president_poll_pct = 46.0
	sync_poll_score(46.0, "📊 Yeni Miting Başladı")
	sync_timer(180)
	_redistribute_roles()
