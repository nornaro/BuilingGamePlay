extends Node

var InventoryPanel: PackedScene = preload("res://inventory_panel.tscn")

func _ready() -> void:
	# Get the current scene root
	var scene_root = get_tree().root
	if not scene_root:
		push_error("No scene open in editor")
		return
	
	# Find the InventoryTabs container
	var InventoryTabs = scene_root.find_child("InventoryTabs", true, false)
	if not InventoryTabs:
		push_error("Could not find InventoryTabs node")
		return
	
	# Clear existing tabs
	for child in InventoryTabs.get_children():
		InventoryTabs.remove_child(child)
		child.queue_free()
	
	var items = FileAccess.open("res://scripts/tscn_files.dat", FileAccess.READ).get_var()
	if not items:
		push_error("No items found in tscn_files.gd")
		return
	
	# Create tabs for each category
	for category in items:
		var inventory = InventoryPanel.instantiate()
		inventory.name = category.split("_")[1].capitalize()
		InventoryTabs.add_child(inventory)
		var grid = inventory.find_child("InventoryGrid", true, false)
		
		# Set owner after adding to scene tree
		inventory.owner = scene_root
		grid.owner = scene_root
		
		# Add items to grid
		for item:String in items[category]:
			var button = TextureButton.new()
			button.name = item
			TextureButton.SIZE_SHRINK_CENTER
			button.custom_minimum_size = Vector2(72, 72)
			button.stretch_mode = TextureButton.STRETCH_SCALE
			button.ignore_texture_size = true
			
			# Set tooltip with formatted name
			var item_name = item.get_basename().replace("_", " ").capitalize()
			print(item)
			button.tooltip_text = item_name
			button.name = item
			button.set_script(load("res://button.gd"))
			button.path = "res://items/"+category+"/Assets/gltf/"+item.split(".")[0]+".tscn"
			var icon_path = "res://items/"+category+"/Assets/gltf/"+item.split(".")[0]+".webp"
			if ResourceLoader.exists(icon_path):
				button.texture_normal = load(icon_path)
			
			grid.add_child(button)
			#grid.add_child(TextureButton.new())
			#print(button.get_parent())
			button.owner = scene_root
	
	print("Inventory UI created successfully!")
