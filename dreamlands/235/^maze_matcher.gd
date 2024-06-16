extends Node

var do_check : bool = false

func _ready() -> void:
	get_parent().changed.connect(func():do_check=true)

func _physics_process(delta: float) -> void:
	if do_check:
		var maze : Maze = get_parent()
		var sum : int = 0
		var cells : Array[Vector2i] = []
		for pair in [[16,2],[17,3],[18,5]]:
			var atlas_coords = maze.tid2coord(pair[0])
			var number_value : int = pair[1]
			for cell in maze.get_used_cells_by_id(0, atlas_coords):
				cells.append(cell)
				sum += number_value
		
		if sum == 10:
			for cell in cells:
				maze.set_cell_tid(cell,2)
		if sum > 10:
			for cell in cells:
				maze.set_cell_tid(cell,maze.get_cell_tid(cell)-10)
		
		do_check = false

func _exit_tree() -> void:
	var maze : Maze = get_parent()
	var sum : int = 0
	var cells : Array[Vector2i] = []
	for pair in [[16,2],[17,3],[18,5]]:
		var atlas_coords = maze.tid2coord(pair[0])
		var number_value : int = pair[1]
		for cell in maze.get_used_cells_by_id(0, atlas_coords):
			cells.append(cell)
			sum += number_value
	if sum < 10:
		for cell in cells:
			maze.set_cell_tid(cell,maze.get_cell_tid(cell)-10)
