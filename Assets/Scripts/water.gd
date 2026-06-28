extends Node3D

@export var underwater: ColorRect

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		underwater.visible = true
	elif body is Pickupable:
		body.underwater = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		underwater.visible = false
	elif body is Pickupable:
		body.underwater = false
		body.linear_velocity.y = 0
