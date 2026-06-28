extends StaticBody3D

func change_color(c: Color):
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = c
	%MeshInstance3D.material_override = new_material
	%MeshInstance3D2.material_override = new_material
	%MeshInstance3D3.material_override = new_material
	%MeshInstance3D4.material_override = new_material
	%MeshInstance3D5.material_override = new_material
