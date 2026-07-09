class_name FarmTile
extends Node3D

var is_planted := false

func plant(crop: PackedScene):
	if is_planted:
		return
	is_planted = true
	var crop_instance = crop.instantiate()
	get_tree().current_scene.add_child(crop_instance)
	crop_instance.global_position = global_position
