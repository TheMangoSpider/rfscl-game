extends Node

const PORT = 7777
const MAX_PLAYERS = 4

var players := {}

signal player_connected(id: int)
signal player_disconnected(id: int)

func _ready() -> void:
	# init EOS
	var init_options = EOSInitializeOptions.new()
	init_options.product_name = "RFCL"
	init_options.product_version = "0.5"
	EOS.initialize(init_options)
	
	var create_options = EOSPlatformCreateOptions.new()

func host():
	if use_steam:
		host_steam()
	else:
		host_eos()

func join(adress: String):
	if use_steam:
		join_steam()
	else:
		join_eos()

func _on_peer_connected(id: int):
	print("peer connected: ", id)
	player_connected.emit(id)

func _on_peer_disconnected(id:int):
	print("peer disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	print("connected to server, my id: ", multiplayer.get_unique_id())

func host_eos() -> void:
	pass

func host_steam() -> void:
	pass
