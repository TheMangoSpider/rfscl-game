class_name Chef
extends Role

@export var knife_tool: KnifeTool

func _ready() -> void:
	var id = get_parent().name.to_int()
	if id > 0 and id != multiplayer.get_unique_id():
		return
	
	tools.append(knife_tool)
	super._ready()
	equip_tool(tools[active_tool])

func _unhandled_input(event):
	if not get_parent().is_multiplayer_authority():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tools[active_tool].use()
