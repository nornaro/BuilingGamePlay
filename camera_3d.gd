# Edit file: res://camera_3d.gd
@tool
extends Camera3D

@export var refresh:Button = Button.new()
@export var capture:Button = Button.new()

func _ready() -> void:
	connect()
	# Wait for proper initialization
	await get_tree().process_frame
	
	# Get the parent SubViewport
	var viewport = get_parent()
	if not viewport is SubViewport:
		return
	
	# Get the viewport texture
	var viewport_texture = viewport.get_texture()
	
	# Wait for rendering to complete
	await RenderingServer.frame_post_draw
	
	# Get the image from the texture
	var image = viewport_texture.get_image()
	
	# Get the path of the scene this script is in
	var scene_path = get_tree()
	if scene_path.is_empty():
		# Fallback for when scene isn't saved yet
		scene_path = "user://temp_icon"
	else:
		# Remove .tscn extension
		scene_path = scene_path.get_basename()
	
	# Save the image with same base name as scene
	var save_path = scene_path + ".webp"
	image.save_webp(save_path)
	print("Saved icon to: ", save_path)
