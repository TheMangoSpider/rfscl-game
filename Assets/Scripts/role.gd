class_name Role
extends Node

@export var hand: Hand

var tools : Array[Tool] = []
var active_tool : int = 0
var tool_node: Node3D
var held_item: Node3D

func _ready() -> void:
	var id = get_parent().name.to_int()
	if id > 0 and id != multiplayer.get_unique_id():
		return
	
	tools.append(hand)

func _process(delta: float) -> void:
	if not get_parent().is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("switch"):
		swap_tool()

func _unhandled_input(event):
	if not get_parent().is_multiplayer_authority():
		return
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
	#if multiplayer.is_server():
		#_do_pickup.rpc(get_parent().name, pickupable.get_path() if pickupable else ^"")
	#else:
		#_do_pickup.rpc_id(1, get_parent().name, pickupable.get_path() if pickupable else ^"")
	var pickupable_path = pickupable.get_path() if pickupable else ^""
	_do_pickup.rpc(get_parent().name, pickupable_path)

@rpc("any_peer", "call_local")
func _do_pickup(player_id: String, pickupable_path: NodePath):
	print("do_pickup called, player_id: ", player_id, " pickupable_path: ", pickupable_path)
	var player = get_tree().current_scene.get_node(player_id)
	var role = player.get_node("Role")
	var pickupable = get_node_or_null(pickupable_path)
	var item_holder = role.get_node("%ItemHolder")
	print("player: ", player, " role: ", role, " pickupable: ", pickupable)
	
	if role.held_item:
		#drop held item by making its parent the world and not player
		role.held_item.reparent(get_tree().current_scene)
		role.held_item.drop_visuals(player.global_position + (-player.global_basis.z * 1.0))
		role.held_item = null
	if pickupable:
		pickupable.pickup_visuals()
		pickupable.reparent(item_holder)
		pickupable.position = Vector3.ZERO
		role.held_item = pickupable

func get_raycast_target() -> Pickupable:
	var space = %Camera3D.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(
		%Camera3D.global_position,
		%Camera3D.global_position + (-%Camera3D.global_basis.z * 2.0)
	)
	var result = space.intersect_ray(ray)
	print("raycast result: ", result)
	if result and result.collider is Pickupable:
		print("hit: ", result.collider.name, " is pickupable: ", result.collider is Pickupable)
		return result.collider
	return null
