extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, WALLBUF, CRAWLBUF, }

var wallbuf_dir : int
var vx : float; var vy : float;
var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,4,JUMPBUF,4,WALLBUF,4,CRAWLBUF,4])
var dead : bool = false
var dead_age : int = 0

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	vy = move_toward(vy, 1.0, 0.01)
	var onfloor = vy >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
	var onwall : int = dpad.x if (dpad.x and $mover.cast_fraction(self, $mover/solidcast, HORIZONTAL, dpad.x) < 1) else 0
	var crawl = false
	if dead:
		if dead_age < 100:
			dead_age += 1
		if Pin.get_dpad_tap() or Pin.get_jump_hit():
			escape("respawn"); return;
		vx = move_toward(vx, 0, 0.01)
	elif onfloor:
		crawl = Pin.get_plant_held()
		bufs.on(FLORBUF)
		if crawl:
			vx = move_toward(vx, dpad.x * 0.23, 0.06)
			bufs.on(CRAWLBUF)
		else:
			vx = move_toward(vx, dpad.x * 0.46, 0.04)
	elif onwall != 0:
		bufs.on(WALLBUF)
		wallbuf_dir = onwall
		vx = move_toward(vx, dpad.x * 0.66, 0.10)
		if vy > 0: vy *= 0.95
	else:
		if bufs.try_eat([CRAWLBUF]): vx = 0; position.y += 1.4
		if dpad.x: vx = move_toward(vx, dpad.x * 0.66, 0.01)
		if vy < 0 and not Pin.get_jump_held(): vy += 0.05 # very fast
	
	if not dead:
		if Pin.get_jump_hit(): bufs.on(JUMPBUF)
		if bufs.try_eat([FLORBUF,JUMPBUF]): onfloor = false; vy = -0.8;
		if bufs.try_eat([JUMPBUF,WALLBUF]):
			if vy > 0: vy = 0
			onwall = 0; vy -= 0.35; vx = wallbuf_dir * -0.66;
		if dpad.x:
			$spr.flip_h = dpad.x < 0
		
	if dead:
		$spr.setup([24])
	elif onwall:
		$spr.setup([15])
		$spr.flip_h = onwall < 0
	elif not onfloor:
		if vy >= 0.90: $spr.setup([25,26,27],13)
		elif vy >= 0.80: $spr.setup([25,34],3)
		elif vy >= 0.60: $spr.setup([25,35,34,35],3)
		elif vy >= 0.40: $spr.setup([34])
		elif vy >= 0.40: $spr.setup([34])
		elif vy >= 0.25: $spr.setup([33])
		elif vy > 0: $spr.setup([32])
		else: $spr.setup([13])
	elif crawl:
		if dpad.x:
			$spr.setup([23,22,22,23], 8)
		else:
			$spr.setup([22])
	elif dpad.x:
		if $spr.frames[0] == 13:
			$spr.setup([12,14,12,13], 13)
		else:
			$spr.setup([14,12,13,12], 13)
	else:
		$spr.setup([12])
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vx):
		vx = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vy):
		if vy >= 0.95: dead = true
		vy = 0
	
