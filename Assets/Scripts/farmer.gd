class_name Farmer
extends Role

@export var hoe_tool : HoeTool
@export var farm_tile_scene: PackedScene
@export var farm_tile_preview_scene: PackedScene
var preview_tile: Node3D

func _ready() -> void:
	var id = get_parent().name.to_int()
	if id > 0 and id != multiplayer.get_unique_id():
		return
	
	tools.append(hoe_tool)
	super._ready()
	equip_tool(tools[active_tool])
	call_deferred("_setup_preview")

func _process(delta: float) -> void:
	if not get_parent().is_multiplayer_authority():
		return
	super._process(delta)
	# tile placement highlight
	if tools[active_tool] is HoeTool:
		var space = %Camera3D.get_world_3d().direct_space_state
		var ray = PhysicsRayQueryParameters3D.create(
			%Camera3D.global_position,
			%Camera3D.global_position + (-%Camera3D.global_basis.z * 10.0),
			4
		)
		var result = space.intersect_ray(ray)
		if result:
			preview_tile.visible = true
			var grid_size := 1.0
			preview_tile.global_position = Vector3(
				round(result.position.x / grid_size) * grid_size,
				result.position.y,
				round(result.position.z / grid_size) * grid_size
			)
		else:
			preview_tile.visible = false
	else:
		preview_tile.visible = false

func _unhandled_input(event):
	if not get_parent().is_multiplayer_authority():
		return
	super._unhandled_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tools[active_tool].use()
			if tools[active_tool] is HoeTool:
				place_tile()

func _setup_preview():
	preview_tile = farm_tile_preview_scene.instantiate()
	get_tree().current_scene.add_child(preview_tile)

func place_tile():
	if not preview_tile.visible:
		return
	var tile = farm_tile_scene.instantiate()
	get_tree().current_scene.add_child(tile)
	tile.global_position = preview_tile.global_position
