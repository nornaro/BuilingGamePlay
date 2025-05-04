extends RayCast3D

var cube_scene :PackedScene
@onready var cube:Node3D
@onready var world:Node3D = %World
@onready var buttons:Array = %ItemBar.get_children()
@onready var buttoncount:int = %ItemBar.get_child_count()-1
@onready var rc:RayCast3D = $RayCast3D2


func _ready() -> void:
	$Sprite2D.position = $"..".get_viewport().get_visible_rect().size/2

func _physics_process(delta):
	if !cube:
		return
	for ray:RayCast3D in get_tree().get_nodes_in_group("rc"):
		rc = ray
		if rc.is_colliding() && rc.get_collider():
			cube.global_transform = rc.get_collider().add_box_from_raycast(rc, cube)
			return
	cube.global_position = to_global(target_position)
	

func _unhandled_input(event: InputEvent) -> void:
	for i:int in range(1, buttoncount):
		if Input.is_physical_key_pressed(KEY_0 + i):
			buttons[i].emit_signal("pressed")
	if Input.is_action_just_released("delete"):
		if !rc.get_collider().is_in_group("temp") && rc.get_collider().name != "Ground":
			rc.get_collider().queue_free()
		set_cube(cube_scene)
	if !cube:
		return
	if Input.is_action_just_released("lmb") and rc.is_colliding():
		cube.get_node("AABBCollision").disabled = false
		cube.get_node("AABBCollision").global_position.y += cube.get_node("AABBCollision").shape.size.y/2
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
	if Input.is_action_just_pressed("delete"):
		cube.queue_free()
		
func set_cube(sc:PackedScene):
	cube_scene = sc
	cube = cube_scene.instantiate()
	cube.add_to_group("temp")
	world.add_child(cube)
