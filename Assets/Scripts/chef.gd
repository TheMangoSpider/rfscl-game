class_name Chef
extends Role

@export var knife_tool: KnifeTool

func _ready() -> void:
	tools.append(knife_tool)
	super._ready()
	equip_tool(tools[active_tool])

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tools[active_tool].use()
