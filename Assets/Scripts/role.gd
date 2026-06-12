class_name Role
extends Node

var tools : Array[Tool] = []
var active_tool : int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	pass

func _interact(target):
	tools[active_tool].use(target)

func swap_tool():
	if active_tool == tools.size() - 1:
		active_tool = 0
	else:
		active_tool += 1;
