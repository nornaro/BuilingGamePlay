extends StaticBody3D

func add_box_from_raycast(ray: RayCast3D, cube:Node) -> Transform3D:
	cube.global_position = ray.get_collision_point() + Vector3(0,0,0)
	return cube.global_transform
