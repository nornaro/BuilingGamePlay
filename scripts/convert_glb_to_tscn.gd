# Edit file: res://convert_glb_to_tscn.gd
@tool
extends EditorScript

var MakeIcon:PackedScene = preload("res://make_icon.tscn")

func _run():
	var base_path = "res://addons/"
	var output_base = "res://items/"
	var dir = DirAccess.open(base_path)
	if dir == null:
		push_error("Cannot open base path: %s" % base_path)
		return

	# Ensure output directory exists
	DirAccess.make_dir_recursive_absolute(output_base)

	for folder in dir.get_directories():
		if folder.begins_with("kaykit_"):
			var full_path = base_path + folder + "/"
			recursive_process_dir(full_path, output_base)

func recursive_process_dir(path, output_base):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Cannot open folder: %s" % path)
		return
	
	# Get relative path within addons folder
	var rel_path = path.replace("res://addons/", "")
	
	# Create matching output directory structure
	var output_path = output_base.path_join(rel_path)
	DirAccess.make_dir_recursive_absolute(output_path)
	
	for file in dir.get_files():
		if file.ends_with(".glb") or file.ends_with(".gltf"):
			process_glb(path + file, output_path)
	
	for subdir in dir.get_directories():
		recursive_process_dir(path + subdir + "/", output_base)

func process_glb(path, output_path):
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
	
	# Find MeshInstance3D
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
	
	# Create collision
	var aabb = mesh.get_aabb()
	var shape = BoxShape3D.new()
	shape.size = aabb.size
	
	var col_shape = CollisionShape3D.new()
	col_shape.name = "Collision"
	col_shape.disabled = true
	col_shape.shape = shape
	col_shape.transform.origin = aabb.position + aabb.size * 0.5
	
	# Add to static body
	static_body.add_child(col_shape)
	static_body.get_node_or_null("SubViewport").queue_free()
	static_body.add_child(MakeIcon.instantiate())
	print(static_body.name + " MakeIcon added")
