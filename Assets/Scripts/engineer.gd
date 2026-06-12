class_name Engineer
extends Role

@export var axe_tool: AxeTool
@export var pickaxe_tool : PickaxeTool


func _ready() -> void:
	tools.append(axe_tool)
	tools.append(pickaxe_tool)
	equip_tool(tools[active_tool])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch"):
		swap_tool()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tools[active_tool].use()
