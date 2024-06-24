extends NavdiSolePlayer

enum {
	FLORBUF, PINJUMPBUF, ONWALBUF, DEADFREEZBUF, DEADVANISHBUF, # PLANTBUF, # no planting tho?
	CONSECUTIVE_DEATH_FRAMES_BUF,
}

func _ready() -> void:
	super._ready()
	var maze : Maze = $mazer.get_maze()
	for c in maze.get_used_cells_by_tids([25]):
		maze.set_cell_tid(c, min(10 + randi()%4, 10 + randi()%4))

var dead : bool = false
var reallydead : bool = false
func revive(pos:Vector2):
	position = pos
	dead = false
	reallydead = false
	vel *= 0
	rotation = 0
	show()

var last_onwall : int = 0
var last_onfloor : bool
var vel : Vector2
var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,4, PINJUMPBUF,4, ONWALBUF,4,])
func _physics_process(delta: float) -> void:
	if position.y > 200:
		reallydead = true
	if reallydead: return
	if dead:
		if bufs.has(DEADFREEZBUF):
			call('show' if randf()<0.5 else 'hide')
			if visible: position += vel * 0.25
			return;
		elif bufs.read(DEADVANISHBUF) < 20:
			call('show' if randf()<0.5 else 'hide')
		else:
			show()
		if not bufs.has(DEADVANISHBUF): reallydead = true
		position += vel
		vel.y += 0.03
		rotation += vel.x * 0.3
		return
	
	var dpad : Vector2i
	dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(PINJUMPBUF)
	var onfloor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
	if onfloor: bufs.on(FLORBUF)
	var onwall : int = 0
	if dpad.x:
		$SheetSprite.flip_h = dpad.x < 0
		if $mover.cast_fraction(self, $mover/solidcast, HORIZONTAL, dpad.x) < 1:
			onwall = dpad.x
			last_onwall = onwall
			bufs.on(ONWALBUF)
	
	vel.x = move_toward(vel.x, dpad.x * 1.0, 0.06)
	
	if onwall:
		vel.y = move_toward(vel.y, 0.1, 0.10)
	else:
		vel.y = move_toward(vel.y, 2.0,
			0.10 if (vel.y < 0 and not Pin.get_jump_held())
			else 0.04)
	
	if onwall and bufs.try_eat([PINJUMPBUF]):
		vel.x = -onwall * 0.55
		vel.y = -1.0
	elif bufs.try_eat([FLORBUF, PINJUMPBUF]):
		vel.y = -1.3
		onfloor = false
	elif bufs.try_eat([ONWALBUF, PINJUMPBUF]):
		vel.x = -last_onwall * 0.55
		vel.y = -1.0
		onfloor = false
	
	if onwall:
		$SheetSprite.setup([34])
	elif onfloor:
		if dpad.x: $SheetSprite.setup([35,33,37,33],8)
		elif Pin.get_plant_held(): $SheetSprite.setup([32])
		else: $SheetSprite.setup([33,33,33,33,33,32],10)
	else:
		if vel.y < 0: $SheetSprite.setup([35])
		else: $SheetSprite.setup([37])

	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		if vel.y > 0: vel.y = 0
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	
	var maze : Maze = $mazer.get_maze()
	var cell = maze.local_to_map(position)
	match maze.get_cell_tid(cell):
		#0: maze.set_cell_tid(cell, 20)
		#0,1:
			#for cel2 in maze.get_used_cells_by_tids([20,21,22,23,24,25]):
				#maze.set_cell_tid(cel2, maze.get_cell_tid(cel2) - 10)
		10: maze.set_cell_tid(cell, 21)
		11: maze.set_cell_tid(cell, 22)
		12: maze.set_cell_tid(cell, 23)
		13: maze.set_cell_tid(cell, 24)
		14: die()
			
	for dx in range(-2,2+1):
		for dy in range(-2,2+1):
			if abs(dx)==2 or abs(dy)==2:
				var cel2 = cell + Vector2i(dx,dy)
				match maze.get_cell_tid(cel2):
					20,21,22,23,24:
						maze.set_cell_tid(cel2, maze.get_cell_tid(cel2)-10)

	last_onfloor = onfloor

func die():
	if bufs.read(CONSECUTIVE_DEATH_FRAMES_BUF) >=3:
		dead = true
		vel.x = randf_range(-0.5, 0.5)
		vel.y = randf_range(-0.5,-0.3)
		rotation = randf_range(-0.2,0.2)
		var maze : Maze = $mazer.get_maze()
		for cell in maze.get_used_cells_by_tids([20,21,22,23,24]):
			maze.set_cell_tid(cell, maze.get_cell_tid(cell)-10)
		$SheetSprite.setup([45])
		bufs.setmin(DEADFREEZBUF, 30)
		bufs.setmin(DEADVANISHBUF, 90)
	else:
		bufs.setmin(CONSECUTIVE_DEATH_FRAMES_BUF, bufs.read(CONSECUTIVE_DEATH_FRAMES_BUF) + 2)
