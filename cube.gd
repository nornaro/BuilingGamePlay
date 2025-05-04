@tool
extends StaticBody3D

func add_box_from_raycast(ray: RayCast3D, cube:Node) -> Transform3D:
	cube.global_position = global_position + cube.global_transform.basis * cube.get_node("AABBCollision").shape.size * ray.get_collision_normal().round()
	return cube.global_transform
