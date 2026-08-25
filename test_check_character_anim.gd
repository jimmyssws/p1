extends SceneTree

func _init():
	var scene = load("res://models_animated/character_animated.glb")
	if not scene:
		print("❌ Failed to load GLB")
		quit(1)
		return
	var inst = scene.instantiate()
	print("✅ GLB Instantiated successfully!")
	print("Node hierarchy:")
	_print_tree(inst, "")
	quit(0)

func _print_tree(node: Node, prefix: String):
	var extra = ""
	if node is AnimationPlayer:
		var anims = node.get_animation_list()
		extra = " [AnimationPlayer with %d anims: %s]" % [anims.size(), str(anims)]
	print(prefix, "- ", node.name, " (", node.get_class(), ")", extra)
	for c in node.get_children():
		_print_tree(c, prefix + "  ")
