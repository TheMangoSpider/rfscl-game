extends Node3D

var dont_build:= false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is BuildingBase:
		dont_build = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is BuildingBase:
		dont_build = false
