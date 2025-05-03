# New file: res://scripts/create_inventory.gd
@tool
extends EditorScript

var InventoryPanel: PackedScene = preload("res://inventory_panel.tscn")

func _run():
	# Get the current scene root
	var scene_root = get_scene()
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
	
	# Load items data
	var items_script = load("res://scripts/tscn_files.gd")
	if not items_script:
		push_error("Could not load tscn_files.gd")
		return
	
	var items = IL.new().items
	if not items:
		push_error("No items found in tscn_files.gd")
		return
	
	# Create tabs for each category
	for category in items:
		var inventory = InventoryPanel.instantiate()
		inventory.name = category.capitalize()
		InventoryTabs.add_child(inventory)
		var grid = InventoryTabs.find_child("InventoryGrid", true, false)
		
		# Set owner after adding to scene tree
		inventory.owner = scene_root
		grid.owner = scene_root
		
		# Add items to grid
		for item in items[category]:
			var button = TextureButton.new()
			button.name = item
			TextureButton.SIZE_SHRINK_CENTER
			button.custom_minimum_size = Vector2(48, 48)
			#button.stretch_mode = TextureButton.STRETCH_KEEP
			
			# Set tooltip with formatted name
			var item_name = item.get_basename().replace("_", " ").capitalize()
			button.tooltip_text = item_name
			button.name = item
			
			# Try to load icon texture
			#var icon_path = "res://addons/kaykit_character_pack_adventures/Assets/gltf/%s_icon.webp" % item
			#var icon_path = "res://addons/"
			#if ResourceLoader.exists(icon_path):
				#button.texture_normal = load(icon_path)
			
			grid.add_child(button)
			grid.add_child(TextureButton.new())
			button.owner = scene_root
	
	print("Inventory UI created successfully!")
