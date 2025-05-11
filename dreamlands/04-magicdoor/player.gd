extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, ROLLINBUF, OUCHBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,7,JUMPBUF,4,ROLLINBUF,28,OUCHBUF,20,
])
var faceleft : bool = false
var flipping : float = 0.0
var upsidedown : bool = false
var airrollin : bool = false
var vx : float; var vy : float;
@onready var spr : SheetSprite = $spr
@onready var mover : NavdiBodyMover = $mover
@onready var cast : ShapeCast2D = $mover/cast
func _physics_process(_delta: float) -> void:
	if !bufs.has(OUCHBUF) and !bufs.has(ROLLINBUF):
		if $spike_toucher.get_overlapping_bodies():
			if vy >= 0:
				bufs.on(OUCHBUF)
				vx = -1.0
				vy = -1.0
	
	var ouch : bool = bufs.has(OUCHBUF)
	
	var dpad = Pin.get_dpad()
	if ouch: dpad *= 0
	elif Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor : bool = (vy >= 0 and
		mover.cast_fraction(self, cast, VERTICAL, 1) < 1)
	
	if dpad.x and not bufs.has(ROLLINBUF):
		faceleft = dpad.x < 0
		spr.flip_h = faceleft
	
	if ouch:
		pass
	elif onfloor:
		if bufs.has(ROLLINBUF):
			vx = move_toward(vx, 0.0, 2.0 / 40)
			bufs.on(FLORBUF)
		elif Pin.get_plant_hit():
			bufs.on(ROLLINBUF)
			vx = -2 if faceleft else 2
		elif posmod(spr.rotation_degrees,360) != 0 and vy>0.8:
			flipping = 3.9
			vy=-0.6
			onfloor=false
			bufs.clr(FLORBUF)
		else:
			upsidedown = false
			vx = move_toward(vx, dpad.x * 1.0, 0.1)
			flipping = 0.0
			bufs.on(FLORBUF)
	else:
		if !upsidedown:
			if abs(vx) < 0.5:
				vx = move_toward(
					vx,
					dpad.x*0.5,
					0.01)
		if Pin.get_plant_hit():
			bufs.on(ROLLINBUF)
			if faceleft and vx > -0.5:
				vx = -0.5
			if !faceleft and vx < 0.5:
				vx = 0.5
			vy = 1.0
			upsidedown = false
			airrollin = true
	
	vy = move_toward(vy, 1.0, 0.04)
	
	if !bufs.has(FLORBUF) or bufs.has(ROLLINBUF):
		if bufs.try_eat([JUMPBUF]) and !upsidedown:
			vy = -1.0; upsidedown = true; vx *= 0.25;
			if abs(vx)<0.25:
				vx = -0.25 if faceleft else 0.25
			bufs.clr(ROLLINBUF)
	if bufs.try_eat([FLORBUF,JUMPBUF]):
		vy = -1
		onfloor = false
		flipping = 0.5
	if vx and!mover.try_slip_move(self,cast,HORIZONTAL,vx):
		if upsidedown:
			vx *= -1
		else:
			vx = 0.0
	if vy and!mover.try_slip_move(self,cast, VERTICAL ,vy):
		if ouch:
			vy *= -0.5
		else:
			vy=0
			if airrollin:
				airrollin = false;
				vx *= 2;
	
	if dpad.x or vx:
		$spr.setup([35,34,],8)
	else:
		$spr.setup([34,34,34,35,],16)
	
	if bufs.has(OUCHBUF):
		spr.visible = bufs.read(OUCHBUF) % 4 < 2
		faceleft = false
		spr.flip_h = faceleft
		spr.rotation_degrees = 270
		flipping = 3.0
	elif (bufs.has(ROLLINBUF) or not onfloor) and !upsidedown:
		flipping += 0.065
		if bufs.has(ROLLINBUF):
			flipping += 0.07
		$spr.rotation_degrees = ceil(flipping) * (-90 if faceleft else 90)
	elif onfloor:
		$spr.rotation = 0
	else:
		$spr.rotation_degrees = 180
