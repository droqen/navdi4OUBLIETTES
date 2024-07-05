extends NavdiSolePlayer

enum { PIN_JUMPBUF, PIN_DUCKBUF, FLORBUF, DUCKBUF, ONWALBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	PIN_JUMPBUF,4, PIN_DUCKBUF,4,
	FLORBUF,4,DUCKBUF,10,ONWALBUF,4])
var vel : Vector2
var last_onwal_dir : int = 0
@onready var mazer : NavdiBodyMazer = $mazer
@onready var mover : NavdiBodyMover = $mover
@onready var solidcast : ShapeCast2D = $mover/solidcast
@onready var spr : SheetSprite = $spr
func _physics_process(delta: float) -> void:
	var dpad : Vector2
	var jumpheld : bool
	if bufs.has(DUCKBUF):
		vel.x = 0
	else:
		dpad = Pin.get_dpad()
		if Pin.get_jump_hit(): bufs.on(PIN_JUMPBUF)
		if Pin.get_plant_hit(): bufs.on(PIN_DUCKBUF)
		if Pin.get_jump_held(): jumpheld = true
	
	var onwall : int = 0
	if dpad.x and mover.cast_fraction(self,solidcast,HORIZONTAL,dpad.x) < 1:
		onwall = dpad.x
	if onwall:
		bufs.on(ONWALBUF)
		last_onwal_dir = onwall
		
	vel.x = move_toward(vel.x, dpad.x * 1.0, 0.07)
	if onwall:
		vel.y = move_toward(vel.y * 0.90, 0.1, 0.035)
	else:
		vel.y = move_toward(vel.y, 1.6, 0.055)
		if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, 0.055)
		
	var onfloor : bool
	onfloor = vel.y>=0 and mover.cast_fraction(self,solidcast,VERTICAL,1)<1
	if onfloor: bufs.on(FLORBUF)
	if bufs.try_eat([PIN_JUMPBUF,FLORBUF]):
		vel.y = -1.85
		onfloor = false
	elif onfloor and bufs.try_eat([PIN_DUCKBUF]):
		vel.y = -0.30
		onfloor = false
		vel.x = 0.0
		bufs.on(DUCKBUF)
	elif bufs.try_eat([ONWALBUF, PIN_JUMPBUF]):
		vel.y = -1.44
		vel.x = -0.50 * last_onwal_dir
	
	if bufs.has(FLORBUF) and not onfloor:
		if vel.y >= 0: vel.y = 0.50
		if dpad.x * vel.x <= 0:
			vel.x = 0
	
	if not mover.try_slip_move(self, solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not mover.try_move(self,solidcast,VERTICAL,vel.y):
		vel.y = 0
	if dpad.x: spr.flip_h = dpad.x < 0
	if bufs.has(DUCKBUF):
		spr.setup([21])
	elif onwall:
		spr.setup([22])
	elif onfloor:
		if dpad.x:
			spr.setup([3,1,2,1],8)
		else:
			spr.setup([1])
	else:
		spr.setup([2])
	
	var maze : Maze = mazer.get_maze()
	match maze.get_cell_tid(maze.local_to_map(position)):
		6: escape(6)
		8: escape(8)
