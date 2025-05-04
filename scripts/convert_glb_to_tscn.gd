# New file: res://scripts/convert_glb_to_tscn.gd
@tool
extends EditorScript

func _run():
	var glb_files := find_glb_files_in_addons()
	if glb_files.is_empty():
		push_error("No GLB files found in Kaykit addons")
		return
	
	for glb_path in glb_files:
		print("Processing: ", glb_path)
		convert_glb_to_tscn(glb_path)

func find_glb_files_in_addons() -> Array[String]:
	var glb_files: Array[String] = []
	var dir := DirAccess.open("res://addons/")
	
	if not dir:
		push_error("Failed to access addons directory")
		return glb_files
	
	dir.list_dir_begin()
	var addon_name := dir.get_next()
	
	while addon_name != "":
		if dir.current_is_dir() and addon_name.begins_with("Kaykit"):
			var kaykit_dir := DirAccess.open("res://addons/" + addon_name)
			if kaykit_dir:
				_find_glb_files_recursive("res://addons/" + addon_name, glb_files)
		addon_name = dir.get_next()
	
	dir.list_dir_end()
	return glb_files

func _find_glb_files_recursive(path: String, glb_files: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				_find_glb_files_recursive(path + "/" + file_name, glb_files)
		elif file_name.get_extension() == "glb":
			glb_files.append(path + "/" + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()

func convert_glb_to_tscn(glb_path: String) -> void:
	# Load the GLB scene
	var glb_scene = load(glb_path)
	if not glb_scene:
		push_error("Failed to load GLB scene: " + glb_path)
		return
	
	# Create a temporary scene to render
	var temp_scene = glb_scene.instantiate()
	
	# Use Papershot to render the icon
	var icon_path = glb_path.get_basename() + "_icon.webp"
	
	# Save the TSCN scene
	var tscn_path = glb_path.get_basename() + ".tscn"
	var packed_scene = PackedScene.new()
	packed_scene.pack(temp_scene)
	var error = ResourceSaver.save(packed_scene, tscn_path)
	
	if error != OK:
		push_error("Failed to save scene to: " + tscn_path)
		return
	
	print("Successfully converted %s to %s and %s" % [glb_path, tscn_path, icon_path])
