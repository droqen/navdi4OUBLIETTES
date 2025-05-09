extends Node

func _ready():
	var maze = get_parent()
	await get_tree().process_frame
	for c in maze.get_used_cells_by_tids([6,16] as Array[int]):
		match maze.get_cell_tid(c):
			6: maze.set_cell_tid(c,-1)
			16:
				maze.set_cell_tid(c,-1)
				var door = load("res://dreamlands/02a-redkey/door.tscn").instantiate()
				door.position = maze.map_to_center(c)
				var p = get_parent()
				p.add_child(door)
				door.owner = p.owner if p.owner else p
