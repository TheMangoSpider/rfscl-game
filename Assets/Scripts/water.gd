extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Pickupable:
		body.underwater = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Pickupable:
		body.underwater = false
		body.linear_velocity.y = 0

func _process(_delta) -> void:
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group(&"Player") and body.is_multiplayer_authority():
			var camera = body.get_node("%Camera3D")
			var underwater = body.get_node("ColorRect")
			var water_surface = global_position.y + $Area3D/CollisionShape3D.shape.size.y / 2
			underwater.visible = camera.global_position.y < 0
