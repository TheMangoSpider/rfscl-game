class_name Role
extends Node

var tools : Array[Tool] = []
var active_tool : int = 0
var tool_node: Node3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	pass

func _interact():
	tools[active_tool].use()

func swap_tool():
	if active_tool == tools.size() - 1:
		active_tool = 0
	else:
		active_tool += 1;
	
	equip_tool(tools[active_tool])

func equip_tool(tool: Tool) -> void:
	print("equipping tool: ", tool)
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
