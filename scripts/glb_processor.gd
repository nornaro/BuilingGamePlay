# Edit file: res://scripts/glb_processor.gd
@tool
extends EditorScript

func _run():
	var items = FileAccess.open("res://scripts/tscn_files.dat", FileAccess.READ).get_var()
	for category in items.keys():
		for item in items[category]:
			process_glb_file("res://addons/"+category+"/Assets/gltf/"+item+".gltf")

func process_glb_file(glb_path: String):
	print("Processing: ", glb_path)
	
	# Load the GLB scene
	var glb_scene := load(glb_path) as PackedScene
	if not glb_scene:
		push_error("Failed to load GLB: " + glb_path)
		return
	
	# Create StaticBody3D container
	var static_body := StaticBody3D.new()
	static_body.name = glb_path.get_file().get_basename()
	
	# Instantiate and reparent children
	var instance: Node3D = glb_scene.instantiate()
	for child in instance.get_children():
		instance.remove_child(child)
		static_body.add_child(child)
		child.owner = static_body
	
	# Add collision shapes
	add_collision_shapes(static_body)
	
	# Create preview setup
	create_preview_setup(static_body)
	
	# Determine output path
	var output_path := glb_path.replace("addons", "items").get_basename() + ".tscn"
	var output_dir := output_path.get_base_dir()
	
	# Ensure output directory exists
	if not DirAccess.dir_exists_absolute(output_dir):
		var err := DirAccess.make_dir_recursive_absolute(output_dir)
		if err != OK:
			push_error("Failed to create directory: " + output_dir)
			return
	
	# Save the scene
	var packed_scene := PackedScene.new()
	packed_scene.pack(static_body)
	var err := ResourceSaver.save(packed_scene, output_path)
	if err != OK:
		push_error("Failed to save scene: " + output_path)
		return
	print("Successfully processed: ", glb_path, " -> ", output_path)

func add_collision_shapes(parent: StaticBody3D):
	# Find first MeshInstance3D
	var mesh_instance: MeshInstance3D
	for child in parent.get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			break
	
	if not mesh_instance or not mesh_instance.mesh:
		push_error("No valid MeshInstance3D found in: " + parent.name)
		return
	
	# AABB collision
	var aabb := mesh_instance.get_aabb()
	var aabb_shape := BoxShape3D.new()
	aabb_shape.size = aabb.size
	
	var aabb_collision := CollisionShape3D.new()
	aabb_collision.name = "AABBCollision"
	aabb_collision.shape = aabb_shape
	aabb_collision.disabled = true
	parent.add_child(aabb_collision)
	aabb_collision.owner = parent
	
	# Convex collision
	var convex_shape := mesh_instance.mesh.create_convex_shape()
	var convex_collision := CollisionShape3D.new()
	convex_collision.name = "ConvexCollision"
	convex_collision.shape = convex_shape
	parent.add_child(convex_collision)
	convex_collision.owner = parent

func create_preview_setup(parent: Node3D):
	var subviewport := SubViewport.new()
	subviewport.size = Vector2i(512, 512)
	subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 45
	
	# Position camera based on AABB
	var aabb_collision := parent.get_node_or_null("AABBCollision")
	if aabb_collision:
		var aabb := aabb_collision.shape as BoxShape3D
		camera.position.y = aabb.size.y
	
	subviewport.add_child(camera)
	camera.owner = subviewport
	
	# Wait for rendering
	var time_passed := 0.0
	var editor_interface := get_editor_interface()
	#while time_passed < 0.5:
		#time_passed += editor_interface.get_editor_settings().get("interface/editor/update_interval")
		#OS.delay_msec(int(editor_interface.get_editor_settings().get("interface/editor/update_interval") * 1000))
	
	await RenderingServer.frame_post_draw
	
	# Save textures
	var base_path = parent.get_parent().get("scene_file_path")
	if base_path:
		print(base_path)
		base_path = base_path.get_basename()
		save_viewport_texture(subviewport, base_path + ".png")
		save_viewport_texture(subviewport, base_path + ".jpg")
		save_viewport_texture(subviewport, base_path + ".webp")

func save_viewport_texture(viewport: SubViewport, path: String):
	var image := viewport.get_texture().get_image()
	match path.get_extension():
		"png": image.save_png(path)
		"jpg": image.save_jpg(path, 0.95)
		"webp": image.save_webp(path)
