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

enum GameState { LOBBY, COUNTDOWN, PLAYING, GAME_OVER }
var current_game_state: int = GameState.LOBBY
var lobby_players: Dictionary = {} # peer_id -> {"ready": bool, "name": String, "is_host": bool}
var lobby_countdown: int = 3
var is_counting_down: bool = false

var lobby_canvas: CanvasLayer = null
var lobby_player_list_vbox: VBoxContainer = null
var lobby_ready_btn: Button = null
var lobby_start_btn: Button = null
var lobby_countdown_label: Label = null
var lobby_count_label: Label = null

@onready var host_btn = $CanvasLayer/LobbyPanel/HostButton if has_node("CanvasLayer/LobbyPanel/HostButton") else null
@onready var join_btn = $CanvasLayer/LobbyPanel/JoinButton if has_node("CanvasLayer/LobbyPanel/JoinButton") else null
@onready var ip_input = $CanvasLayer/LobbyPanel/IpInput if has_node("CanvasLayer/LobbyPanel/IpInput") else null

var ambient_player: AudioStreamPlayer3D = null
var sfx_alarm: AudioStreamPlayer = null
var sfx_cheer: AudioStreamPlayer = null
var sfx_rally_music: AudioStreamPlayer = null
var sfx_crowd_ambient: AudioStreamPlayer = null
var sfx_crowd_panic: AudioStreamPlayer = null

func _setup_ambient_audio():
	# 🎵 Miting Arka Plan Marş & Müziği (Dolu Dolu ve Enerjik)
	if not sfx_rally_music:
		sfx_rally_music = AudioStreamPlayer.new()
		var music_stream = load("res://sounds/rally_ambient_music.wav") as AudioStreamWAV
		if music_stream:
			music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			music_stream.loop_end  = -1
			sfx_rally_music.stream    = music_stream
			sfx_rally_music.volume_db = -4.0
			sfx_rally_music.bus       = "Master"
			sfx_rally_music.finished.connect(func(): if sfx_rally_music: sfx_rally_music.play())
			add_child(sfx_rally_music)
			sfx_rally_music.play()

	# 🔊 Sürekli Kalabalık Uğultusu (2D Genel Atmosfer)
	if not sfx_crowd_ambient:
		sfx_crowd_ambient = AudioStreamPlayer.new()
		var amb_stream = load("res://sounds/crowd_ambient.wav") as AudioStreamWAV
		if amb_stream:
			amb_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			amb_stream.loop_end  = -1
			sfx_crowd_ambient.stream    = amb_stream
			sfx_crowd_ambient.volume_db = -2.0
			sfx_crowd_ambient.bus       = "Master"
			sfx_crowd_ambient.finished.connect(func(): if sfx_crowd_ambient: sfx_crowd_ambient.play())
			add_child(sfx_crowd_ambient)
			sfx_crowd_ambient.play()

	# 🔊 3D Konumsal Kalabalık (Meydan Ortası Z = -8.0)
	if not ambient_player:
		ambient_player = AudioStreamPlayer3D.new()
		var murmur_stream = load("res://sounds/npc_murmur.wav") as AudioStreamWAV
		if murmur_stream:
			murmur_stream.loop_mode    = AudioStreamWAV.LOOP_FORWARD
			murmur_stream.loop_end     = -1
			ambient_player.stream      = murmur_stream
			ambient_player.unit_size   = 18.0
			ambient_player.max_distance = 70.0
			ambient_player.volume_db   = 6.0
			ambient_player.position    = Vector3(0, 1.2, -8.0)
			ambient_player.finished.connect(func(): if ambient_player: ambient_player.play())
			ambient_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
			add_child(ambient_player)
			ambient_player.play()

	# 🚨 Alarm Sireni
	if not sfx_alarm:
		sfx_alarm = AudioStreamPlayer.new()
		var alarm_stream = load("res://sounds/alarm_siren.wav") as AudioStreamWAV
		if alarm_stream:
			sfx_alarm.stream    = alarm_stream
			sfx_alarm.volume_db = 7.0
			add_child(sfx_alarm)

	# 👏 Alkış / Coşku Sesi
	if not sfx_cheer:
		sfx_cheer = AudioStreamPlayer.new()
		var cheer_stream = load("res://sounds/cheer_applause.wav") as AudioStreamWAV
		if cheer_stream:
			sfx_cheer.stream    = cheer_stream
			sfx_cheer.volume_db = 7.0
			add_child(sfx_cheer)

	# 😱 Panik Çığlık Sesi
	if not sfx_crowd_panic:
		sfx_crowd_panic = AudioStreamPlayer.new()
		sfx_crowd_panic.stream = load("res://sounds/crowd_panic.wav")
		sfx_crowd_panic.volume_db = 4.0
		add_child(sfx_crowd_panic)


var stage_broadcast_speaker: AudioStreamPlayer3D = null

func _setup_stage_speaker():
	if stage_broadcast_speaker: return
	stage_broadcast_speaker = AudioStreamPlayer3D.new()
	stage_broadcast_speaker.name = "StageBroadcastSpeaker"
	stage_broadcast_speaker.position = Vector3(0, 3.5, -31.0) # Kürsü üstü dev hoparlör
	stage_broadcast_speaker.unit_size = 28.0
	stage_broadcast_speaker.max_distance = 100.0
	stage_broadcast_speaker.volume_db = 9.0
	stage_broadcast_speaker.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	add_child(stage_broadcast_speaker)

@rpc("any_peer", "call_local")
func play_stage_announcement(sound_path: String):
	_setup_stage_speaker()
	if stage_broadcast_speaker:
		var stream = load(sound_path) as AudioStream
		if stream:
			stage_broadcast_speaker.stream = stream
			stage_broadcast_speaker.play()

func _ready():
	_setup_stage_speaker()
	_setup_ambient_audio()
	_create_news_ticker_ui()
	sync_poll_score(46.0, "📊 Canlı Anket Başladı")
	sync_timer(180)
	if has_node("TopBarHUD"):
		$TopBarHUD.hide()
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()

	_create_lobby_ui()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var net_mode = Global.network_mode if get_node_or_null("/root/Global") else "HOST"
	if DisplayServer.get_name() == "headless" or "--server" in OS.get_cmdline_args():
		net_mode = "HOST"

	if net_mode == "HOST":
		_on_host_pressed()
	elif net_mode == "JOIN":
		_on_join_pressed()

func _create_lobby_ui():
	lobby_canvas = CanvasLayer.new()
	lobby_canvas.name = "LobbyReadyCanvasLayer"
	add_child(lobby_canvas)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	lobby_canvas.add_child(center)

	var panel_container = PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(580, 440)
	var p_style = StyleBoxTexture.new()
	var p_tex = load("res://ui_kenney/grey_panel.png")
	if p_tex:
		p_style.texture = p_tex
		p_style.texture_margin_left = 16
		p_style.texture_margin_right = 16
		p_style.texture_margin_top = 16
		p_style.texture_margin_bottom = 16
	panel_container.add_theme_stylebox_override("panel", p_style)
	center.add_child(panel_container)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel_container.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Başlık
	var title_lbl = Label.new()
	title_lbl.text = "🏛️ BÜYÜK MİTİNG LOBİSİ"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color(0.12, 0.18, 0.35))
	vbox.add_child(title_lbl)

	# Oyuncu Sayacı
	lobby_count_label = Label.new()
	lobby_count_label.text = "👥 Bağlı Oyuncular (Hazır: 0 / 0)"
	lobby_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lobby_count_label.add_theme_font_size_override("font_size", 13)
	lobby_count_label.add_theme_color_override("font_color", Color(0.35, 0.4, 0.5))
	vbox.add_child(lobby_count_label)

	# Geri Sayım Bandı
	lobby_countdown_label = Label.new()
	lobby_countdown_label.text = ""
	lobby_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lobby_countdown_label.add_theme_font_size_override("font_size", 16)
	lobby_countdown_label.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
	vbox.add_child(lobby_countdown_label)

	# Oyuncu Listesi (Scroll)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	lobby_player_list_vbox = VBoxContainer.new()
	lobby_player_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lobby_player_list_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(lobby_player_list_vbox)

	# Butonlar
	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 12)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_hbox)

	lobby_ready_btn = Button.new()
	lobby_ready_btn.custom_minimum_size = Vector2(160, 44)
	lobby_ready_btn.text = "✅ HAZIR OL"
	_apply_btn_texture(lobby_ready_btn, "yellow")
	lobby_ready_btn.mouse_entered.connect(func(): _play_ui_sound("res://sounds/rollover1.ogg", -6.0))
	lobby_ready_btn.pressed.connect(func(): _play_ui_sound("res://sounds/mouseclick1.ogg", 0.0); _on_lobby_ready_toggle_pressed())
	btn_hbox.add_child(lobby_ready_btn)

	lobby_start_btn = Button.new()
	lobby_start_btn.custom_minimum_size = Vector2(160, 44)
	lobby_start_btn.text = "🚀 OYUNU BAŞLAT"
	_apply_btn_texture(lobby_start_btn, "green")
	lobby_start_btn.mouse_entered.connect(func(): _play_ui_sound("res://sounds/rollover1.ogg", -6.0))
	lobby_start_btn.pressed.connect(func(): _play_ui_sound("res://sounds/task_complete.wav", 3.0); _on_lobby_start_pressed())
	btn_hbox.add_child(lobby_start_btn)

	var leave_btn = Button.new()
	leave_btn.custom_minimum_size = Vector2(120, 44)
	leave_btn.text = "🚪 MENÜ"
	_apply_btn_texture(leave_btn, "red")
	leave_btn.mouse_entered.connect(func(): _play_ui_sound("res://sounds/rollover1.ogg", -6.0))
	leave_btn.pressed.connect(func(): _play_ui_sound("res://sounds/mouseclick1.ogg", 0.0); _on_lobby_leave_pressed())
	btn_hbox.add_child(leave_btn)

func _play_ui_sound(path: String, vol: float = 0.0):
	var sfx = AudioStreamPlayer.new()
	var st = load(path) as AudioStream
	if st:
		sfx.stream = st
		sfx.volume_db = vol
		sfx.bus = "Master"
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(func(): sfx.queue_free())

func _apply_btn_texture(btn: Button, color_name: String):
	var tex = load("res://ui_kenney/%s_button00.png" % color_name)
	if not tex: return
	var sb = StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 10
	sb.texture_margin_right = 10
	sb.texture_margin_top = 8
	sb.texture_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15) if color_name in ["yellow", "grey"] else Color(1, 1, 1))
	btn.add_theme_font_size_override("font_size", 13)

func _on_host_pressed():
	var err = peer.create_server(9999)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
		# Host kendisini lobiye ekler
		var my_id = multiplayer.get_unique_id()
		lobby_players[my_id] = {
			"name": "👑 Host (Sen)",
			"ready": false,
			"is_host": true
		}
		_update_lobby_display()

func _on_join_pressed():
	var target_ip = "127.0.0.1"
	if get_node_or_null("/root/Global") and Global.server_ip != "":
		target_ip = Global.server_ip
	elif get_node_or_null("/root/Global") and Global.join_ip != "" and Global.join_ip != "127.0.0.1":
		target_ip = Global.join_ip

	var err = peer.create_client(target_ip, 9999)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server():
	var my_id = multiplayer.get_unique_id()
	rpc_id(1, "register_client_to_lobby", my_id)

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_peer_connected(id: int):
	if not multiplayer.is_server(): return
	if not lobby_players.has(id):
		lobby_players[id] = {
			"name": "🎮 Oyuncu %d" % id,
			"ready": false,
			"is_host": false
		}
	rpc("sync_lobby_data", lobby_players, is_counting_down, lobby_countdown)

func _on_peer_disconnected(id: int):
	if not multiplayer.is_server(): return
	if lobby_players.has(id):
		lobby_players.erase(id)
	if connected_players.has(id):
		connected_players.erase(id)
		var p_node = get_node_or_null(str(id))
		if p_node: p_node.queue_free()
	rpc("sync_lobby_data", lobby_players, is_counting_down, lobby_countdown)
	_check_all_ready()

@rpc("any_peer", "call_local")
func register_client_to_lobby(id: int):
	if not multiplayer.is_server(): return
	if not lobby_players.has(id):
		lobby_players[id] = {
			"name": "🎮 Oyuncu %d" % id,
			"ready": false,
			"is_host": false
		}
	rpc("sync_lobby_data", lobby_players, is_counting_down, lobby_countdown)

@rpc("any_peer", "call_local")
func sync_lobby_data(players_data: Dictionary, counting: bool, count_val: int):
	lobby_players = players_data
	is_counting_down = counting
	lobby_countdown = count_val
	_update_lobby_display()

func _update_lobby_display():
	if not lobby_player_list_vbox: return
	
	# Eski listeyi temizle
	for child in lobby_player_list_vbox.get_children():
		child.queue_free()
		
	var my_id = multiplayer.get_unique_id()
	var total_count = lobby_players.size()
	var ready_count = 0
	
	for pid in lobby_players.keys():
		var pinfo = lobby_players[pid]
		var is_ready = pinfo.get("ready", false)
		if is_ready: ready_count += 1
		
		var card = PanelContainer.new()
		var card_style = StyleBoxTexture.new()
		card_style.texture = load("res://ui_kenney/blue_panel.png")
		card_style.texture_margin_left = 8
		card_style.texture_margin_right = 8
		card_style.texture_margin_top = 6
		card_style.texture_margin_bottom = 6
		card.add_theme_stylebox_override("panel", card_style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		card.add_child(hbox)
		
		var name_lbl = Label.new()
		var p_name = pinfo.get("name", "Oyuncu")
		if pid == my_id:
			p_name += " (Sen)"
		name_lbl.text = p_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		hbox.add_child(name_lbl)
		
		var status_badge = PanelContainer.new()
		var badge_style = StyleBoxTexture.new()
		badge_style.texture = load("res://ui_kenney/%s_button00.png" % ("green" if is_ready else "grey"))
		badge_style.texture_margin_left = 6
		badge_style.texture_margin_right = 6
		badge_style.texture_margin_top = 4
		badge_style.texture_margin_bottom = 4
		status_badge.add_theme_stylebox_override("panel", badge_style)
		
		var badge_lbl = Label.new()
		badge_lbl.text = " ✅ HAZIR " if is_ready else " ⏳ BEKLİYOR "
		badge_lbl.add_theme_font_size_override("font_size", 12)
		badge_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		status_badge.add_child(badge_lbl)
		hbox.add_child(status_badge)
		
		lobby_player_list_vbox.add_child(card)

	if lobby_count_label:
		lobby_count_label.text = "👥 Bağlı Oyuncular (Hazır: %d / %d)" % [ready_count, total_count]

	# Benim hazır butonumun durumunu güncelle
	if lobby_ready_btn:
		var my_ready = lobby_players.get(my_id, {}).get("ready", false)
		if my_ready:
			lobby_ready_btn.text = "❌ HAZIR DEĞİL"
			_apply_btn_texture(lobby_ready_btn, "red")
		else:
			lobby_ready_btn.text = "✅ HAZIR OL"
			_apply_btn_texture(lobby_ready_btn, "yellow")

	# Host butonunun görünürlüğü
	if lobby_start_btn:
		var is_server = multiplayer.is_server()
		lobby_start_btn.visible = is_server
		lobby_start_btn.disabled = false

	# Geri sayım yazısı
	if lobby_countdown_label:
		if is_counting_down:
			lobby_countdown_label.text = "🚨 OYUN BAŞLIYOR: %d SANİYE..." % lobby_countdown
		else:
			lobby_countdown_label.text = ""

func _on_lobby_ready_toggle_pressed():
	var my_id = multiplayer.get_unique_id()
	rpc_id(1, "request_toggle_ready", my_id)

@rpc("any_peer", "call_local")
func request_toggle_ready(peer_id: int):
	if not multiplayer.is_server(): return
	if lobby_players.has(peer_id):
		lobby_players[peer_id]["ready"] = not lobby_players[peer_id]["ready"]
		rpc("sync_lobby_data", lobby_players, is_counting_down, lobby_countdown)
		_check_all_ready()

func _check_all_ready():
	if not multiplayer.is_server(): return
	if lobby_players.size() == 0: return
	
	var all_ready = true
	for pid in lobby_players.keys():
		if not lobby_players[pid].get("ready", false):
			all_ready = false
			break
			
	if all_ready and not is_counting_down and lobby_players.size() >= 1:
		_start_countdown_loop()
	elif not all_ready and is_counting_down:
		is_counting_down = false
		rpc("sync_lobby_data", lobby_players, false, 3)

func _start_countdown_loop():
	is_counting_down = true
	lobby_countdown = 3
	rpc("sync_lobby_data", lobby_players, true, lobby_countdown)
	
	while is_counting_down and lobby_countdown > 0:
		await get_tree().create_timer(1.0).timeout
		if not is_counting_down: return
		lobby_countdown -= 1
		rpc("sync_lobby_data", lobby_players, true, lobby_countdown)
		
	if is_counting_down and lobby_countdown <= 0:
		is_counting_down = false
		rpc("launch_match_from_lobby")

func _on_lobby_start_pressed():
	if not multiplayer.is_server(): return
	# Host tek tıkla geri sayımı tetikler ve başlatır
	if not is_counting_down:
		_start_countdown_loop()

func _on_lobby_leave_pressed():
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://menu.tscn")

@rpc("any_peer", "call_local")
func launch_match_from_lobby():
	current_game_state = GameState.PLAYING
	if lobby_canvas:
		lobby_canvas.hide()
	if has_node("TopBarHUD"):
		$TopBarHUD.show()
		
	if multiplayer.is_server():
		# Tüm lobi oyuncularını maça aktar
		connected_players = lobby_players.keys().duplicate()
		for pid in connected_players:
			var player = player_scene.instantiate()
			player.name = str(pid)
			add_child(player)
			
		_redistribute_roles()
		_spawn_npcs(130)
		_setup_ambient_audio()
		_setup_crowd_sounds()
		_start_match_timer()

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

func _spawn_npcs(count: int = 130):
	var total_spawned = 0
	
	# --- GRUP 1: SAHNE ÖNÜ COŞKULU DİNLEYİCİLER (~72 Kişi) ---
	for i in range(72):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var pos = Vector3(randf_range(-13.0, 13.0), 0.5, randf_range(-24.5, -9.5))
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(0) # STAGE_FANATIC
		
	# --- GRUP 2: WC VE BÜFE SIRASI BEKLEYENLER (~16 Kişi) ---
	for i in range(8):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var pos = Vector3(-26.0 + randf_range(-0.4, 0.4), 0.5, -16.0 + (i * 1.35))
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(1, pos) # WC_QUEUE
		
	for i in range(8):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var pos = Vector3(26.0 + randf_range(-0.4, 0.4), 0.5, -16.0 + (i * 1.35))
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(1, pos) # WC_QUEUE

	# --- GRUP 3: BANKLAR VE HAVUZ ÇEVRESİ DİNLENENLER (~14 Kişi) ---
	for i in range(14):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var roll = randf()
		var pos = Vector3.ZERO
		if roll < 0.35:
			pos = Vector3(-12.0 + randf_range(-1.2, 1.2), 0.5, -2.0 + randf_range(-0.6, 0.6))
		elif roll < 0.70:
			pos = Vector3(12.0 + randf_range(-1.2, 1.2), 0.5, -2.0 + randf_range(-0.6, 0.6))
		else:
			var angle = randf() * PI * 2
			pos = Vector3(cos(angle) * 4.5, 0.5, 6.0 + sin(angle) * 4.5)
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(2) # BENCH_RELAXER

	# --- GRUP 4: DIŞARIDA TURNİKE SIRASINDA DOĞANLAR (~28 Kişi) ---
	for i in range(28):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var pos = Vector3(randf_range(-7.0, 7.0), 0.5, randf_range(26.0, 42.0))
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(4) # QUEUE_ENTRANCE

	# --- GRUP 5: MEYDANDA SERBEST GEZEN SİVİLLER (~24 Kişi) ---
	for i in range(24):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_%d" % total_spawned
		total_spawned += 1
		var pos = Vector3(randf_range(-26.0, 26.0), 0.5, randf_range(0.0, 18.0))
		npc.position = pos
		add_child(npc, true)
		npc.set_archetype(3) # ROAMER # ROAMER
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
	if sfx_cheer and not sfx_cheer.playing:
		sfx_cheer.play()
	for n in get_tree().get_nodes_in_group("npcs"):
		if n and is_instance_valid(n) and n.has_method("trigger_cheer"):
			if n.global_position.distance_to(source) <= radius:
				n.trigger_cheer(4.5)

var news_ticker_panel: PanelContainer = null
var news_ticker_label: Label = null
var _news_ticker_timer: float = 0.0

func _create_news_ticker_ui():
	if not has_node("TopBarHUD"): return
	var top_hud = get_node("TopBarHUD")
	
	news_ticker_panel = PanelContainer.new()
	news_ticker_panel.name = "DynamicNewsTicker"
	news_ticker_panel.custom_minimum_size = Vector2(740, 44)
	news_ticker_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	news_ticker_panel.position = Vector2(0, 56)
	
	var style = StyleBoxTexture.new()
	var red_tex = load("res://ui_kenney/red_button00.png")
	if red_tex:
		style.texture = red_tex
		style.texture_margin_left = 14
		style.texture_margin_right = 14
		style.texture_margin_top = 8
		style.texture_margin_bottom = 8
	news_ticker_panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	news_ticker_panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)
	
	var badge = Label.new()
	badge.text = "🔴 SON DAKİKA:"
	badge.add_theme_font_size_override("font_size", 14)
	badge.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	hbox.add_child(badge)
	
	news_ticker_label = Label.new()
	news_ticker_label.text = "BAŞKAN MİTİNG ALANINDA HALKA HİTAP EDİYOR!"
	news_ticker_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_ticker_label.add_theme_font_size_override("font_size", 13)
	news_ticker_label.add_theme_color_override("font_color", Color(1, 1, 1))
	hbox.add_child(news_ticker_label)
	
	top_hud.add_child(news_ticker_panel)
	news_ticker_panel.hide()

@rpc("any_peer", "call_local")
func show_campaign_promise(promise_index: int):
	var PROMISES = [
		"BAŞKAN MÜJDELEDİ: 'HER MAHALLEYE BEDAVA DÖNER, ÇAY ÇEŞMESİ VE 1000 MBPS İNTERNET!'",
		"TARİHİ VAAT: 'EMEKLİLERE VE GENÇLERE ÇİFTE BAYRAM İKRAMİYESİ + HERKESE BEDAVA DRON!'",
		"BÜYÜK MİTİNG COŞKUSU: 'MİTİNG ALANI DÜNYANIN EN BÜYÜK MANGAL PARKI İLAN EDİLECEK!'",
		"SEÇİM BEYANNAMESİ: 'TÜM VERGİLER KALDIRILDI, ŞEHİR İÇİ ULAŞIM TAMAMEN ÜCRETSİZ!'"
	]
	var idx = clamp(promise_index, 0, PROMISES.size() - 1)
	var text_msg = PROMISES[idx]
	
	if not news_ticker_panel:
		_create_news_ticker_ui()
		
	if news_ticker_label and news_ticker_panel:
		news_ticker_label.text = text_msg
		news_ticker_panel.show()
		_news_ticker_timer = 8.0
		
	if sfx_cheer:
		sfx_cheer.play()
	play_stage_announcement("res://sounds/cheer_applause.wav")
		
	# Miting alanındaki halkı coştur
	trigger_crowd_cheer(Vector3(0, 0, -22), 45.0)

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

func _process(delta):
	if _trend_clear_timer > 0.0:
		_trend_clear_timer -= delta
		if _trend_clear_timer <= 0.0 and poll_trend_label:
			poll_trend_label.text = ""
			
	if _news_ticker_timer > 0.0:
		_news_ticker_timer -= delta
		if _news_ticker_timer <= 0.0 and news_ticker_panel:
			news_ticker_panel.hide()

@rpc("any_peer", "call_local")
func sync_poll_score(score: float, trend_msg: String = ""):
	president_poll_pct = clamp(score, 0.0, 100.0)
	var opp_score = 100.0 - president_poll_pct
	if pres_vote_label:
		pres_vote_label.text = "👑 BAŞKAN: %" + str(snapped(president_poll_pct, 0.1))
	if opp_vote_label:
		opp_vote_label.text = "⚔️ MUHALEFET: %" + str(snapped(opp_score, 0.1))
	if vote_progress_bar:
		vote_progress_bar.value = president_poll_pct
	if poll_trend_label and trend_msg != "":
		poll_trend_label.text = trend_msg
		_trend_clear_timer = 4.0

func adjust_poll_score(delta_pct: float, reason: String = ""):
	president_poll_pct = clamp(president_poll_pct + delta_pct, 0.0, 100.0)
	sync_poll_score(president_poll_pct, reason)
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		rpc("sync_poll_score", president_poll_pct, reason)

@rpc("any_peer", "call_local")
func sync_timer(seconds: int):
	match_seconds = seconds
	if timer_label:
		var mins = seconds / 60
		var secs = seconds % 60
		timer_label.text = "%02d:%02d" % [mins, secs]
