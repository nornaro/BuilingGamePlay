# New file: res://scripts/tscn_files.gd
@tool
extends EditorScript

func _run():
	var tscn_files = {}
	var base = "res://addons/"
	
	# Get directories
	var dirs = DirAccess.get_directories_at(base)
	if dirs == null:
		printerr("Failed to access directory: ", base)
		return
	
	for folder in dirs:
		if !folder.begins_with("kaykit_"):
			continue
			
		tscn_files[folder] = []
		var gltf_path = base + folder + "/Assets/gltf/"
		
		# Check if gltf directory exists
		if !DirAccess.dir_exists_absolute(gltf_path):
			continue
			
		# Get files
		var files = DirAccess.get_files_at(gltf_path)
		if files == null:
			printerr("Failed to access directory: ", gltf_path)
			continue
			
		for file in files:
			if !(file.ends_with(".gltf") || file.ends_with(".glb")):
				continue
			tscn_files[folder].append(file)

	# Write output
	var output_file = FileAccess.open("res://scripts/tscn_files.dat", FileAccess.WRITE)
	if output_file == null:
		printerr("Failed to open output file: ", FileAccess.get_open_error())
		return
		
	output_file.store_var(tscn_files)
	output_file.close()
