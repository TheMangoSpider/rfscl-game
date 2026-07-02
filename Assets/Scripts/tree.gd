class_name TreePlant
extends Interactable

@export var health := 1
@export var tree_drop: PackedScene

func interact(tool: Tool) -> void:
	print("hit")
	if tool is not AxeTool:
		return
	print("hurt")
	if multiplayer.is_server():
		_take_damage()
		print("hurt")
	else:
		_request_damage.rpc_id(1)
	
	if health <= 0:
		_die.rpc()

#func spawn_drop() -> void:
	#print("spawn")
	#var drop = tree_drop.instantiate()
	#get_tree().current_scene.add_child(drop)
	#drop.global_position = self.global_position

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
	var drop = tree_drop.instantiate()
	drop.name = str(randi())  # unique name needed
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
	queue_free()
