class_name FarmTile
extends Node3D

var is_planted := false

func plant(seed: SeedPacket):
	if is_planted:
		return
	is_planted = true
	var crop = preload("res://Assets/Scenes/crop.tscn").instantiate()
	crop.growth_stages = seed.growth_stages.duplicate()
	crop.growth_time = seed.growth_time
	crop.result = seed.result
	get_tree().current_scene.add_child(crop)
	crop.global_position = global_position
