class_name KnifeNode
extends Node3D

@onready var hitbox = $SwingPivot/Area3D
var tool_resource: Tool

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.monitoring = false

func swing() -> void:
	%AnimationPlayer.play("knife_swing")
	hitbox.monitoring = true
	await %AnimationPlayer.animation_finished
	hitbox.monitoring = false 

func _on_hitbox_body_entered(body) -> void:
	#if body.has_node("Interactable"):
		#body.get_node("Interactable").interact(tool_resource)
	pass
