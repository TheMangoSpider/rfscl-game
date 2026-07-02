extends Node

@export var player_scene: PackedScene

var spawn_positions := [
	Vector3(0, 5, 0),
	Vector3(3, 5, 0),
	Vector3(-3, 5, 0),
	Vector3(0, 5, 3),
]
var spawn_index := 0

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		_spawn_player(1)  # spawn host
	else:
		multiplayer.connected_to_server.connect(_on_connected)

func _on_connected():
	pass

func _spawn_player(id: int):
	print("spawning player: ", id, " is server: ", multiplayer.is_server())
	var player = player_scene.instantiate()
	player.name = str(id)
	player.spawn_position = spawn_positions[spawn_index % spawn_positions.size()]
	spawn_index += 1
	add_child(player)
