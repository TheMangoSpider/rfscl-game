class_name HammerNode
extends Node3D

@onready var hitbox = $SwingPivot/Area3D
var tool_resource: Tool

func _ready() -> void:
	hitbox.monitoring = false

func swing() -> void:
	%AnimationPlayer.play("hammer_swing")
	await %AnimationPlayer.animation_finished
