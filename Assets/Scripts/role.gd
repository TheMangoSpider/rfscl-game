class_name Role
extends Node

@export var hand: Hand

var tools : Array[Tool] = []
var active_tool : int = 0
var tool_node: Node3D
var held_item: Node3D
var last_highlighted: Node = null

var _initialized := false

func _ready() -> void:
	if not _initialized:
		return
	
	tools.append(hand)

func _process(delta: float) -> void:
	if not get_parent().is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("switch"):
		swap_tool()
	
	# Pickup text raycast
	var target = get_raycast_target()
	if target != last_highlighted:
		if last_highlighted and is_instance_valid(last_highlighted):
			var label = last_highlighted.get_node_or_null("Label3D")
			if label:
				label.visible = false
		if target:
			var label = target.get_node_or_null("Label3D")
			if label:
				label.visible = true
		last_highlighted = target

func _unhandled_input(event):
	if not get_parent().is_multiplayer_authority():
		return
	if event.is_action_pressed("interact"):
		print("interact pressed, target: ", get_raycast_target())
		var target = get_raycast_target()
		if target is Pickupable:
			pickup(target)
		elif target is Crop and target.curr_stage >= target.growth_stages.size() - 1:
			var crop_result = target.result.instantiate()
			crop_result.name = "harvest " + str(randi())
			get_tree().current_scene.add_child(crop_result)
			crop_result.global_position = target.global_position
			target.queue_free()
			await get_tree().process_frame
			pickup(crop_result)
	if event.is_action_pressed("drop") && held_item:
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
	print("equipping: ", tool, " tool_scene: ", tool.tool_scene if tool else "tool is null")
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
	
	#ensure that label is gone
	if pickupable:
		var label = pickupable.get_node_or_null("Label3D")
		if label:
			label.visible = false
	
	if role.held_item:
		#drop held item by making its parent the world and not player
		role.held_item.reparent(get_tree().current_scene)
		role.held_item.drop_visuals(get_drop_position(player))
		role.held_item = null
	if pickupable:
		pickupable.pickup_visuals()
		pickupable.reparent(item_holder)
		pickupable.position = Vector3.ZERO
		role.held_item = pickupable

func get_raycast_target() -> Node:
	var space = %Camera3D.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(
		%Camera3D.global_position,
		%Camera3D.global_position + (-%Camera3D.global_basis.z * 4.0)
	)
	ray.collision_mask = 0b11101111
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.exclude = [get_parent().get_rid()]
	var result = space.intersect_ray(ray)
	#print("raw hit: ", result.get("collider", "nothing"))
	#print("raycast result: ", result)
	if result and (result.collider is Pickupable or result.collider is Crop):
		#print("hit: ", result.collider.name, " is pickupable: ", result.collider is Pickupable)
		return result.collider
	return null

func get_drop_position(player: Node3D):
	var drop_pos = player.global_position + (-player.global_basis.z * 1.0)
	
	#find ground
	var space = player.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(
		drop_pos + Vector3(0, 2, 0),
		drop_pos + Vector3(0, -5, 0),
		4
	)
	ray.exclude = [player.get_rid()]
	var result = space.intersect_ray(ray)
	if result:
		return result.position + Vector3(0, 0.3, 0)
	return drop_pos
