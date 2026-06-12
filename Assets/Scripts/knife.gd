class_name KnifeTool
extends Tool

@export var swing_cooldown := 0.5

var on_cooldown := false

func use():
	if on_cooldown:
		return
	
	tool_node.swing()
	on_cooldown = true
	await Engine.get_main_loop().create_timer(swing_cooldown).timeout
	on_cooldown = false
