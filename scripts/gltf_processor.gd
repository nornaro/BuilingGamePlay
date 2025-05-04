extends Node

@export var output_dir := "res://items/"

var _gltf_doc := GLTFDocument.new()
var _gltf_state := GLTFState.new()

func process_glb_file(glb_path: String) -> String:
	# Load GLB and convert to scene
	var err := _gltf_doc.append_from_file(glb_path, _gltf_state)
	if err != OK:
		push_error("Failed to load GLB: " + glb_path)
		return ""
	
	var scene_root := _gltf_doc.generate_scene(_gltf_state)
	if not scene_root:
		push_error("Failed to generate scene from GLB")
		return ""
	
	# Add collision and script
	_add_collision_to_scene(scene_root)
	_add_script_to_node(scene_root)
	
	# Save scene
	var tscn_path := output_dir.path_join(glb_path.get_file().get_basename() + ".tscn")
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene_root)
	err = ResourceSaver.save(packed_scene, tscn_path)
	if err != OK:
		push_error("Failed to save scene: " + tscn_path)
		return ""
	
	return tscn_path

func _add_collision_to_scene(scene_root: Node3D) -> void:
	for child in scene_root.get_children():
		if child is MeshInstance3D:
			var aabb: AABB = child.get_aabb()
			var collision := CollisionShape3D.new()
			collision.shape = BoxShape3D.new()
			collision.shape.size = aabb.size
			collision.position = aabb.get_center()
			
			var area := Area3D.new()
			area.add_child(collision)
			scene_root.add_child(area)

func _add_script_to_node(node: Node) -> void:
	var script := GDScript.new()
	script.source_code = """extends Node3D

func _ready():
	pass
"""
	script.reload()
	node.set_script(script)

func batch_process_directory(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		push_error("Cannot open directory: " + dir_path)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.get_extension() == "glb" or file_name.get_extension() == "gltf"):
			var full_path := dir_path.path_join(file_name)
			process_glb_file(full_path)
		file_name = dir.get_next()
