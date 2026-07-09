extends Node3D

var dont_build:= false
var deplant:= false
var curr_tile

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is BuildingBase:
		dont_build = true
	elif body is FarmTile:
		deplant = true
		curr_tile = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is BuildingBase:
		dont_build = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is FarmTile:
		deplant = true
		curr_tile = area.get_parent()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() is FarmTile:
		deplant = false
		curr_tile = null
