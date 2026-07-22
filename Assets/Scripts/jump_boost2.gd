class_name JumpBoost2
extends Skill

func apply(player: Node, role: Node):
	player.jump_vel += 5.0
	player.sprint_speed += 5.0
