extends Node
@onready var maze : Maze = get_parent()
var _clear : bool
func _init(clear : bool) -> void:
	_clear = clear
func _ready() -> void:
	change_all_into([80],82)
	change_all_into([83],85)
	change_all_into([90],92)
	change_all_into([93],95)
	await get_tree().create_timer(0.05).timeout
	change_all_into([82],80)
	change_all_into([85],83)
	change_all_into([92],90)
	change_all_into([95],93)
	if _clear:
		var spike_cells : Array[Vector2i] = maze.get_used_cells_by_tids([80,83,90,93])
		spike_cells.shuffle()
		var delay : float = 0.1
		for c in spike_cells:
			var tid = maze.get_cell_tid(c)
			maze.set_cell_tid(c, tid+2)
			await get_tree().create_timer(0.05).timeout
			maze.set_cell_tid(c, tid+1)
			await get_tree().create_timer(delay).timeout
			delay *= 0.8
	queue_free()
func change_all_into(froms:Array[int],to:int)->void:
	for from_cell in maze.get_used_cells_by_tids(froms):
		maze.set_cell_tid(from_cell, to)
	
