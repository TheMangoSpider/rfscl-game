class_name Crop
extends Node3D

@export var growth_stages: Array[PackedScene] = []
@export var growth_time := 30.0
@export var result: PackedScene

var curr_stage := 0
var time_since_last_growth := 0.0
var stage_instance: Node3D

func _ready() -> void:
	show_stage(curr_stage)

func show_stage(stage: int):
	if stage_instance:
		stage_instance.queue_free()
	stage_instance = growth_stages[stage].instantiate()
	add_child(stage_instance)

@onready var mesh = $MeshInstance3D

func _process(delta: float) -> void:
	if curr_stage >= growth_stages.size() - 1:
		return #fully grown
	time_since_last_growth += delta
	if time_since_last_growth >= growth_time:
		time_since_last_growth = 0.0
		curr_stage += 1
		show_stage(curr_stage)
