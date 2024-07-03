extends Node

@onready var maze : Maze = get_parent()
@onready var tree : SceneTree = get_tree()

class Squelcher:
	var _squelching:bool=false;
	var _maze:Maze; var _tree; var _tid1;
	var _chance; var _fraction;
	var _delay; var _tids;
	func _init(maze, tree, tid1, chance, fraction, delay, tids) -> void:
		_maze=maze; _tree=tree;
		_tid1=tid1; _chance=chance; _fraction=fraction;
		_delay=delay; _tids=tids;
	func proc():
		if not _squelching and randf() < _chance:
			var cells = [];
			for cell in _maze.get_used_cells_by_tids([_tid1]):
				if randf()<_fraction:cells.append(cell)
			if cells:
				_squelching = true;
				cells.shuffle()
				for tid in _tids:
					for cell in cells:
						_maze.set_cell_tid(cell,tid);
						await _tree.physics_frame
					await _tree.create_timer(_delay).timeout
				_squelching = false;

@onready var squelchers : Array[Squelcher] = [
	Squelcher.new(maze, tree, 0, 0.01, 0.25, 0.10, [6,0,5,0]),
	#Squelcher.new(maze, tree, 1, 0.01, 0.12, 0.10, [2,3,2,1]),
	Squelcher.new(maze, tree, 7, 0.02, 0.25, 0.15, [8,9,9,8,7]),
]

func _physics_process(_delta: float) -> void:
	for s in squelchers: s.proc()
