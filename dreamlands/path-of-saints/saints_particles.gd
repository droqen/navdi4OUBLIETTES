extends Node2D

static var goalrot : float = 0.0
var angvel : float = 0.0
func _physics_process(_delta: float) -> void:
	var togoalrot = goalrot - rotation
	angvel = move_toward(angvel * 0.99, togoalrot*0.05, 0.001)
	rotation += angvel
