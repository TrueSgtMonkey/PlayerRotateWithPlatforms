tool
extends EditorPlugin

const Crystal = preload("res://Scenes/Levels/CrystalCaves/SaveStone_00.shader")

var activated := false
var pressed := false
var path := ""
var materials = []
var label : LineEdit
var bits = [1, 5, 6]
var uv_mult := 1.0
var editor_camera_3d = null
		
func _ready():
	var editor_viewport_3d = find_viewport_3d(get_node("/root/EditorNode"), 0)
	editor_camera_3d = editor_viewport_3d.get_child(0)
		
func _input(event):
	if Input.is_key_pressed(KEY_F12) && !pressed && !activated:
		genKey("generateShapes", "Generate Shapes")
	elif Input.is_key_pressed(KEY_F11) && !pressed && !activated:
		genKey("setupQodot", "Setup Qodot Map")
	elif !Input.is_key_pressed(KEY_F12) && !Input.is_key_pressed(KEY_F11) && pressed:
		pressed = false
		
	if Input.is_key_pressed(KEY_F10):
		var nodes = get_editor_interface().get_selection().get_selected_nodes()
		for node in nodes:
			print(node.global_transform.origin)
			if(node is MeshInstance):
				print("mesh_size: ", node.mesh.get_aabb().size)
	if Input.is_key_pressed(KEY_F9):
		var nodes = get_editor_interface().get_selection().get_selected_nodes()
		for node in nodes:
			if node is Spatial:
				if editor_camera_3d == null:
					editor_camera_3d = find_viewport_3d(get_node("/root/EditorNode"), 0).get_child(0)
				node.transform.origin = editor_camera_3d.transform.origin
	if Input.is_key_pressed(KEY_F8):
		var nodes = get_editor_interface().get_selection().get_selected_nodes()
		for node in nodes:
			if node is MeshInstance:
				var g = load("res://addons/CollisionGen/Generator.tscn").instance()
				for i in range(0, node.mesh.get_surface_count()):
					node.mesh.surface_set_material(i, g.get_node("MeshInstance").mesh.surface_get_material(0))
				g.queue_free()
			else:
				continue

func find_viewport_3d(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport_3d(child, recursive_level)
			if result != null:
				return result

# We may want different functionality for using the same Generator scene
# For instance, functionality for levels brought in from Trenchbroom vs Blender
func genKey(function : String, buttName : String):
	var g = load("res://addons/CollisionGen/Generator.tscn").instance()
	g.get_node("VBoxContainer/GenButton").connect("pressed", self, function, [g])
	g.get_node("VBoxContainer/GenButton").text = buttName
	g.get_node("VBoxContainer/CancelButton").connect("pressed", self, "cancel", [g])
	g.get_node("VBoxContainer/HBoxContainer/HSlider").connect("value_changed", self, "xChange")
	g.get_node("VBoxContainer/HBoxContainer/Value").connect("text_entered", self, "xBarChange", [g])
	label = g.get_node("VBoxContainer/HBoxContainer/Value")
	label.text = str(uv_mult)
	add_child(g)
	pressed = true
	activated = true
		
# Gets all the materials in a path
func getMaterials(s):
	if s == "":
		print("You need to input a string!")
		return
	elif s == path:
		print("That path is already loaded!")
		return
	path = s
	materials.clear()
	var dir = Directory.new()
	dir.open(path)
	var file := "butt"
	dir.list_dir_begin()
	while file != "":
		file = dir.get_next()
		if file.ends_with(".material"):
			var material = load(file)
			materials.append(material)
			print(material.name)
	dir.list_dir_end()
	return materials
	
func genTextures(fg):
	activated = false
	fg.queue_free()
	
func xChange(val):
	uv_mult = val
	label.text = str(val)
	
func xBarChange(s, g):
	g.get_node("VBoxContainer/HBoxContainer/HSlider").value = float(s)

func cancel(g):
	g.queue_free()
	activated = false

# Used for all children that are MeshInstances
# Will make StaticBodies with collision shapes around them.
# Useful for levels brought in from Blender.
func generateShapes(g):
	
	var parents = get_editor_interface().get_selection().get_selected_nodes()
	for parent in parents:
		for node in parent.get_children():
			if node is MeshInstance:
				node.use_in_baked_light = true
				# Creates a collision shape for the mesh
				# Since this is slow, we only want to do this when we are testing levels
								# gets the static body created
				var child = null
				if(node.get_child_count() > 0 && node.get_child(0) is StaticBody):
					child = node.get_child(0)
				else:
					for i in node.get_children():
						if i is StaticBody:
							child = i
							break
					if(child == null):
						node.create_trimesh_collision()
		
				# sets the static body's collision layers & masks to all the bits layered above
				if(child != null):
					for i in range(0, bits.size()):
						child.set_collision_layer_bit(bits[i], true)
						child.set_collision_mask_bit(bits[i], true)
	g.queue_free()
	activated = false

# Used if the children of the selected nodes are not MeshInstances and are instead PhysicsBodies
# Basically, for Qodot .map files that have been brought in
func setupQodot(g):
	#buttface
	var parents = get_editor_interface().get_selection().get_selected_nodes()
	for parent in parents:
		if parent is PhysicsBody:
			for mesh in parent.get_children():
				if mesh is MeshInstance:
					mesh.use_in_baked_light = true
			for i in range(0, bits.size()):
				parent.set_collision_layer_bit(bits[i], true)
				parent.set_collision_mask_bit(bits[i], true)
		else:
			for node in parent.get_children():
				if node is PhysicsBody:
					if node.get_child_count() == 0:
						node.queue_free()
						continue
					var meshes := 0
					for mesh in node.get_children():
						if mesh is MeshInstance:
							meshes += 1
							mesh.use_in_baked_light = true
					if meshes == 0:
						node.queue_free()
					# sets the static body's collision layers & masks to all the bits layered above
					for i in range(0, bits.size()):
						node.set_collision_layer_bit(bits[i], true)
						node.set_collision_mask_bit(bits[i], true)
			print("CollisionGen completed.")
	g.queue_free()
	activated = false
