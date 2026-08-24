extends Node3D

var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")
var npc_scene = preload("res://npc.tscn")
var connected_players = [] # Oyuncu ID'lerini burada tutacağız

@onready var host_btn = $CanvasLayer/LobbyPanel/HostButton if has_node("CanvasLayer/LobbyPanel/HostButton") else ($CanvasLayer/HostButton if has_node("CanvasLayer/HostButton") else null)
@onready var join_btn = $CanvasLayer/LobbyPanel/JoinButton if has_node("CanvasLayer/LobbyPanel/JoinButton") else ($CanvasLayer/JoinButton if has_node("CanvasLayer/JoinButton") else null)
@onready var ip_input = $CanvasLayer/LobbyPanel/IpInput if has_node("CanvasLayer/LobbyPanel/IpInput") else null

func _ready():
	if host_btn:
		host_btn.pressed.connect(_on_host_pressed)
	if join_btn:
		join_btn.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()
	_add_player(multiplayer.get_unique_id())
	_spawn_npcs(20) # Oyunu kurunca haritaya 20 sivil atar

func _on_join_pressed():
	var target_ip = "127.0.0.1"
	if ip_input and ip_input.text.strip_edges() != "":
		target_ip = ip_input.text.strip_edges()
		
	peer.create_client(target_ip, 9999)
	multiplayer.multiplayer_peer = peer
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()

func _add_player(id):
	connected_players.append(id) # Yeni gelen oyuncuyu listeye ekle
	
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)
	
	# Her yeni oyuncu geldiğinde rolleri yeniden hesapla ve dağıt
	_redistribute_roles()

func _redistribute_roles():
	# Sadece sunucu rol dağıtımı yapabilir
	if not multiplayer.is_server(): return
	
	# Kodun sapıtmaması için oyuncu listesini kopyalıyoruz
	var players_to_assign = connected_players.duplicate()
	
	# 1. KURAL: İlk oyuncuyu her zaman BAŞKAN yap (Lobi kurucusu)
	var president_id = players_to_assign[0]
	var pres_node = get_node_or_null(str(president_id))
	if pres_node:
		pres_node.rpc("assign_role", "PRESIDENT")
	players_to_assign.erase(president_id)
	
	# 2. KURAL: Eğer başka oyuncu varsa, birini rastgele SUİKASTÇI yap
	if players_to_assign.size() > 0:
		var assassin_id = players_to_assign[randi() % players_to_assign.size()]
		var ass_node = get_node_or_null(str(assassin_id))
		if ass_node:
			ass_node.rpc("assign_role", "ASSASSIN")
		players_to_assign.erase(assassin_id)
		
	# 3. KURAL: Geriye kalan herkesi (3. ve 4. kişileri) KORUMA yap
	for guard_id in players_to_assign:
		var guard_node = get_node_or_null(str(guard_id))
		if guard_node:
			guard_node.rpc("assign_role", "GUARD")

# Bu fonksiyon ağdaki herkeste çalışarak tüm oyuncuların ekranını dondurur ve bitiş ekranını açar
@rpc("any_peer", "call_local")
func net_game_over(message: String):
	for child in get_children():
		if child.has_method("local_game_over"):
			child.local_game_over(message)

func _spawn_npcs(amount):
	for i in range(amount):
		var npc = npc_scene.instantiate()
		npc.name = "NPC_" + str(i) 
		npc.position = Vector3(randf_range(-20, 20), 2, randf_range(-20, 20))
		add_child(npc, true)
