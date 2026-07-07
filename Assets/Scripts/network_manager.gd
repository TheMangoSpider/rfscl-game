extends Node

const PORT = 7777
const MAX_PLAYERS = 4

var players := {}

signal player_connected(id: int)
signal player_disconnected(id: int)

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
