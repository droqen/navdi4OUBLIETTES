extends Node

func get_dpad() -> Vector2i:
	return Vector2i(
		(1 if Input.is_action_pressed("right") else 0)-
		(1 if Input.is_action_pressed("left") else 0),
		0
		#(1 if Input.is_action_pressed("down") else 0)-
		#(1 if Input.is_action_pressed("up") else 0)
	)

func get_dpad_tap() -> Vector2i:
	return Vector2i(
		(1 if Input.is_action_just_pressed("right") else 0)-
		(1 if Input.is_action_just_pressed("left") else 0),
		0
		#(1 if Input.is_action_just_pressed("down") else 0)-
		#(1 if Input.is_action_just_pressed("up") else 0)
	)

func get_jump_hit() -> bool: return Input.is_action_just_pressed("jump")
func get_jump_held() -> bool: return Input.is_action_pressed("jump")
func get_plant_hit() -> bool: return Input.is_action_just_pressed("plant")
func get_plant_held() -> bool: return Input.is_action_pressed("plant")
