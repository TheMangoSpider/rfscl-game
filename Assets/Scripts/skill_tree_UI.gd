class_name SkillTreeUI
extends PanelContainer

var skill_tree: SkillTree
var skill_buttons := {}
var node_positions := {}

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
		call_deferred("build_ui")

func build_ui():
	var node_container = $SkillTreeContainer/SkillNodes
	var skills = skill_tree.get_all_skills()
	var max_depth = get_max_depth(skill_tree)
	
	# calc subtree widths
	var subtree_widths = {}
	calc_subtree_width(skill_tree, subtree_widths)
	
	# assign positions
	assign_positions(skill_tree, 0.0, size.x, max_depth, subtree_widths)
	
	# create buttons at calculated positions
	for skill in skills:
		var button = Button.new()
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.2, 0.3, 0.5, 1.0)))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(0.3, 0.4, 0.6, 1.0)))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.4, 0.5, 0.7, 1.0)))
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.15, 0.15, 0.15, 1.0)))
		
		button.custom_minimum_size = Vector2(150, 44)
		button.text = skill.skill_name
		button.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6, 1.0))
		button.disabled = not skill.can_unlock()
		button.position = node_positions[skill]
		button.pressed.connect(func():
			skill_tree.unlock_skill(skill)
			refresh()
		)
		node_container.add_child(button)
		skill_buttons[skill] = button
	
	node_container.custom_minimum_size = Vector2(size.x, (max_depth + 1) * 120 + 100)
	node_container.skill_buttons = skill_buttons
	node_container.queue_redraw()

func calc_subtree_width(node: Node, widths: Dictionary) -> int:
	var children = node.get_children().filter(func(c): return c is Skill)
	if children.is_empty():
		widths[node] = 1
		return 1
	var total = 0
	for child in children:
		total += calc_subtree_width(child, widths)
	widths[node] = total
	return total

func assign_positions(node: Node, left: float, right: float, max_depth: int, widths: Dictionary):
	var children = node.get_children().filter(func(c): return c is Skill)
	if children.is_empty():
		return
	
	var total_width = widths[node]
	var cursor = left
	
	for child in children:
		var child_width = widths[child]
		var child_left = cursor
		var child_right = cursor + (right - left) * (float(child_width) / total_width)
		var center_x = (child_left + child_right) / 2.0 - 75
		var depth = get_depth(child)
		var y = (max_depth - depth) * 120
		node_positions[child] = Vector2(center_x, y)
		assign_positions(child, child_left, child_right, max_depth, widths)
		cursor = child_right

func refresh():
	for skill in skill_buttons:
		var btn = skill_buttons[skill]
		btn.disabled = skill.is_active or (not skill.can_unlock())

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
	var container_width = 700.0
	var siblings = skill.get_parent().get_children().filter(func(c): return c is Skill)
	var index = siblings.find(skill)
	var total = siblings.size()
	return (index + 1) * (container_width / (total + 1))


func open():
	visible = true
	$"../DimRect".visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SkillTreeContainer/SkillNodes.queue_redraw()

func close():
	visible = false
	$"../DimRect".visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _make_button_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style
