extends TabContainer


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Inventory"):
		visible = !visible
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
