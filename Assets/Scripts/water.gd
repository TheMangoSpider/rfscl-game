extends Node3D

@export var underwater: ColorRect

func _on_area_3d_area_exited(area: Area3D) -> void:
	if underwater.visible:
		underwater.visible = false
		return
	underwater.visible = true
