class_name Skill
extends Node

@export var skill_name: String
@export var description: String
@export var cost := 1 # points needed to unlock this skill
@export var additional_requirements: Array[NodePath] = []
var is_active := false

func can_unlock() -> bool:
	#can only unlock skill if parent is unlocked
	if get_parent() is Skill and not get_parent().is_active:
		return false
	
	# check if another needs other non-connected nodes
	for path in additional_requirements:
		var required = get_node_or_null(path)
		if required and not required.is_active:
			return false
	return true

func unlock(player: Node, role: Node):
	if not can_unlock():
		return
	is_active = true
	apply(player, role)

func apply(player: Node, role: Node):
	pass #implementation for each skill (will be overriden)
