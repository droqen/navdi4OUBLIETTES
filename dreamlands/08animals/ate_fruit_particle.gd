extends Node2D
@export var colour : Color
func _ready() -> void:
	var p : CPUParticles2D = $CPUParticles2D
	p.color = colour;
	p.one_shot = true;
	p.restart()
	await p.finished
	queue_free()
