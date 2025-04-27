extends EditorScript

func _ready() -> void:
	create_box_shape_from_mesh(%crypt)


func create_box_shape_from_mesh(mesh_instance: MeshInstance3D) -> BoxShape3D:
	var mesh: Mesh = mesh_instance.mesh
	if mesh == null:
		return null

	var aabb: AABB = mesh.get_aabb()
	var box_shape := BoxShape3D.new()
	box_shape.size = aabb.size
	return box_shape

func add_collision_shape_to_mesh(mesh_instance: MeshInstance3D):
	var shape = create_box_shape_from_mesh(mesh_instance)
	if shape == null:
		return

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = shape
	collision_shape.position = mesh_instance.mesh.get_aabb().position + mesh_instance.mesh.get_aabb().size * 0.5

	mesh_instance.add_child(collision_shape)
