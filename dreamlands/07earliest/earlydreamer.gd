extends NavdiSolePlayer

enum {FLORBUF=1,JUMPBUF,TURNBUF,}
var vx : float; var vy : float; var faceleft : bool;
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4,
	JUMPBUF,4,
	TURNBUF,4,
])
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor=vy>=0 and$mover.cast_fraction(self,$mover/shape,VERTICAL,1)<1
	vy = move_toward(vy, 1.25, 0.03)
	vx = move_toward(vx, dpad.x*0.50, 0.05)
	if vx and!$mover.try_slip_move(self, $mover/shape, HORIZONTAL, vx):
		vx = 0
	if vy and!$mover.try_slip_move(self, $mover/shape, VERTICAL, vy):
		vy = 0
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -1.0 # jump
		onfloor = false
	if onfloor: bufs.on(FLORBUF)
	if dpad.x and (faceleft!=(dpad.x<0)):
		faceleft=!faceleft;bufs.on(TURNBUF);$spr.flip_h=faceleft;
	if bufs.has(TURNBUF):
		$spr.setup([24])
	elif onfloor:
		if dpad.x:
			$spr.setup([12,13,14,11],10)
		else:
			$spr.setup([11])
	else:
		if vy < -0.5: $spr.setup([15])
		elif vy < 0.0: $spr.setup([16])
		else: $spr.setup([17])
