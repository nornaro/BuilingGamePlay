@tool
extends EditorScript

func _run():
	var main_dict = {}
	
	# Get all kaykit folders in addons
	var kaykit_folders = []
	var dir = DirAccess.open("res://addons/")
	if dir:
		dir.list_dir_begin()
		var folder = dir.get_next()
		while folder != "":
			if folder.begins_with("kaykit_") and dir.current_is_dir():
				kaykit_folders.append(folder)
			folder = dir.get_next()
	
	# Process each kaykit folder
	for folder in kaykit_folders:
		var parts = folder.split("_")
		if parts.size() < 2:
			continue
			
		var key_name = parts[1]  # Second word after "kaykit"
		var tscn_files = []
		
		# Scan Assets/gltf folder for .tscn files
		var assets_dir = DirAccess.open("res://addons/%s/Assets/gltf/" % folder)
		if assets_dir:
			assets_dir.list_dir_begin()
			var file = assets_dir.get_next()
			while file != "":
				if file.ends_with(".tscn"):
					tscn_files.append(file)
				file = assets_dir.get_next()
		
		if not tscn_files.is_empty():
			main_dict[key_name] = tscn_files
	
	# Create the output file content
	var output = "# Auto-generated file - do not edit manually!\n"
	output += "extends Object\n\n"
	output += "var tscn_files = {\n"
	
	# Add each entry to the output
	for key in main_dict:
		output += "    \"%s\": [\n" % key
		for file in main_dict[key]:
			output += "        \"%s\",\n" % file
		output += "    ],\n"
	
	output += "}\n"
	
	# Write to file
	var output_file = FileAccess.open("res://scripts/tscn_files.gd", FileAccess.WRITE)
	if output_file:
		output_file.store_string(output)
		print("Successfully wrote tscn_files dictionary to res://scripts/tscn_files.gd")
	else:
		printerr("Failed to open output file for writing")
