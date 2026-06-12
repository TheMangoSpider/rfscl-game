extends CharacterBody3D

@export var look_sensitivity : float = 0.006
@export var jump_vel := 6.0
@export var auto_bhop := true

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_time := 0.0

#Ground movment settings can be easily tweaked for bhop and more
@export var walk_speed := 7.0
@export var sprint_speed := 9
@export var ground_accel := 11.0
@export var ground_decel := 7.0
@export var ground_friction := 3.5

#Air vars that prob need to be tweaked to get it right
@export var air_cap := 0.85 #if higher can surf steeper ramps (btw surfing not implmented yet cause I dont really think its necessary atm)
@export var air_accel := 800.0
@export var air_move_speed := 500.0

@export var uncapped_speed := true
@export var uncapped_ground_accel := 11.0
@export var uncapped_air_accel := 15.0

var wish_dir := Vector3.ZERO

func _get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func _process(delta):
	pass

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	
	if uncapped_speed:
		var strafe_factor = 1.0 - max(cur_speed_in_wish_dir / walk_speed, 0.0)
		var accel_speed = uncapped_air_accel * strafe_factor * delta
		self.velocity += accel_speed * wish_dir
	else:
		var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
		var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
		if add_speed_till_cap > 0:
			var accel_speed = air_accel * air_move_speed * delta
			accel_speed = min(accel_speed, add_speed_till_cap)
			self.velocity += accel_speed * wish_dir

func _handle_ground_physics(delta) -> void:
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = _get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = (uncapped_ground_accel if uncapped_speed else ground_accel) * delta * _get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap) if not uncapped_speed else accel_speed
		self.velocity += accel_speed * wish_dir
	
	# always apply friction, uncapped just means no speed ceiling
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed
	
	_headbob_effect(delta)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
			self.velocity.y = jump_vel
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	print(velocity)
	move_and_slide()
