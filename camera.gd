# Edit file: res://camera.gd
extends Camera3D

const MOVE_SPEED = 5.0
const LOOK_SENSITIVITY = 0.003
const JUMP_FORCE = 5.0

var velocity = Vector3.ZERO

func _input(event):
	if Input.is_action_pressed("alt"):
		return
	# Mouse look (only if right mouse button is pressed)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * LOOK_SENSITIVITY)

func _physics_process(delta):
	# Get input directions
	var input_dir = Input.get_vector("a", "d", "s", "w")
	
	# Calculate movement direction relative to camera orientation
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	var up = Vector3.UP
	
	var direction = Vector3.ZERO
	direction += forward * input_dir.y  # W/S - forward/back
	direction += right * input_dir.x    # A/D - left/right
	
	# Normalize to prevent faster diagonal movement
	direction = direction.normalized()
	
	# Apply movement
	if direction:
		velocity.x = direction.x * MOVE_SPEED
		velocity.z = direction.z * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED)
	
	# Vertical movement (space = up, ctrl = down)
	if Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
	elif Input.is_action_pressed("ctrl"):
		velocity.y = -JUMP_FORCE
	else:
		velocity.y = 0
	
	# Apply movement
	global_translate(velocity * delta)
