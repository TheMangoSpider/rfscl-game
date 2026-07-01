extends StaticBody3D

@export var input_name : String
@export var anim_name: String
@export var output_scene: PackedScene
@export var spawn_pos: Vector3

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Pickupable and body.item_name == input_name:
		body.queue_free()
		%AnimationPlayer.play(anim_name)
		await get_tree().create_timer(1.5).timeout
		
		var output = output_scene.instantiate()
		add_child(output)
		output.position = spawn_pos
