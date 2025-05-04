# Edit file: res://scripts/glb_processor.gd
@tool
extends EditorScript

		
var preview: EditorResourcePreview = get_editor_interface().get_resource_previewer()
var gen: EditorResourcePreviewGenerator = EditorResourcePreviewGenerator.new()

func _run():
	var items = FileAccess.open("res://scripts/tscn_files.dat", FileAccess.READ).get_var()
	DirAccess.remove_absolute("res://items/")
	for category in items.keys():
		DirAccess.make_dir_recursive_absolute("res://items/"+category+"/Assets/gltf/")
		preview.add_preview_generator(gen)
		preview.get_window()
		preview.get_viewport()
		for item in items[category]:
			glb_to_tscn("res://addons/"+category+"/Assets/gltf/"+item)
			#preview.queue_resource_preview("res://addons/"+category+"/Assets/gltf/"+item, self, "set_texture", null)
			preview.queue_resource_preview(("res://addons/"+category+"/Assets/gltf/"+item)+".mesh", self, "set_texture", null)
	
func glb_to_tscn(glb_path: String):
	var glb_scene := load(glb_path) as PackedScene
	if not glb_scene:
		push_error("Failed to load GLB: " + glb_path)
		return
	
	# Create StaticBody3D container
	var static_body := StaticBody3D.new()
	static_body.name = glb_path.get_file().get_basename()
	var instance: Node3D = glb_scene.instantiate()
	for child in instance.get_children():
		instance.remove_child(child)
		static_body.add_child(child)
		child.owner = static_body
	var script = load("res://cube.gd")
	static_body.set_script(script)
	add_collision_shapes(static_body)
	
	# Save the scene
	var output_path := glb_path.replace("addons", "items").split(".")[0] + ".tscn"
	var packed_scene := PackedScene.new()
	packed_scene.pack(static_body)
	var err := ResourceSaver.save(packed_scene, output_path)
	if err != OK:
		push_error("Failed to save scene: " + output_path)

func set_texture(path: String, preview: Texture2D, thumbnail: Texture2D, userdata) -> void:
	var img = preview.get_image().save_webp(path.replace("addons","items").split(".")[0]+".webp")

func add_collision_shapes(parent: StaticBody3D):
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
	aabb_collision.owner = parent
	#aabb_collision.position.y += aabb_shape.y/2
	aabb_collision.transform.origin = aabb.position + aabb.size
	parent.add_child(aabb_collision)
	
	# Convex collision
	var convex_shape := mesh_instance.mesh.create_convex_shape()
	var convex_collision := CollisionShape3D.new()
	convex_collision.name = "ConvexCollision"
	convex_collision.disabled = true
	convex_collision.shape = convex_shape
	parent.add_child(convex_collision)
	convex_collision.owner = parent
