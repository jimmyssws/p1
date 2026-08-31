@tool
extends Node3D
## Applies one serialized material to every mesh in an imported GLTF subtree.
## Keeping the GLTF as a child instance avoids editing/reimporting source assets.

@export var material: Material

func _ready() -> void:
	apply_material_override()

func apply_material_override() -> void:
	if material == null:
		return
	_apply_to_descendants(self)

func _apply_to_descendants(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = material
		_apply_to_descendants(child)
