extends NavdiSolePlayer

enum { PINJUMPBUF, FLORBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	PINJUMPBUF,4, FLORBUF,4,
])
var vel : Vector2

func _physics_process(_delta: float) -> void:
	var dpad : Vector2
	var jumpheld : bool
	var onfloor : bool
	var mover : NavdiBodyMover = $NavdiBodyMover
	var shape : ShapeCast2D = $NavdiBodyMover/ShapeCast2D
	var floorcast : ShapeCast2D = $NavdiBodyMover/FloorCast
	var mazer : NavdiBodyMazer = $NavdiBodyMazer
	var spr : SheetSprite = $SheetSprite
	
	dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(PINJUMPBUF)
	if Pin.get_jump_held(): jumpheld = true
	
	if dpad.x: spr.flip_h = dpad.x < 0
	
	onfloor = (vel.y >= 0
		and mover.cast_fraction(self, floorcast, VERTICAL, 1) < 1)
	if onfloor: bufs.on(FLORBUF)
	
	vel.x = move_toward(vel.x, dpad.x * 1, 0.10)
	vel.y = move_toward(vel.y, 4.0, 0.032)
	if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, 0.05)
	
	if not mover.try_slip_move(self, shape, HORIZONTAL, vel.x):
		vel.x = 0
	if not mover.try_slip_move(self, floorcast if vel.y >= 0 else shape, VERTICAL, vel.y):
		vel.y = 0
	
	if bufs.try_eat([PINJUMPBUF, FLORBUF]):
		vel.y = -1.5
		onfloor = false

	if onfloor:
		if dpad.x:
			spr.setup([11,10,12,10], 8)
		else:
			spr.setup([10])
	else:
		spr.setup([11])
