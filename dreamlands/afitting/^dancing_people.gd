extends Node

var dancebuf : int = 0
var danceframe : int = 0

func _physics_process(_delta: float) -> void:
	if dancebuf > 0:
		dancebuf -= 1
	else:
		dancebuf = 10
		var maze : Maze = get_parent()
		danceframe = (danceframe + 1) % 4
		for c in maze.get_used_cells_by_tids([22,23]):
			maze.set_cell_tid(c, 22 + danceframe%2)
		for c in maze.get_used_cells_by_tids([24,25,26,27]):
			maze.set_cell_tid(c, 24 + danceframe%4)
