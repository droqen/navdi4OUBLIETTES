extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, }

var vel : Vector2
var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,5, JUMPBUF,5,])

func _physics_process(_delta: float) -> void:
	var dpad : Vector2
	dpad = Pin.get_dpad()
	vel.x = move_toward(vel.x, dpad.x, 0.1)
	vel.y = move_toward(vel.y, 1.6, 0.035)
	if vel.y < 0 and not Pin.get_jump_held(): vel.y += 0.065
	var onfloor : bool = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if onfloor: bufs.on(FLORBUF)
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	if bufs.try_eat([JUMPBUF,FLORBUF,]):
		vel.y = -1.3
