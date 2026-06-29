class_name Pickupable
extends RigidBody3D

@export var underwater_speed := 3.0
@export var item_name: String
var underwater := false

func pickup_visuals() -> Node3D:
	freeze = true
	collision_layer = 0
	collision_mask = 0
	return self

func drop_visuals(drop_position: Vector3):
	freeze = false
	collision_layer = 1
	collision_mask = 5
	global_position = drop_position

func _process(delta: float) -> void:
	if underwater:
		linear_velocity.y += underwater_speed * delta
