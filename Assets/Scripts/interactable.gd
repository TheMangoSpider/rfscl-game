class_name Interactable
extends Node3D

@export var health: int
@export var drop: PackedScene
@export var toolType: Tool

func interact(tool: Tool) -> void:
	print("hit")
	if not is_valid_tool(tool):
		return
	print("hurt")
	if multiplayer.is_server():
		_take_damage()
		print("hurt")
	else:
		_request_damage.rpc_id(1)

func is_valid_tool(tool: Tool) -> bool:
	return true


@rpc("any_peer", "call_local")
func _request_damage() -> void:
	if not multiplayer.is_server():
		return
	_take_damage()

func _take_damage() -> void:
	health -= 1
	if health <= 0:
		_die.rpc()

@rpc("authority", "call_local")
func _die() -> void:
	var drop = drop.instantiate()
	drop.name = "drop_" + str(get_path()).md5_text().substr(0, 8)  # unique name needed
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
	queue_free()
