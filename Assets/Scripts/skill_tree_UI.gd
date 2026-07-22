class_name SkillTreeUI
extends PanelContainer

var skill_tree: SkillTree
var skill_buttons := {}

func _ready() -> void:
	print("SKILLTREEUI READY")
	var role = get_parent().get_parent().get_node("Role")
	print("role: ", role)
	for child in role.get_children():
		print("role Child: ", child.name, " is SkilTree: ", child is SkillTree)
		if child is SkillTree:
			skill_tree = child
	
	print("Skilll_tree found: ", skill_tree)
	if skill_tree:
		build_ui()

func build_ui():
	print("SkillTreeUI size: ", size)
	var node_container = $SkillTreeContainer/SkillNodes
	var skills = skill_tree.get_all_skills()
	var max_depth = get_max_depth(skill_tree)
	
	for skill in skills:
		var depth = get_depth(skill)
		var button = Button.new()
		
		button.custom_minimum_size = Vector2(140, 40)
		button.text = skill.skill_name
		button.disabled = not skill.can_unlock()
		button.position = Vector2(
			get_branch_x(skill),
			(max_depth - depth) * 120 # root at bottom
		)
		button.pressed.connect(func():
			skill_tree.unlock_skill(skill)
			refresh()
		)
		node_container.add_child(button)
		skill_buttons[skill] = button
		print("button: ", skill.skill_name, " pos: ", button.position)
	
	node_container.skill_buttons = skill_buttons
	node_container.queue_redraw()

func refresh():
	for skill in skill_buttons:
		skill_buttons[skill].disabled = not skill.can_unlock() and not skill.is_active

func get_depth(node: Node) -> int:
	var depth = 0
	if node.get_parent() is Skill:
		depth += get_depth(node.get_parent()) + 1
	return depth

func get_max_depth(tree: Node) -> int:
	var max_d = 0
	for skill in tree.get_all_skills():
		max_d = max(max_d, get_depth(skill))
	return max_d

func get_branch_x(skill: Skill) -> float:
	var siblings = skill.get_parent().get_children().filter(func(c): return c is Skill)
	var index = siblings.find(skill)
	var total = siblings.size()
	return (index + 1) * (size.x / (total + 1))


func open():
	visible = true
	$"../DimRect".visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SkillTreeContainer/SkillNodes.queue_redraw()

func close():
	visible = false
	$"../DimRect".visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
