extends Node

@onready var maze : Maze = get_parent()

var gotkey : bool = false

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	if player:
		var cell = maze.local_to_map(player.position)
		match maze.get_cell_tid(cell):
			12:
				maze.set_cell_tid(cell, 0)
				gotkey = true
			14:
				if gotkey:
					maze.set_cell_tid(cell, 0)
