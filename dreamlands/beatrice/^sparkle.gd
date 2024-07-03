extends Node

@onready var maze : Maze = get_parent()

var sparkling : bool = false

func _physics_process(_delta: float) -> void:
	if not sparkling and randf() < 0.01: sparkle()
func sparkle() -> void:
	var sparkley_cells = []
	for cell in maze.get_used_cells_by_tids([1]):
		if randf() < 0.08: sparkley_cells.append(cell)
	if sparkley_cells:
		sparkling = true
		sparkley_cells.shuffle()
		var tree = get_tree()
		for tid in [2,3,2,1]:
			for cell in sparkley_cells: maze.set_cell_tid(cell, tid); await tree.physics_frame
			await tree.create_timer(0.1).timeout
		sparkling = false
