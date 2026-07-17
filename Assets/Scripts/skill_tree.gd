class_name SkillTree
extends Node

var skill_points := 1

func unlock_skill(skill: Skill):
	if skill_points >= skill.cost and skill.can_unlock():
		skill_points -= skill.cost
		skill.unlock(get_parent(), get_parent().get_node("Role"))
