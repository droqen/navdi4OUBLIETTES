extends Node
@onready var maze : Maze = get_parent()
var _clear : bool
func _init(clear : bool) -> void:
	_clear = clear
func _ready() -> void:
	var spike_cells = maze.get_used_cells_by_tids([80])
	for c in spike_cells: maze.set_cell_tid(c, 82)
	await get_tree().create_timer(0.05).timeout
	spike_cells = maze.get_used_cells_by_tids([80,82])
	for c in spike_cells: maze.set_cell_tid(c, 80)
	if _clear:
		spike_cells.shuffle()
		var delay : float = 0.1
		for c in spike_cells:
			maze.set_cell_tid(c, 82)
			await get_tree().create_timer(0.05).timeout
			maze.set_cell_tid(c, 81)
			await get_tree().create_timer(delay).timeout
			delay *= 0.8
	queue_free()
	
