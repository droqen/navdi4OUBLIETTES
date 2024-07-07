extends Node

var waity : int = 0

func _physics_process(_delta: float) -> void:
	waity -= 1
	match waity:
		0,10,25:
			for cell in get_parent().get_used_cells_by_tids([10,11,12] as Array[int]):
				var tid = get_parent().get_cell_tid(cell)
				tid += 1; if tid >= 13: tid = 10
				get_parent().set_cell_tid(cell,tid)
		_:
			if waity < 0: waity = randi_range(70,90)
