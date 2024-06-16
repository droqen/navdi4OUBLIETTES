@tool
extends Label

@export var count_please : bool : 
	get() : return false
	set(v) :
		if v :
			var maze : Maze = get_parent()
			text = "twos - %d\nthrees - %d\nfives - %d" % [
				len(maze.get_used_cells_by_id(0, Vector2i(6,0))),
				len(maze.get_used_cells_by_id(0, Vector2i(7,0))),
				len(maze.get_used_cells_by_id(0, Vector2i(8,0))),
			]
