class_name SpeedBoost2
extends Skill

func apply(player: Node, role: Node):
	player.walk_speed += 5.0
	player.sprint_speed += 5.0
