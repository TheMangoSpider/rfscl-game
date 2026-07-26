class_name RoleData
extends Resource

@export var display_name: String
@export var icon: Texture2D
@export var role_script: GDScript
@export var skill_tree_scene: PackedScene

@export var hand: Hand

# fisher
@export var spear_tool: SpearTool

# farmer
@export var hoe_tool: HoeTool

#chef
@export var knife_tool: KnifeTool

#engineer
@export var axe_tool: AxeTool
@export var pickaxe_tool: PickaxeTool
@export var hammer_tool: HammerTool
@export var build_base_scene: PackedScene
@export var build_tile_preview_scene: PackedScene
@export var farm_tile_scene: PackedScene
@export var farm_tile_preview_scene: PackedScene
