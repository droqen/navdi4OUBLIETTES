extends NavdiSolePlayer

enum {FLORBUF,JUMPBUF}
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, JUMPBUF,4,
])
var vx : float; var vy : float;
var jumpjuice : int;
var airtime : int;
func _physics_process(_delta: float) -> void:
	var dpad : Vector2 = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if Pin.get_jump_held() and not bufs.has(FLORBUF) and jumpjuice > 0:
		jumpjuice += 1
	else:
		if jumpjuice > 50: jumpjuice = 50; vy *= 0.5
		jumpjuice -= 1
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -1.0; jumpjuice = 1;
	var tofloor : float = $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1)
	var onfloor : bool = vy >= 0 and tofloor < 1
	if onfloor: position.y += tofloor; bufs.on(FLORBUF); jumpjuice = 0; airtime = 0;
	else: airtime += 1
	vx = move_toward(vx, dpad.x * 1.0, 0.1)
	if jumpjuice > 100:
		var f : float = remap(float(jumpjuice), 100.0, 170.0, 0.0, 0.4)
		vx *= 1.0-f
		vy -= abs(vx)*f*0.01
	if jumpjuice < 170 + airtime / 10 - 17:
		vy -= jumpjuice * 0.0004
	else:
		jumpjuice = -1
	vy = move_toward(vy, 2.2, 0.03) * 0.99
	if jumpjuice < 0: vy += 0.03
	if vx and not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vx):
		vx = 0
	if vy and not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vy):
		if vy > 2.0:
			vy *= -0.5
		else:
			vy = 0
	
	if position.x > 385: position.x = 5
	if position.x < 5: position.x = 385
