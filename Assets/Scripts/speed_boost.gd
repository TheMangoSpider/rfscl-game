class_name SpeedBoost
extends Skill

func apply(player: Node, role: Node):
	player.walk_speed += 20.0
	player.sprint_speed += 20.0
