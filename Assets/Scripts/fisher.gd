class_name Fisher
extends Role

@export var spear_tool: SpearTool

var charge_time := 0.0
var is_charging := false

func _ready() -> void:
	tools.append(spear_tool)
	equip_tool(tools[active_tool])

func _process(delta: float) -> void:
	if is_charging:
		charge_time = min(charge_time + delta, spear_tool.max_charge_time)


func _unhandled_input(event):
	super._unhandled_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_charging = true
			charge_time = 0.0
		else:
			is_charging = false
			tools[active_tool].release(
				get_tree().current_scene,
				%Camera3D.global_position,
				-%Camera3D.global_basis.z,
				charge_time     
			)
