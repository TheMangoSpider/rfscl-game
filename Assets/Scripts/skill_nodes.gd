extends Control

var skill_buttons := {}

func _draw():
	for skill in skill_buttons:
		var btn = skill_buttons[skill]
		var btn_center = btn.position + btn.size / 2
		
		# draw lines connecting skills to parents and shi
		if skill.get_parent() is Skill:
			var parent_btn = skill_buttons.get(skill.get_parent())
			if parent_btn:
				draw_line(btn_center, parent_btn.position + parent_btn.size / 2, Color(0.6, 0.6, 0.6, 1.0), 2.0)
		
		# lines to additional requirement nodes
		for path in skill.additional_requirements:
			var required = skill.get_node_or_null(path)
			if required and skill_buttons.has(required):
				var req_btn = skill_buttons[required]
				# diff color line to diferentiate
				draw_line(btn_center, req_btn.position + req_btn.size / 2, Color(1.0, 0.8, 0.0, 1.0), 2.0)
