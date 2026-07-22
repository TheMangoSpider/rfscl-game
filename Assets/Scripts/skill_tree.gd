class_name SkillTree
extends Node

var skill_points := 10

func unlock_skill(skill: Skill):
	if skill_points >= skill.cost and skill.can_unlock():
		skill_points -= skill.cost
		var role = get_parent()
		var player = role.get_parent()
		skill.unlock(player, role)

func get_all_skills() -> Array[Skill]:
	var skills: Array[Skill] = []
	collect_skills(self, skills)
	return skills

func collect_skills(node: Node, skills: Array[Skill]):
	for child in node.get_children():
		if child is Skill:
			skills.append(child)
			collect_skills(child, skills)
