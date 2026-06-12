class_name Farmer
extends Role

@export var hoe_tool : HoeTool

func _ready() -> void:
	tools.append(hoe_tool)
	equip_tool(tools[active_tool])

func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tools[active_tool].use()
