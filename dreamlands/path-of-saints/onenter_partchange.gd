extends Node

const SaintsParticles = preload("res://dreamlands/path-of-saints/saints_particles.gd")

@export var partrot = 0.0

func _enter_tree() -> void:
	SaintsParticles.goalrot = partrot
