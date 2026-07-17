class_name Skill
extends Node

@export var skill_name: String
@export var description: String
@export var cost := 1 #points needed
var is_active := false

func can_unlock() -> bool:
	#can only unlock skill if parent is unlocked
	if get_parent() is Skill:
		return get_parent().is_active
	return true

func unlock(player: Node, role: Node):
	if not can_unlock():
		return
	is_active = true
	apply(player, role)

func apply(player: Node, role: Node):
	pass #implementation for each skill (will be overriden)
