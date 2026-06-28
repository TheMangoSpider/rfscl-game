class_name BuildingWheel
extends Control

@export var buildings: Array[BuildingData] = []
var selected: BuildingData = null

func _ready() -> void:
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE

func open():
	visible = true
	mouse_filter = MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close() -> BuildingData:
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return selected


func _on_drawer_slice_hovered(index: int) -> void:
	if index == -1:
		selected = null
		$InfoPanel/VBoxContainer/Name.text = "Hover a slice"
		$InfoPanel/VBoxContainer/Description.text = ""
	else:
		selected = buildings[index]
		$InfoPanel/VBoxContainer/Name.text = selected.building_name
		$InfoPanel/VBoxContainer/Description.text = selected.description
