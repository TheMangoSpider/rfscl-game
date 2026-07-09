class_name Engineer
extends Role

@export var axe_tool: AxeTool
@export var pickaxe_tool : PickaxeTool
@export var hammer_tool : HammerTool

@export var tile_size := 5.0
@export var build_base_scene: PackedScene
@export var build_tile_preview_scene: PackedScene
var preview_tile: Node3D

func _ready() -> void:
	var id = get_parent().name.to_int()
	if id > 0 and id != multiplayer.get_unique_id():
		return
	
	tools.append(axe_tool)
	tools.append(pickaxe_tool)
	tools.append(hammer_tool)
	super._ready()
	equip_tool(tools[active_tool])
	call_deferred("_setup_preview")

func _process(delta: float) -> void:
	if not get_parent().is_multiplayer_authority():
		return
	super._process(delta)
	# tile placement highlight
	if tools[active_tool] is HammerTool:
		var space = %Camera3D.get_world_3d().direct_space_state
		var ray = PhysicsRayQueryParameters3D.create(
			%Camera3D.global_position,
			%Camera3D.global_position + (-%Camera3D.global_basis.z * 10.0),
			4
		)
		var result = space.intersect_ray(ray)
		if result:
			preview_tile.visible = true
			var grid_size := tile_size
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
	if event.is_action_pressed("interact") and tools[active_tool] is HammerTool:
		if %BuildingWheel.visible:
			%BuildingWheel.close()
		else:
			%BuildingWheel.open()
	else:
		super._unhandled_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not %BuildingWheel.visible:
			tools[active_tool].use()
			if tools[active_tool] is HammerTool:
				build()

func build():
	if not preview_tile.visible or preview_tile.dont_build:
		return
	var building = %BuildingWheel.selected
	if not building:
		return
	var tile = build_base_scene.instantiate()
	tile.change_color(building.color)
	get_tree().current_scene.add_child(tile)
	tile.global_position = preview_tile.global_position
	tile.recipe = building.recipe
	tile.finished_scene = building.finished_scene
	tile.init()

func _setup_preview():
	preview_tile = build_tile_preview_scene.instantiate()
	get_tree().current_scene.add_child(preview_tile)
	var decal = preview_tile.get_node("Decal")
	decal.size = Vector3(tile_size, 10.0, tile_size)
	var shape = preview_tile.get_node("Area3D/CollisionShape3D")
	shape.shape.size = Vector3(tile_size, 0.1, tile_size)
