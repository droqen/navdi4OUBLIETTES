extends Node

const DesertPlayer = preload("res://dreamlands/desert-archive/desert_player.gd")

var stopfloatbuf : int = 0

func _physics_process(_delta: float) -> void:
	var player : DesertPlayer = DesertPlayer.GetPlayer(self) as DesertPlayer
	if stopfloatbuf > 0:
		stopfloatbuf -= 1
	elif player and Pin.get_dpad().x:
		if player.vel.y > -1: player.vel.y -= 0.1
		else: stopfloatbuf = 15 + randi() % 15
