class_name WheelDrawer
extends Control

@export var outer_radius := 140.0
@export var inner_radius := 50.0
var hovered := -1

signal slice_hovered(index:int)

func _draw() -> void:
	var center = size / 2
	var buildings = get_parent().get_parent().buildings
	var slice_angle = TAU / buildings.size()
	
	for i in buildings.size():
		var start = i * slice_angle - PI / 2
		var end = start + slice_angle
		var mid = start + slice_angle / 2
		var expand = 10.0 if hovered == i else 0.0
		var offset = Vector2(cos(mid), sin(mid)) * expand
		
		var points = PackedVector2Array()
		var steps = 32
		for s in steps:
			var a = lerp(start, end, float(s) / steps)
			points.append(center + offset + Vector2(cos(a), sin(a)) * outer_radius)
		for s in range(steps - 1, -1, -1):
			var a = lerp(start, end, float(s) / steps)
			points.append(center + offset + Vector2(cos(a), sin(a)) * inner_radius)
		
		draw_colored_polygon(points, buildings[i].color)
		
		#draw icons
		if buildings[i].icon:
			var icon_size = Vector2(32, 32)
			var label_r = (outer_radius + inner_radius) / 2.0
			var icon_pos = center + offset + Vector2(cos(mid), sin(mid)) * label_r - icon_size / 2
			draw_texture_rect(buildings[i].icon, Rect2(icon_pos,icon_size), false)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var center = size / 2
		var diff = event.position - center
		var dist = diff.length()
		var prev = hovered
		
		if dist < inner_radius or dist > outer_radius + 12:
			hovered = -1
		else:
			var angle = fmod(atan2(diff.y, diff.x) + PI / 2 + TAU, TAU)
			var buildings = get_parent().get_parent().buildings
			hovered = int(angle / (TAU / buildings.size())) % buildings.size()
		
		if hovered != prev:
			queue_redraw()
			slice_hovered.emit(hovered)
