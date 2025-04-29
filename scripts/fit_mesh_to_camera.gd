# Edit file: res://camera.gd
extends Camera3D

@export var target_mesh: MeshInstance3D

func _ready():
	if target_mesh:
		fit_mesh_to_view()

func fit_mesh_to_view():
	# Get mesh bounds
	var aabb = target_mesh.get_aabb()
	var mesh_size = aabb.size
	
	# Calculate required distance based on current FOV
	var fov_rad = deg_to_rad(fov)
	var viewport_size = get_viewport().size
	var aspect_ratio = viewport_size.x / viewport_size.y
	
	# Calculate distance needed to fit mesh vertically
	var distance = (mesh_size.y * 0.5) / tan(fov_rad * 0.5)
	
	# Check if we need more distance to fit horizontally
	var horizontal_fov = 2 * atan(tan(fov_rad * 0.5) * aspect_ratio)
	var horizontal_distance = (mesh_size.x * 0.5) / tan(horizontal_fov * 0.5)
	distance = max(distance, horizontal_distance)
	
	# Add small buffer to ensure full visibility
	distance *= 1.1
	
	# Position mesh in front of camera
	var forward = -global_transform.basis.z
	target_mesh.global_position = global_position + forward * distance
	
	# Rotate mesh to face camera (optional)
	target_mesh.look_at(global_position)
