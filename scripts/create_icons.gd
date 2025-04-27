# New file: res://scripts/generate_single_icon.gd
@tool
extends EditorScript

const ICON_SIZE = 512

func _run():
	# Load target scene to generate icon for
	var target_scene_path = "res://addons/kaykit_character_pack_adventures/Assets/gltf/sword_1handed.tscn"
	generate_icon(target_scene_path)

func generate_icon(scene_path: String):
	print("Generating icon for:", scene_path)
	
	# Load template and target scenes
	var template = preload("res://addons/kaykit_halloween_bits/Assets/gltf/crypt.tscn")
	var target_scene = ResourceLoader.load(scene_path)
	
	if not template or not target_scene:
		push_error("Failed to load required scenes")
		return

	# Create instances
	var template_instance = template.instantiate()
	var target_instance = target_scene.instantiate()
	
	# Find first mesh in target scene
	var mesh_instance = _find_first_mesh_instance(target_instance)
	if not mesh_instance:
		push_error("No MeshInstance3D found in target scene")
		template_instance.free()
		target_instance.free()
		return

	# Get viewport from template
	var viewport = template_instance.get_node("SubViewport")
	viewport.size = Vector2i(ICON_SIZE, ICON_SIZE)
	
	# Add mesh to viewport (positioned where camera expects it)
	var mesh_copy = mesh_instance.duplicate()
	viewport.add_child(mesh_copy)
	
	# Center mesh in view
	var aabb = mesh_copy.get_aabb()
	mesh_copy.global_position = -aabb.get_center()
	
	# Force render
	RenderingServer.force_draw()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	# Save image
	var image = viewport.get_texture().get_image()
	if image and image.get_size() != Vector2i.ZERO:
		var save_path = scene_path.get_basename() + "_icon.webp"
		if image.save_webp(save_path, 0.9) == OK:
			print("Successfully saved icon to:", save_path)
		else:
			push_error("Failed to save image")
	else:
		push_error("Failed to capture valid image")
	
	# Cleanup
	template_instance.free()
	target_instance.free()

func _find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = _find_first_mesh_instance(child)
		if result:
			return result
	return null
