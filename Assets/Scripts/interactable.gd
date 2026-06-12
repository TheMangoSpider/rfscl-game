class_name Interactable
extends Node

func _interact(role: Role) -> void:
	pass  # overriden, interacts diff per object

func _can_interact(role: Role) -> bool:
	return false  # overridden, checks if the correct role is interacting with this
