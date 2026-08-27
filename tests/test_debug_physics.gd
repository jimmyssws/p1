extends SceneTree

func _init():
	print("--- 🧪 DEBUGGING PHYSICS & MOVEMENT ---")
	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	
	# Simulate 30 physics frames
	for i in range(30):
		# Let's inspect player and first NPC
		var players = root.get_tree().get_nodes_in_group("players")
		var npcs = root.get_tree().get_nodes_in_group("npcs")
		if i == 5 or i == 25:
			print("Frame %d: Players count = %d, NPCs count = %d" % [i, players.size(), npcs.size()])
			if players.size() > 0:
				var p = players[0]
				print("Player pos: %s, on_floor: %s, velocity: %s" % [str(p.global_position), str(p.is_on_floor()), str(p.velocity)])
			if npcs.size() > 0:
				var npc = npcs[0]
				print("NPC 0 pos: %s, on_floor: %s, velocity: %s, state: %s" % [str(npc.global_position), str(npc.is_on_floor()), str(npc.velocity), str(npc.current_state)])
	
	print("Simulation finished.")
	quit(0)
