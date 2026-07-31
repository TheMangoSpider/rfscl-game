extends Node

@export var player_scene: PackedScene
@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner

var spawn_positions := [
	Vector3(0, 5, 0),
	Vector3(3, 5, 0),
	Vector3(-3, 5, 0),
	Vector3(0, 5, 3),
]
var spawn_index := 0

func _ready() -> void:
	spawner.spawn_function = _spawn_player_func
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		for id in NetworkManager.selected_classes:
			_spawn_player(id)

func _spawn_player(id: int):
	var class_name_str = NetworkManager.selected_classes.get(id, "")
	if class_name_str == "":
		print("no class selected for: ", id)
		return
	var pos = spawn_positions[spawn_index % spawn_positions.size()]
	spawn_index += 1
	spawner.spawn([id, class_name_str, pos])


func _spawn_player_func(data: Array) -> Node:
	var id = data[0]
	var class_name_str = data[1]
	var pos = data[2]
	var player = player_scene.instantiate()
	player.name = str(id)
	player.selected_class = class_name_str
	player.spawn_position = pos
	return player
