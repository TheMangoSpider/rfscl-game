extends Control

func _ready() -> void:
	NetworkManager.classes_updated.connect(_refresh_ui)
	_refresh_ui()

func on_class_selected(class_name_str: String):
	NetworkManager.claim_class.rpc(class_name_str)

func _refresh_ui():
	# update buttons to show which classes are taken
	for class_name_str in ["Farmer", "Fisher", "Engineer", "Chef"]:
		var button = get_node(class_name_str)
		var is_taken = class_name_str in NetworkManager.selected_classes.values()
		var is_mine = NetworkManager.selected_classes.get(
			multiplayer.get_unique_id()) == class_name_str
		button.disabled = is_taken and not is_mine
		button.text = class_name_str + (" ✓" if is_mine else (" (taken)" if is_taken else ""))

func on_ready_pressed():
	if not multiplayer.is_server():
		return #only host starts game
	var my_class = NetworkManager.selected_classes.get(multiplayer.get_unique_id())
	if not my_class:
		return # select a class to start obvi
	NetworkManager.start_game.rpc()
