extends NavdiSolePlayer

enum { JUMPBUF, FLORBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons([JUMPBUF,4,FLORBUF,4,])
var vel : Vector2
@onready var mover : NavdiBodyMover = $mover
@onready var solidcast : ShapeCast2D = $mover/solidcast
@onready var spr : SheetSprite = $spr
func _physics_process(delta: float) -> void:
	var dpad : Vector2
	dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	vel.x = move_toward(vel.x, dpad.x * 1.0, 0.07)
	vel.y = move_toward(vel.y, 1.6, 0.07)
	var onfloor : bool
	onfloor = vel.y>=0 and mover.cast_fraction(self,solidcast,VERTICAL,1)<1
	if onfloor: bufs.on(FLORBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vel.y = -1.2
	if not mover.try_slip_move(self, solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not mover.try_move(self,solidcast,VERTICAL,vel.y):
		vel.y = 0
	if dpad.x: spr.flip_h = dpad.x < 0
	if onfloor:
		if dpad.x:
			spr.setup([3,1,2,1],8)
		else:
			spr.setup([1])
	else:
		spr.setup([2])
