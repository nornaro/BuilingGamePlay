# Edit file: res://convert_glb_to_tscn.gd
@tool
extends EditorScript

func _run():
	var base_path = "res://addons/"
	var dir = DirAccess.open(base_path)
	if dir == null:
		push_error("Cannot open base path: %s" % base_path)
		return

	for folder in dir.get_directories():
		if folder.begins_with("kaykit_"):
			var full_path = base_path + folder + "/"
			recursive_process_dir(full_path)

func recursive_process_dir(path):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Cannot open folder: %s" % path)
		return
	
	for file in dir.get_files():
		if file.ends_with(".glb") or file.ends_with(".gltf"):
			process_glb(path + file)
	
	for subdir in dir.get_directories():
		recursive_process_dir(path + subdir + "/")

func process_glb(path):
	var scene = load(path)
	if not scene:
		push_error("Could not load: %s" % path)
		return
	
	var inst = scene.instantiate()
	
	# Convert root to StaticBody3D
	var static_body = StaticBody3D.new()
	static_body.name = inst.name
	static_body.transform = inst.transform
	
	# Add cube.gd script to StaticBody3D
	var script = load("res://cube.gd")
	if script:
		static_body.set_script(script)
	
	# Try to find a MeshInstance3D by type
	var mesh_node: MeshInstance3D = null
	var mesh_instances = inst.find_children("", "MeshInstance3D", true, false)
	if mesh_instances.size() > 0:
		mesh_node = mesh_instances[0]
	
	if not mesh_node:
		push_warning("No MeshInstance3D found in %s" % path)
		return
	
	var mesh = mesh_node.mesh
	if not mesh:
		push_warning("No mesh in MeshInstance3D at %s" % path)
		return
	
	# Duplicate and set up mesh
	var mesh_copy = mesh_node.duplicate()
	mesh_copy.transform = mesh_node.transform
	
	# Create collision shape from AABB
	var aabb = mesh.get_aabb()
	var shape = BoxShape3D.new()
	shape.size = aabb.size
	
	var col_shape = CollisionShape3D.new()
	col_shape.name = "Collision"
	col_shape.disabled = true
	col_shape.shape = shape
	col_shape.transform.origin = aabb.position + aabb.size * 0.5
	
	# Add to static body
	static_body.add_child(mesh_copy)
	static_body.add_child(col_shape)
	
	# Set owner AFTER adding to scene tree
	mesh_copy.owner = static_body
	col_shape.owner = static_body

	# Save scene
	var save_path = path.get_basename() + ".tscn"
	var packed_scene = PackedScene.new()
	packed_scene.pack(static_body)
	var err = ResourceSaver.save(packed_scene, save_path)
	if err != OK:
		push_error("Failed to save: %s" % save_path)
	else:
		print("✅ Saved: ", save_path)
