extends NavdiSolePlayer

enum { GRASSRUSTLEBUF=1000, BIGFLAPBUF, PREBIGFLAPBUF, PECKBUF, }

var vel : Vector2
var bufs : Bufs = Bufs.Make(self).setup_bufons([GRASSRUSTLEBUF,10, BIGFLAPBUF,13, PREBIGFLAPBUF,3, PECKBUF,10,])
func _physics_process(delta: float) -> void:
	var dpad : Vector2
	dpad = Pin.get_dpad()
	if bufs.has(PECKBUF): dpad *= 0
	if Pin.get_jump_hit():
		vel.y = -1.5
		bufs.on(BIGFLAPBUF)
		bufs.on(PREBIGFLAPBUF)
	vel.x = move_toward(vel.x, dpad.x, 0.1)
	if vel.y > 0 and Pin.get_jump_held():
		vel.y = move_toward(vel.y, 0.25, 0.05)
	else:
		vel.y = move_toward(vel.y, 1.5, 0.1)
	if dpad.x: $spr.flip_h = dpad.x < 0
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	var onfloor : bool = $mover.cast_fraction(self, $mover/solidcast,
	VERTICAL, 1.0) < 1 and vel.y >= 0
	if onfloor and Pin.get_plant_hit():
		bufs.on(PECKBUF); vel.x = 0;
	var hidden_in_grass : bool = false
	var maze : Maze = LiveDream.GetRoom(self).maze
	var rect = RectangleShape2D.new()
	rect.size = Vector2(2,2)
	for cell in $mazer.find_all_overlapping_cells(position + Vector2(0,-2), rect):
		var tid = maze.get_cell_tid(cell)
		match tid:
			12,13:
				if bufs.read(GRASSRUSTLEBUF) <= 1:
					maze.set_cell_tid(cell, 12 if tid!=12 else 13)
				hidden_in_grass = true
	
	if hidden_in_grass:
		hide()
		if bufs.read(GRASSRUSTLEBUF) <= 1: bufs.on(GRASSRUSTLEBUF)
	else:
		show()
		if bufs.read(GRASSRUSTLEBUF) == 1:
			for cell in maze.get_used_cells_by_tids([13]):
				maze.set_cell_tid(cell, 12)
		if onfloor:
			if bufs.has(PECKBUF):
				$spr.setup([22])
			elif dpad.x:
				$spr.setup([11,10],8)
			else:
				$spr.setup([10])
		else:
			if bufs.has(PREBIGFLAPBUF): $spr.setup([20])
			elif bufs.has(BIGFLAPBUF): $spr.setup([21])
			elif Pin.get_jump_held(): $spr.setup([20,21],7)
			else: $spr.setup([20])
