class_name Pickupable
extends Node

@export var item_scene: PackedScene
var drop_scene: PackedScene
@export var item_name: String

func _ready() -> void:
	if not drop_scene:
		drop_scene = load(scene_file_path)
