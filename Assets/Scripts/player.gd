extends CharacterBody3D

var spawn_position:= Vector3(0, 5, 0)
@export var selected_class := "Farmer"

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

@export var swim_up_speed := 8.0
@export var underwater_gravity := 0.2
@export var water_accel := 15.0
@export var water_drag := 20.0
@export var water_cap := 7.0

# Air vars that prob need to be tweaked to get it right
## the vars air cap and accel determine the feel of bhopping/airstrafing. speed caps must
## be implemented through external systems like friction, drag, or variability in those two
@export var air_cap := 2.0 # if higher can surf steeper ramps
@export var air_accel := 2.0
@export var air_move_speed := 500.0

@export var uncapped_speed := false
@export var uncapped_ground_accel := 11.0
@export var uncapped_air_accel := 15.0

@export var underwater: ColorRect

var wish_dir := Vector3.ZERO

const ROLE_DATA = {
	"Farmer": preload("res://Assets/Resources/Roles/farmer_data.tres"),
	"Fisher": preload("res://Assets/Resources/Roles/fisher_data.tres"),
	"Engineer": preload("res://Assets/Resources/Roles/engineer_data.tres"),
	"Chef": preload("res://Assets/Resources/Roles/chef_data.tres"),
}

func _get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _ready():
	call_deferred("_deferred_ready")

func _deferred_ready():
	print("selected_class: ", selected_class)
	print("all selected classes: ", NetworkManager.selected_classes)
	print("PLAYER READY START")
	
	var data = ROLE_DATA[selected_class]
	apply_role($Role, data)
	
	print("role script: ", $Role.get_script())
	print("role has unhandled input: ", $Role.has_method("_unhandled_input"))
	
	if is_multiplayer_authority():
		position = spawn_position
		%Camera3D.make_current()
		
		for child in %WorldModel.find_children("*", "VisualInstance3D"):
			child.set_layer_mask_value(1, false)
			child.set_layer_mask_value(2, true)
	else:
		$BuildingWheelLayer.visible = false
		$ColorRect.visible = false
	
	# call tree ui ready cause its no autocalled
	$SkillTreeLayer/SkillTreeUI._ready()

func _enter_tree() -> void:
	print("enter tree, name: ", name, " to_int: ", name.to_int())
	var id = name.to_int()
	if id > 0:
		set_multiplayer_authority(id)
		$StateSync.set_multiplayer_authority(id)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	# when skill tree open, only allow escape to close
	if $SkillTreeLayer/SkillTreeUI.visible:
		if event.is_action_pressed("ui_cancel"):
			$SkillTreeLayer/SkillTreeUI.close()
		return
	
	if event.is_action_pressed("menu"):
		var skill_ui = $SkillTreeLayer/SkillTreeUI
		if skill_ui.visible:
			skill_ui.close()
		else:
			skill_ui.open()
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	$Role._unhandled_input(event)

func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	
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
	
	## apply a reduction in speed when landing a bhop to prevent rapid speed increase (effectively acts as a cap unless you're goated)
	## could run into issues later if there are other ways to increase speed
	if self.velocity.length() > 10:
		velocity *= 0.95
	
	_headbob_effect(delta)

func _handle_underwater_physics(delta) -> void:
	velocity.x = lerp(velocity.x, 0.0, water_drag * delta)
	velocity.z = lerp(velocity.z, 0.0, water_drag * delta)
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), water_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	velocity.y = lerp(velocity.y, -2.0, 5.0 * delta) ## no shot ts called lerp
	# vertical stuff
	if Input.is_action_pressed("jump"):
		velocity.y = lerp(velocity.y, swim_up_speed, 8.0 * delta)

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	var input_dir = Input.get_vector("left", "right", "forward", "back").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if is_on_floor():
		if Input.is_action_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
			self.velocity.y = jump_vel
		_handle_ground_physics(delta)
	else:
		if underwater.visible:
			_handle_underwater_physics(delta)
		else:
			_handle_air_physics(delta)
	
	## speed label (idk if it should go here or not but this is where your "print(velocity)" was
	#var speed_label: Label = $speed_label
	#var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	#speed_label.text = "Speed: %d" % horizontal_velocity.length()
	
	move_and_slide()

func apply_role(role_node: Node, data: RoleData) -> void:
	print("APPLY ROLE START, data: ", data, " hand: ", data.hand if data else "null")
	print("apply_role called, data: ", data)
	print("data.hand: ", data.hand if data else "data is null")
	print("data.role_script: ", data.role_script if data else "data is null")
	role_node.set_script(data.role_script)
	
	role_node.hand = data.hand
	
	#fisher
	if data.spear_tool:
		role_node.spear_tool = data.spear_tool
	
	#farmer
	if data.hoe_tool:
		role_node.hoe_tool = data.hoe_tool
		role_node.farm_tile_scene = data.farm_tile_scene
		role_node.farm_tile_preview_scene = data.farm_tile_preview_scene
	
	#chef
	if data.knife_tool:
		role_node.knife_tool = data.knife_tool
	
	#engineer
	if data.axe_tool:
		role_node.axe_tool = data.axe_tool
		role_node.pickaxe_tool = data.pickaxe_tool
		role_node.hammer_tool = data.hammer_tool
		role_node.build_base_scene = data.build_base_scene
		role_node.build_tile_preview_scene = data.build_tile_preview_scene
	
	role_node._initialized = true 
	role_node._ready()
	var skill_tree = data.skill_tree_scene.instantiate()
	role_node.add_child(skill_tree)

func _process(delta) -> void:
	if is_multiplayer_authority():
		$Role._process(delta)
