class_name SpearProjectile
extends RigidBody3D

var launch_velocity := Vector3.ZERO

func launch(velocity: Vector3):
	launch_velocity = velocity

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if launch_velocity != Vector3.ZERO:
		state.linear_velocity = launch_velocity
		launch_velocity = Vector3.ZERO 

func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0.1:
		var up = Vector3.UP
		
		if abs(linear_velocity.normalized().dot(Vector3.UP)) > 0.95:
			up = Vector3.FORWARD
		
		var target_basis = Basis.looking_at(linear_velocity, up)
		basis = target_basis * Basis.from_euler(Vector3(deg_to_rad(90), 0, 0))

func _on_body_entered(body: Node) -> void:
	if body.has_node("Interactable"):
		body.get_node("Interactable").interact(null)  # for future fish detection
	freeze = true               
	await get_tree().create_timer(0.1).timeout
	queue_free()
