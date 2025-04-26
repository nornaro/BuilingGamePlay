extends StaticBody3D

func add_box_from_raycast(ray: RayCast3D, cube:Node) -> Transform3D:
	cube.global_position = global_position + cube.get_node("Collision").shape.size * ray.get_collision_normal().round()
	return cube.global_transform
