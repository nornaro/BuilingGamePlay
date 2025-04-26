extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta):
	# Get the input direction
	var input_dir = Input.get_vector("a", "d", "w", "s")
	
	# Get camera basis vectors
	var camera = get_viewport().get_camera_3d()
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	
	# Calculate movement direction relative to camera
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	# Apply movement on ground
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Handle vertical movement (space = up, ctrl = down)
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("crouch"):
		velocity.y = -JUMP_VELOCITY
	else:
		velocity.y = 0
	
	move_and_slide()