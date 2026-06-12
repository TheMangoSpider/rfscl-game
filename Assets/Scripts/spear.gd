class_name SpearTool
extends Tool

@export var max_charge_time := 1.5
@export var min_throw_force := 10.0
@export var max_throw_force := 40.0

var is_charging := false
var charge_time := 0.0

func _process(delta: float) -> void:
	if is_charging:
		charge_time = min(charge_time + delta, max_charge_time)

func use(target: Object):
	is_charging = true
	charge_time = 0.0

func release(spawn_parent: Node, origin: Vector3, direction: Vector3, charge_time: float) -> void:
	var force = lerp(min_throw_force, max_throw_force, charge_time / max_charge_time)
	var spear_instance = spear_scene.instantiate()
	spear_instance.global_position = origin
	spear_instance.launch(direction * force)
	spawn_parent.add_child(spear_instance)
