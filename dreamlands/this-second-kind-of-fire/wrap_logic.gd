extends Node
const FlagCheckpoint = preload("res://dreamlands/this-second-kind-of-fire/flagcheckpoint.gd")
@onready var player = $"../fireplayer"
@onready var camera = $"../Camera2D"
@onready var maze = $"../Maze"
var camvel : Vector2
const W = 300
const H = 220
const W2 = W/2
const H2 = H/2
const H4 = H/4

func _physics_process(_delta: float) -> void:
	if player and not is_instance_valid(player): player = null
	
	var current_checkpoint = get_parent().get_node_or_null(FlagCheckpoint.ActiveCheckName)
	
	var camtarget : Vector2 = camera.position
	if current_checkpoint:
		camtarget = current_checkpoint.position
	if player:
		camtarget.y = min(camtarget.y, player.position.y + H4)
	var totarget = camtarget - camera.position
	var spd : float = 0.2 + totarget.length() * 0.02
	var todesiredvel = totarget.limit_length(spd) - camvel
	camvel *= 0.99
	camvel += todesiredvel.limit_length(0.05)
	camera.position += camvel
	
	if player:
		if player.just_died():
			if totarget.length() > 100.0:
				camvel += todesiredvel * 0.1
		else:
			if player.position.x < camera.position.x - W2:
				player.position.x += W
			if player.position.x > camera.position.x + W2:
				player.position.x -= W
		#if player.position.y < camera.position.y - H2:
			#player.position.y += H
		#if player.position.y > camera.position.y + H2:
			#player.position.y -= H
		if player.position.y > camera.position.y + H2 + 4:
			player.die()
		else:
			var tid = maze.get_cell_tid(maze.local_to_map(player.position))
			if tid == 8:
				if player.position.x > 500:
					LiveDream.GetDream(self).windfish_lucidwake.emit("A")
				elif player.position.y > 400:
					LiveDream.GetDream(self).windfish_lucidwake.emit("B")
				else:
					LiveDream.GetDream(self).windfish_lucidwake.emit("?")
				player.queue_free()
