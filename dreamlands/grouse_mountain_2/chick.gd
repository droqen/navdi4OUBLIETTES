extends Node2D

enum { HUNGRY, FULL }

signal ate

var vely : float = 0.0

var hungryst = TinyState.new(HUNGRY, func(_then, now):
	match now:
		HUNGRY: pass # already hungry
		FULL: $spr.setup([121]); z_index = 0; ate.emit();
)

func manual_process( player : NavdiSolePlayer,
minx : int, maxx : int) -> void:
	var to_player = player.global_position - global_position
	if abs(to_player.x) <6:
		if (
		hungryst.id == HUNGRY and
		abs(to_player.y) <3 and
		player.chick_try_eat()
		):
			hungryst.goto(FULL)
			position.y = 0
	else:
		$spr.flip_h = to_player.x < 0
		match hungryst.id:
			HUNGRY:
				position.y += vely
				if position.y >= 0:
					position.y = 0
					vely = 0
					if randf() < 0.03:
						position.y = -1
						vely = 0
				else:
					vely += 0.02
				if randf() < 0.40:
					position.x += sign(to_player.x) * 0.33
			FULL:
				position.y = -1
				if abs(to_player.y) * 2 > abs(to_player.x):
					$spr.setup([123])
				else:
					$spr.setup([121])
				if randf() < 0.20:
					position.x += sign(to_player.x) * 0.33
		if position.x < minx: position.x = minx
		if position.x > maxx: position.x = maxx
		
