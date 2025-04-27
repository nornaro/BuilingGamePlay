# New file: res://scripts/create_inventory.gd
@tool
extends EditorScript


func _run():
	# Load the panel scene
	var panel_scene = load("res://panel.tscn")
	if not panel_scene:
		push_error("Could not load panel.tscn")
		return
	
	# Get the current scene root
	var scene_root = get_scene()
	if not scene_root:
		push_error("No scene open in editor")
		return
	
	# Find or create the Inventory TabContainer
	var inventory = scene_root.find_child("Inventory", true, false)
	if not inventory:
		inventory = TabContainer.new()
		inventory.name = "Inventory"
		scene_root.add_child(inventory)
		inventory.owner = scene_root
	
	for child:Node in inventory.get_children():
		inventory.remove_child(child)
		child.free()

	# Clear existing tabs
	for child in inventory.get_children():
		child.queue_free()
	
	# Load the items data directly from the script
	var items_script = load("res://scripts/tscn_files.gd")
	if not items_script:
		push_error("Could not load tscn_files.gd")
		return
	
	# Create a temporary instance to access the items dictionary
	var temp_node = Node.new()
	temp_node.set_script(items_script)
	var items = IL.new().items
	temp_node.free()
	
	if not items:
		push_error("No items found in tscn_files.gd")
		return
	
	# Create tabs for each category
	for category in items:
		print(category)
		# Create panel instance
		var panel = panel_scene.instantiate()
		panel.name = category.capitalize()
		inventory.add_child(panel)
		panel.owner = scene_root
		
		# Create buttons for each item
		for item in items[category]:
			var button = Button.new()
			button.custom_minimum_size = Vector2(25, 25)
			
			# Format item name
			var item_name = item.get_basename().replace("_", " ").capitalize()
			button.text = item_name
			button.name = item
			
			panel.add_child(button)
			button.owner = scene_root
	
	print("Inventory UI created successfully!")
