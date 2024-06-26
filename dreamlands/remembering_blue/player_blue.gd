extends Node2D

enum { PADDLE_BUF, DIGGING_BUF, }
var bufs = Bufs.Make(self).setup_bufons([PADDLE_BUF, 15, DIGGING_BUF, 60, ])
var paddle_dpadx : int = 0
var vel : Vector2
var faceleft : bool = false
var blue_frictionless : bool = false

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var friction_damp = 1.00 if blue_frictionless else 0.95 
	
	var onfloor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1.0) < 1
	if bufs.has(DIGGING_BUF):
		pass
	elif onfloor:
		if Pin.get_plant_hit():
			bufs.on(DIGGING_BUF)
			vel.x = 0
			vel.y = 0
		else:
			vel.x = move_toward(vel.x, dpad.x * 0.4, 0.05)
	else:
		vel.x = move_toward(vel.x, dpad.x * 0.5, 0.02)
	vel.y = move_toward(vel.y * friction_damp, 1, 0.02)
	
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	
	if bufs.has(DIGGING_BUF):
		if bufs.read(DIGGING_BUF) == 60-20:
			var tid = get_diggable_tid_here()
			if tid < 0:
				vel.y = -0.35
				bufs.clr(DIGGING_BUF)
		if bufs.read(DIGGING_BUF) == 1:
			var tid = get_diggable_tid_here()
			match tid:
				1:
					var maze : Maze = $mazer.get_maze()
					maze.set_cell_tid(last_dig_cell, 10 * (randi()%6))
			vel.y = -0.35
			bufs.clr(DIGGING_BUF)
	elif not bufs.has(PADDLE_BUF) and Pin.get_jump_hit():
		vel.y = -0.65
		paddle_dpadx = dpad.x
		if paddle_dpadx: faceleft = paddle_dpadx < 0
		bufs.on(PADDLE_BUF)
		blue_frictionless = true
	
	if blue_frictionless:
		if not bufs.has(PADDLE_BUF) and not Pin.get_jump_held():
			blue_frictionless = false
	
	var spr = $SheetSprite
	if bufs.has(DIGGING_BUF):
		spr.setup([12,14,12,14,14,14],12)
	elif onfloor:
		if dpad.x:
			spr.setup([5,4],10)
			faceleft = dpad.x < 0
		else:
			spr.setup([4])
		spr.flip_h = faceleft
	elif bufs.read(PADDLE_BUF) > 1:
		if paddle_dpadx:
			spr.flip_h = paddle_dpadx < 0
			spr.setup([3])
		else:
			spr.setup([6])
	else:
		spr.setup([2])

var last_dig_cell : Vector2i

func get_diggable_tid_here() -> int:
	var maze : Maze = $mazer.get_maze()
	var dig_point = Vector2(
		position.x + (-4 if faceleft else 4),
		position.y + (10)
	)
	last_dig_cell = maze.local_to_map(dig_point);
	var dig_tid = maze.get_cell_tid(last_dig_cell)
	match dig_tid:
		1, 0,10,20,30,40,50: return dig_tid
		_: return -1
