class_name Role
extends Node

var tools : Array[Tool] = []
var active_tool : int = 0
var tool_node: Node3D
var held_item: Node3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		var target = get_raycast_target()
		if target is Pickupable:
			pickup(target)
		elif held_item:
			pickup(null)

func _interact():
	tools[active_tool].use()

func swap_tool():
	if active_tool == tools.size() - 1:
		active_tool = 0
	else:
		active_tool += 1;
	
	equip_tool(tools[active_tool])

func equip_tool(tool: Tool) -> void:
	if tool_node:
		tool_node.queue_free()
	tool_node = tool.tool_scene.instantiate()
	tool.tool_node = tool_node
	if not tool.get("is_projectile"):
		tool_node.tool_resource = tool
	else:
		tool_node.gravity_scale = 0
		tool_node.freeze = true
	
	%ToolHolder.add_child(tool_node)

func pickup(pickupable: Pickupable) -> void:
	if held_item:
		#drop held item by making its parent the world and not player
		held_item.reparent(get_tree().current_scene)
		held_item.drop_visuals(get_parent().global_position + (-get_parent().global_basis.z * 1.0))
		held_item = null
	if pickupable:
		pickupable.pickup_visuals()
		pickupable.reparent(%ItemHolder)
		pickupable.position = Vector3.ZERO
		held_item = pickupable

func get_raycast_target() -> Pickupable:
	var space = %Camera3D.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(
		%Camera3D.global_position,
		%Camera3D.global_position + (-%Camera3D.global_basis.z * 2.0)
	)
	var result = space.intersect_ray(ray)
	if result and result.collider is Pickupable:
		return result.collider
	return null
