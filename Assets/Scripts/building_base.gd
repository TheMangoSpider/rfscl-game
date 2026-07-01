class_name BuildingBase
extends StaticBody3D

var recipe: Dictionary[String, int]
var items: Dictionary[String, int]
var finished_scene: PackedScene
var items_inside: Array

func change_color(c: Color):
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = c
	%MeshInstance3D.material_override = new_material
	%MeshInstance3D2.material_override = new_material
	%MeshInstance3D3.material_override = new_material
	%MeshInstance3D4.material_override = new_material
	%MeshInstance3D5.material_override = new_material

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Pickupable and items.has(body.item_name):
		items[body.item_name] += 1
		items_inside.append(body)
	for key in recipe:
		if recipe[key] == items[key]:
			finish()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Pickupable and items.has(body.item_name):
		items[body.item_name] -= 1
		for val in items_inside:
			if val == body:
				items_inside.erase(body)

func init():
	items = recipe.duplicate()
	for key in items:
		items[key] = 0

func finish():
	print("say goodbye")
	for item in items_inside:
		if recipe[item.item_name] > 0:
			item.queue_free()
			recipe[item.item_name] -= 1
	var building = finished_scene.instantiate()
	building.global_position = self.global_position
	get_tree().current_scene.add_child(building)
	items_inside.clear()
	queue_free()
