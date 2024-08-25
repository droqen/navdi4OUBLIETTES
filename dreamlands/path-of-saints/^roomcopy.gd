extends Node
class_name RoomCopy

@export var copyname : String = ''

static var roomcopies_cleared : Array = []

func clear_all_copies() -> void:
	if not copyname in RoomCopy.roomcopies_cleared:
		RoomCopy.roomcopies_cleared.append(copyname)

func _enter_tree() -> void:
	if copyname in RoomCopy.roomcopies_cleared:
		var maze = get_parent() as Maze
		for redcell in maze.get_used_cells_by_tids([12]):
			maze.set_cell_tid(redcell, -1)
