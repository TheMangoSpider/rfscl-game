class_name Customer
extends StaticBody3D

@export var item_pool : Array[String] = []
var needed_item : String

func _ready() -> void:
	needed_item = item_pool.pick_random()

func sell(held_item: Pickupable):
	if not held_item:
		return
	if held_item.item_name == needed_item:
		if multiplayer.is_server():
			complete_sale.rpc(held_item.get_path())
		else:
			complete_sale.rpc_id(1, held_item.get_path())
		get_parent().add_cash(20)

@rpc("authority", "call_local")
func complete_sale(item_path: NodePath):
	var item = get_node_or_null(item_path)
	if item:
		item.queue_free()
	if multiplayer.is_server():
		get_parent().add_cash.rpc(20)
