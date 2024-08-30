extends Node2D

var velocity_falling_in : float = 0.0

var win : int = 600

func _physics_process(_delta: float) -> void:
	velocity_falling_in += 0.0001
	scale += Vector2(velocity_falling_in,velocity_falling_in)
	rotation += velocity_falling_in * 0.1
	if win > 0:
		win -= 1
		if win == 0:
			LiveDream.GetDream(self).windfish_lucidwake.emit("NOWHERE")
	
