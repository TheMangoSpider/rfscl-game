class_name TreePlant
extends Interactable

@export var health := 1
@export var tree_drop: PackedScene

func interact(tool: Tool) -> void:
	print("hit")
	if tool is not AxeTool:
		return
	print("hurt")
	health -= 1
	if health <= 0:
		spawn_drop()
		queue_free()

func spawn_drop() -> void:
	print("spawn")
	var drop = tree_drop.instantiate()
	get_tree().current_scene.add_child(drop)
	drop.global_position = self.global_position
