extends NavdiSolePlayer

@export var transparent : bool = false;

const GREENBLOCK_TIDS = [10,20,21, 22,23,]

enum {
	STAND=101, FLY, FALL, WALK, PLANTING,
	PINJUMPBUF=201, PINPLANTBUF, FLORBUF, PLANTINGBUF, FLYENERGYBUF,
}
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	PINJUMPBUF,4, PINPLANTBUF,4, FLORBUF,4, PLANTINGBUF,20, FLYENERGYBUF,60,
])
var state : TinyState = TinyState.new(STAND,func(_then,now):
	match now:
		STAND: $spr.setup([2])
		FLY: $spr.setup([5,6],4)
		FALL: $spr.setup([7,7,17,7,17,],5)
		WALK: $spr.setup([4,2],9)
		PLANTING: $spr.setup([9,8],7)
	if transparent:
		for i in range(len($spr.frames)):
			$spr.frames[i] += 80
)
var vel : Vector2

func delete_matched_cells(maze: Maze, cells: Array[Vector2i]):
	for cell in cells:
		maze.set_cell_tid(cell, 12)
	await get_tree().create_timer(0.08).timeout
	for cell in cells:
		maze.set_cell_tid(cell, -1 if transparent else 0)

func _physics_process(delta: float) -> void:
	#if position.y < 5: position.y = 5
	var dpad : Vector2
	var jhit : bool; var jheld : bool; var phit : bool;
	var onfloor : bool = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1.0) < 1
	if onfloor: bufs.on(FLORBUF)
	if bufs.has(PLANTINGBUF):
		if not onfloor: bufs.clr(PLANTINGBUF) # cncael
		if bufs.read(PLANTINGBUF) == 1:
			# let's do it!
			var maze : Maze = $mazer.get_maze()
			var target_cell = $mazer.find_best_floor_cell_if_any(position, $mover/solidcast.shape)
			if target_cell and maze.get_cell_tid(target_cell) in GREENBLOCK_TIDS:
				var target_cells = maze.magic_wand(target_cell,
					func(c): return maze.get_cell_tid(c) in GREENBLOCK_TIDS
				)
				delete_matched_cells(maze, target_cells)
	else:
		dpad = Pin.get_dpad()
		jhit = Pin.get_jump_hit(); if jhit: bufs.on(PINJUMPBUF)
		jheld = Pin.get_jump_held()
		phit = Pin.get_plant_hit(); if phit: bufs.on(PINPLANTBUF)
	if !$mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if !$mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	if dpad.x : $spr.flip_h = dpad.x < 0
	vel.x = move_toward(vel.x, dpad.x * 1, 0.1)
	if jheld:
		vel.y = move_toward(vel.y, -1, 0.2)
	else:
		vel.y = move_toward(vel.y, 1, 0.06)
	
	if onfloor and bufs.try_eat([PINPLANTBUF]):
		vel *= 0
		bufs.on(PLANTINGBUF)
	
	if bufs.has(PLANTINGBUF):
		state.goto(PLANTING)
	elif jheld:
		state.goto(FLY)
	elif onfloor:
		if dpad.x: state.goto(WALK)
		else: state.goto(STAND)
	else:
		state.goto(FALL)
