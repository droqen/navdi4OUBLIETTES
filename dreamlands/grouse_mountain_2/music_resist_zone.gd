extends Area2D

@export var minpx : float = -10.0
@export var maxpx : float = 10.0

func _physics_process(_delta: float) -> void:
	var player = null
	for area in get_overlapping_areas():
		if area.get_parent().get('IS_PLAYER_GROUSE'):
			player = area.get_parent()
	if player:
		var bgm = get_tree().get_first_node_in_group("GrouseBGM")
		if bgm:
			var sweep : float = inverse_lerp(minpx, maxpx, player.position.x - position.x)
			if minpx < maxpx:
				if player.vel.x > 0: player.vel.x *= lerp(0.8,0.3,sweep)
				else: player.vel.x -= 0.5 * sweep
			if maxpx < minpx:
				if player.vel.x < 0: player.vel.x *= lerp(0.8,0.3,sweep)
				else: player.vel.x += 0.5 * sweep
			bgm.set_sweep(sweep, 0.0 if sweep < 0.5 else 1.0)
