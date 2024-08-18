extends Node2D

var player : Node2D = null

var targetpos_x : float = 0

func _enter_tree() -> void:
	show()
	player = NavdiSolePlayer.GetPlayer(self)
	if player: update_hide()
	position.x = targetpos_x

func _physics_process(delta: float) -> void:
	if not player: player = NavdiSolePlayer.GetPlayer(self)
	if player: update_hide()

func update_hide() -> void:
	if player.position.x <= 175:
		targetpos_x = 180
	elif player.position.x >= 185:
		targetpos_x = -180
	else:
		targetpos_x = 0
	position.x = lerp(position.x, targetpos_x, 0.1)
