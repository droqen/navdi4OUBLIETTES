extends NavdiSolePlayer

func _physics_process(_delta: float) -> void:
	position += Pin.get_dpad() as Vector2
