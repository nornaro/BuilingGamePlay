# Edit file: res://addons/kaykit_dungeon_remastered/Assets/gltf/camera_3d.gd
@tool
extends Camera3D
var papershot:Node

func _update_camera() -> void:
	var collision:CollisionShape3D = $"../../Collision"
	if is_inside_tree() and collision and collision.shape:
		position = collision.shape.size + collision.position
	pass
	
func _ready() -> void:
	get_parent().find_children("", "Papershot", true, false)[0]
	_update_camera()
	papershot.take_screenshot()
	print(get_path())
	#$"..".queue_free()
