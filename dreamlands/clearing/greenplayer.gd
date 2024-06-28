extends Node2D

var vel : Vector2

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	vel.x = move_toward(vel.x, dpad.x * 1.0, 0.1)
	vel.y = move_toward(vel.y, 2.0, 0.1)
	if Pin.get_jump_hit(): vel.y = -1.5
	var maze : Maze = $mazer.get_maze()
	var cell = maze.local_to_map(position)
	var tid = maze.get_cell_tid(cell)
	match tid:
		13,14,15:
			maze.set_cell_tid(cell, tid+10)
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	#var onfloor = vel.y >= 0 and 
