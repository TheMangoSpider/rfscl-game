extends Node

const PORT = 7777
const MAX_PLAYERS = 4

var players := {}
var selected_classes := {}

signal player_connected(id: int)
signal player_disconnected(id: int)

signal classes_updated

func host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("hosting on port: ", PORT)

func join(address: String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	print("joining: ", address)

func _on_peer_connected(id: int):
	print("peer connected: ", id)
	player_connected.emit(id)

func _on_peer_disconnected(id:int):
	print("peer disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	print("connected to server, my id: ", multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func claim_class(class_name_str: String):
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()
	
	#check if class is taken
	if class_name_str in selected_classes.values():
		return
	
	selected_classes.erase(sender_id)
	selected_classes[sender_id] = class_name_str
	sync_classes.rpc(selected_classes)

@rpc("authority", "call_local")
func sync_classes(classes: Dictionary):
	selected_classes = classes
	
	#UI update
	classes_updated.emit()

@rpc("authority", "call_local")
func start_game() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/main.tscn")
