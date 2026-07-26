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
		
		#spawn all players with selected classes
		for id in NetworkManager.selected_classes:
			_spawn_player(id)
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
	
	# apply class
	var class_name_str = NetworkManager.selected_classes.get(id, "")
	if class_name_str == "":
		print("warning: no class selected for player ", id)
		return
	player.selected_class = class_name_str
	
	add_child(player)
