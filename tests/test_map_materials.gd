extends SceneTree

const SCENE_PATH := "res://scenes/main.tscn"
const MATERIAL_PATHS := {
	"plaza": "res://assets/materials/plaza_concrete.tres",
	"building": "res://assets/materials/building_brick.tres",
	"stage_wood": "res://assets/materials/stage_wood.tres",
	"stage_metal": "res://assets/materials/stage_metal.tres",
	"barrier": "res://assets/materials/barrier_metal.tres",
	"furniture": "res://assets/materials/furniture_wood.tres",
}

var failures: Array[String] = []

func _init() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "main scene loads as PackedScene")
	if packed == null:
		_finish()
		return
	var map := packed.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	_check_required_direct_children(map)
	_check_material_resources()
	_check_serialized_assignments(map)
	_check_unique_sibling_names(map)
	_check_unique_scene_ids()
	_check_grounded_roots(map)
	_check_collision_alignment(map)
	map.free()
	_finish()

func _check_required_direct_children(map: Node) -> void:
	for node_name in ["PlazaGround", "StagePlatform", "Building_A", "Building_B", "Building_C", "Building_D", "Building_E", "Building_F", "Building_G", "Building_H"]:
		_check(map.get_node_or_null(node_name) != null, "%s is a direct child" % node_name)

func _check_material_resources() -> void:
	for label in MATERIAL_PATHS:
		var material := load(MATERIAL_PATHS[label]) as StandardMaterial3D
		_check(material != null, "%s material loads" % label)
		if material:
			_check(material.uv1_triplanar, "%s material uses UV1 triplanar" % label)
			_check(material.albedo_texture != null, "%s material has albedo texture" % label)
			_check(material.normal_enabled and material.normal_texture != null, "%s material has normal texture" % label)
			_check(material.roughness_texture != null, "%s material has roughness texture" % label)

func _check_serialized_assignments(map: Node) -> void:
	_check_mesh_material(map.get_node_or_null("PlazaGround/GroundMesh"), MATERIAL_PATHS.plaza, "plaza ground")
	_check_mesh_material(map.get_node_or_null("StagePlatform/StageMesh"), MATERIAL_PATHS.stage_wood, "stage deck")
	_check_mesh_material(map.get_node_or_null("StagePlatform/BackdropMesh"), MATERIAL_PATHS.stage_metal, "stage backdrop")
	for letter in ["A", "B", "C", "D", "E", "F", "G", "H"]:
		var building := map.get_node_or_null("Building_%s" % letter)
		_check(building != null and building.get("material") != null, "Building_%s wrapper serializes its material" % letter)
		if building and building.has_method("apply_material_override"):
			building.apply_material_override()
		var mesh := _find_first_mesh(building)
		_check_mesh_material(mesh, MATERIAL_PATHS.building, "Building_%s" % letter)
	for path in ["Barrier_Left/BarrierMesh", "Barrier_Right/BarrierMesh", "SecurityCheckpoint/Barrier_Left_Wing/BarrierMesh", "SecurityCheckpoint/Barrier_Right_Wing/BarrierMesh"]:
		_check_mesh_material(map.get_node_or_null(path), MATERIAL_PATHS.barrier, path)
	for path in ["Tent_Water/Table/TableMesh", "Tent_Press/Table/TableMesh", "Bench_1/BenchMesh", "Bench_2/BenchMesh"]:
		_check_mesh_material(map.get_node_or_null(path), MATERIAL_PATHS.furniture, path)

func _check_mesh_material(node: Node, expected_path: String, label: String) -> void:
	_check(node is MeshInstance3D, "%s mesh exists" % label)
	if not node is MeshInstance3D:
		return
	var mesh_instance := node as MeshInstance3D
	var material := mesh_instance.get_surface_override_material(0)
	if material == null:
		material = mesh_instance.material_override
	_check(material != null, "%s has serialized material override" % label)
	if material:
		_check(material.resource_path == expected_path, "%s uses %s" % [label, expected_path])

func _find_first_mesh(node: Node) -> MeshInstance3D:
	if node == null:
		return null
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_first_mesh(child)
		if found:
			return found
	return null

func _check_unique_sibling_names(node: Node, logical_path: String = "main") -> void:
	var seen := {}
	for child in node.get_children():
		_check(not seen.has(child.name), "unique sibling name %s/%s" % [logical_path, child.name])
		seen[child.name] = true
		_check_unique_sibling_names(child, "%s/%s" % [logical_path, child.name])

func _check_unique_scene_ids() -> void:
	var file := FileAccess.open(SCENE_PATH, FileAccess.READ)
	_check(file != null, "scene text opens for unique-id validation")
	if file == null:
		return
	var text := file.get_as_text()
	var regex := RegEx.new()
	regex.compile("unique_id=([0-9]+)")
	var seen := {}
	for result in regex.search_all(text):
		var value := result.get_string(1)
		_check(not seen.has(value), "serialized unique_id %s appears once" % value)
		seen[value] = true

func _check_grounded_roots(map: Node) -> void:
	for node_name in ["Building_A", "Building_B", "Building_C", "Building_D", "Building_E", "Building_F", "Building_G", "Building_H", "RallyFlag_Left", "RallyFlag_Right", "WatchTower_L", "WatchTower_R", "CentralFountain", "PoliceCar", "TaxiCar", "StreetTree_L1", "StreetTree_R1", "Bush_L1", "Bush_R1", "Trash_1", "Trash_2", "Hydrant_1", "StreetLight_1", "StreetLight_2", "PlazaBench_1", "PlazaBench_2"]:
		var node := map.get_node_or_null(node_name) as Node3D
		_check(node != null, "%s exists for grounding check" % node_name)
		if node:
			_check(is_zero_approx(node.position.y), "%s model root is grounded at Y=0" % node_name)
	_check_box_bottom(map.get_node_or_null("PlazaGround/GroundMesh"), "PlazaGround")
	_check_box_bottom(map.get_node_or_null("StagePlatform/StageMesh"), "StagePlatform")
	for node_name in ["LightTower_Left", "SoundTower_Right", "Barrier_Left", "Barrier_Right", "Buffet_Left", "Buffet_Right", "Bench_1", "Bench_2", "WC_1", "WC_2", "PortableWC_1", "PortableWC_2", "EntranceGate"]:
		var body := map.get_node_or_null(node_name) as Node3D
		if body:
			var mesh := _find_first_mesh(body)
			_check_box_bottom(mesh, node_name)

func _check_box_bottom(mesh_node: Node, label: String) -> void:
	_check(mesh_node is MeshInstance3D, "%s has a procedural mesh" % label)
	if not mesh_node is MeshInstance3D:
		return
	var mesh_instance := mesh_node as MeshInstance3D
	_check(mesh_instance.mesh is BoxMesh, "%s uses BoxMesh" % label)
	if not mesh_instance.mesh is BoxMesh:
		return
	var box := mesh_instance.mesh as BoxMesh
	var world_y := mesh_instance.position.y
	var parent := mesh_instance.get_parent()
	while parent is Node3D:
		world_y += (parent as Node3D).position.y
		parent = parent.get_parent()
	_check(absf(world_y - box.size.y * mesh_instance.scale.y * 0.5) < 0.01, "%s box bottom is aligned to Y=0" % label)

func _check_collision_alignment(map: Node) -> void:
	for pair in [
		["PlazaGround/GroundMesh", "PlazaGround/GroundCollision"],
		["StagePlatform/StageMesh", "StagePlatform/StageCollision"],
		["Barrier_Left/BarrierMesh", "Barrier_Left/BarrierCollision"],
		["Barrier_Right/BarrierMesh", "Barrier_Right/BarrierCollision"],
		["SecurityCheckpoint/Barrier_Left_Wing/BarrierMesh", "SecurityCheckpoint/Barrier_Left_Wing/BarrierCollision"],
		["SecurityCheckpoint/Barrier_Right_Wing/BarrierMesh", "SecurityCheckpoint/Barrier_Right_Wing/BarrierCollision"],
	]:
		var mesh := map.get_node_or_null(pair[0]) as MeshInstance3D
		var collision := map.get_node_or_null(pair[1]) as CollisionShape3D
		_check(mesh != null and collision != null, "%s collision pair exists" % pair[0])
		if mesh and collision:
			_check(mesh.transform.is_equal_approx(collision.transform), "%s mesh and collision transforms align" % pair[0])
			_check(mesh.mesh is BoxMesh and collision.shape is BoxShape3D, "%s uses matching box geometry" % pair[0])
			if mesh.mesh is BoxMesh and collision.shape is BoxShape3D:
				_check((mesh.mesh as BoxMesh).size.is_equal_approx((collision.shape as BoxShape3D).size), "%s mesh and collision sizes align" % pair[0])

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL: %s" % message)

func _finish() -> void:
	if failures.is_empty():
		print("MAP MATERIAL TESTS PASSED")
		quit(0)
	else:
		printerr("MAP MATERIAL TESTS FAILED: %d failure(s)" % failures.size())
		quit(1)
