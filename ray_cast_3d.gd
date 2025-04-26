extends RayCast3D

var cube_scene :PackedScene
@onready var cube:Node3D
@onready var world:Node3D = %World
@onready var buttons:Array = %ItemBar.get_children()
@onready var buttoncount:int = %ItemBar.get_child_count()-1

func _physics_process(delta):
	if !cube:
		return
	if not is_colliding():
		cube.global_position = to_global(target_position)
		return
	cube.global_transform = get_collider().add_box_from_raycast(self, cube)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("alt"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Input.is_action_just_released("alt"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for i:int in range(1, buttoncount):
		if Input.is_physical_key_pressed(KEY_0 + i):
			buttons[i].emit_signal("pressed")
	if !cube:
		return
	if Input.is_action_just_released("lmb") and is_colliding():
		cube.get_node("Collision").disabled = false
		cube.remove_from_group("temp")
		set_cube(cube_scene)
	cube.visible = Input.is_action_pressed("rmb")
	if Input.is_action_just_released("+90"):
		cube.rotation.y += deg_to_rad(90)
	if Input.is_action_just_released("-90"):
		cube.rotation.y += deg_to_rad(-90)
	if Input.is_action_pressed("+"):
		target_position.z += 0.1
	if Input.is_action_pressed("-"):
		target_position.z -= 0.1
	if Input.is_action_just_released("delete"):
		if !get_collider().is_in_group("temp"):
			get_collider().queue_free()
		
func set_cube(sc:PackedScene):
	cube_scene = sc
	cube = cube_scene.instantiate()
	cube.add_to_group("temp")
	world.add_child(cube)
