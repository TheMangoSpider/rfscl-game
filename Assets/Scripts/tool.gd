class_name Tool
extends Resource

@export var tool_scene: PackedScene
var tool_node: Node3D

func use():
	pass # overriden, diff tools get used differently

func release(spawn_parent: Node, origin: Vector3, direction: Vector3, charge_time: float) -> void:
	pass
