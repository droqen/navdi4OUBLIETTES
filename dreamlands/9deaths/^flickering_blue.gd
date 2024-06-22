extends Node

var blue_loop_tid : int = 24
var blue_loop_buf : int = 20

var allgone : bool = false

func _physics_process(_delta: float) -> void:
	var maze : Maze = get_parent()
	if blue_loop_buf > 0:
		blue_loop_buf -= 1
		if blue_loop_buf == 1:
			var blue_loop_tid2 = blue_loop_tid + 1
			if blue_loop_tid2 > 27:
				blue_loop_tid2 = 24
			for cell_blue in maze.get_used_cells_by_id(0, maze.tid2coord(blue_loop_tid)):
				maze.set_cell_tid(cell_blue, blue_loop_tid2)
			for cell_blue in maze.get_used_cells_by_id(0, maze.tid2coord(blue_loop_tid+10)):
				maze.set_cell_tid(cell_blue, blue_loop_tid2+10)
			blue_loop_tid = blue_loop_tid2
	else:
		blue_loop_buf = 5
	for cell23 in maze.get_used_cells_by_id(0, maze.tid2coord(23)):
		maze.set_cell_tid(cell23, blue_loop_tid)
	for cell33 in maze.get_used_cells_by_id(0, maze.tid2coord(33)):
		maze.set_cell_tid(cell33, blue_loop_tid+10)
	
	if not allgone:
		allgone = true
		for cell16 in maze.get_used_cells_by_id(0, maze.tid2coord(16)):
			allgone = false; break;
		if allgone:
			NavdiSolePlayer.GetPlayer(self).queue_free() # bye player
			prints("awaken the wind fish", $"../../..")
			$"../../..".windfish_awakened.emit()
