extends Node

@export var skipchance : float = 0.0
@export var randchance : float = 0.0
const LETS = ['C','G','O','Q','D','P','B','R','E','F','L','I','J','T','H','K','M','N','Z','V','W','U','Y','A','X','S',]
var letid : int = 0
func _physics_process(_delta: float) -> void:
	if randf() < skipchance:
		return
	elif randf() < randchance:
		letid = randi() % 26
	else:
		letid = (letid+1) % 26
	get_parent().text = LETS[letid]
