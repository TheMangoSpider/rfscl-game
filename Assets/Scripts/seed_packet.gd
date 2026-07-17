class_name SeedPacket
extends Pickupable

@export var uses := 5

# Crop info to be passed when planted
@export var growth_stages: Array[PackedScene] = []
@export var growth_time := 30.0
@export var result: PackedScene
 
