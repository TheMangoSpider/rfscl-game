class_name Pickupable
extends RigidBody3D

@export var underwater_speed := 3.0
@export var item_name: String
var underwater := false
var original_mask: int

func _ready() -> void:
	original_mask = collision_mask

func pickup_visuals() -> Node3D:
	freeze = true
	collision_layer = 0
	collision_mask = 0
	return self

func drop_visuals(drop_position: Vector3):
	freeze = false
	collision_layer = 1
	collision_mask = original_mask
	global_position = drop_position

func _process(delta: float) -> void:
	if underwater:
		linear_velocity.y += underwater_speed * delta
