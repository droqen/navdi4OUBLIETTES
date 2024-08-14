extends Node

var maze : Maze
var redcells : Array[Vector2i]
var stopped : bool = false

func _ready() -> void:
	self.maze = get_parent()
	if maze:
		self.redcells = maze.get_used_cells_by_tids([12])
		for i in range(100):
			var c : int = 20
			if i < 4: c = 20
			elif i < 12:
				if i % 2 == 0: c = 21
				else: c = -1
			else: break
			for cell in redcells:
				maze.set_cell_tid(cell, c)
			await get_tree().physics_frame
			if stopped: break
		#for cell in redcells:
			#maze.set_cell_tid(cell, -1)
	queue_free()

func _exit_tree() -> void:
	if maze and redcells:
		for cell in redcells:
			maze.set_cell_tid(cell, -1)
		if maze.has_node("RoomCopy"):
			maze.get_node("RoomCopy").clear_all_copies()
		stopped = true
