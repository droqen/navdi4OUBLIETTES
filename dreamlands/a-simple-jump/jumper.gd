extends NavdiSolePlayer

enum {FLORBUF,JUMPBUF}
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, JUMPBUF,4,
])
var vx : float; var vy : float;
func _physics_process(_delta: float) -> void:
	var dpad : Vector2 = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -1.0
	var tofloor : float = $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1)
	var onfloor : bool = vy >= 0 and tofloor < 1
	if onfloor: position.y += tofloor; bufs.on(FLORBUF)
	vx = move_toward(vx, dpad.x * 1.0, 0.1)
	vy = move_toward(vy, 1.2, 0.05) * 0.99
	if vx and not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vx):
		vx = 0
	if vy and not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vy):
		vy = 0
	
