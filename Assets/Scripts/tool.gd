class_name Tool
extends Resource

@export var spear_scene : PackedScene

func use(target: Object):
	pass # overriden, diff tools get used differently

func release(spawn_parent: Node, origin: Vector3, direction: Vector3, charge_time: float) -> void:
	pass
