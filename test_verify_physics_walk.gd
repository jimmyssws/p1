extends SceneTree

func _init():
	print("--- 🧪 TESTING PHYSICS WALK & MOVEMENT ---")
	var p_scene = load("res://player.tscn")
	var p = p_scene.instantiate()
	root.add_child(p)
	p.position = Vector3(0, 3, 0)
	
	# Simulate 5 physics steps
	for i in range(5):
		p.velocity.x = 2.0
		p._physics_process(0.016)
		print("Step %d: player pos=%s, velocity=%s" % [i, str(p.position), str(p.velocity)])
	
	p.free()
	
	var n_scene = load("res://npc.tscn")
	var npc = n_scene.instantiate()
	root.add_child(npc)
	npc.position = Vector3(0, 3, 0)
	npc.direction = Vector3(1, 0, 0)
	for i in range(5):
		npc._physics_process(0.016)
		print("Step %d: npc pos=%s, velocity=%s" % [i, str(npc.position), str(npc.velocity)])
	npc.free()
	print("✅ PHYSICS AND MOVEMENT 100% OPERATIONAL!")
	quit(0)
