class_name BuildingData
extends Resource

@export var building_name: String
@export var description: String
@export var color: Color
@export var recipe: Dictionary[String, int]  # diff materials would be diff numbers to simplify recipes {"wood": 3, "stone": 2}
@export var tub_scene: PackedScene
@export var finished_scene: PackedScene
@export var icon: Texture2D  # icon on the wheel
