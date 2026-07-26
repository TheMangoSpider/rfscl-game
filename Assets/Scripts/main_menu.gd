extends Control

func _on_host_pressed():
	NetworkManager.host()
	get_tree().change_scene_to_file("res://Assets/Scenes/class_select.tscn")

func _on_join_pressed():
	NetworkManager.join("127.0.0.1")
	get_tree().change_scene_to_file("res://Assets/Scenes/class_select.tscn")
