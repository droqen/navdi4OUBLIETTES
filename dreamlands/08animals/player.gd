extends NavdiSolePlayer

enum {
	FLORBUF,
	JUMPHITBUF,
	CHIMNYBUF,
}

@onready var spr = $SheetSprite
@onready var mover = $NavdiBodyMover
@onready var solidcast = $NavdiBodyMover/ShapeCast2D
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,5, JUMPHITBUF,5, CHIMNYBUF,3, ])

var vx : float;
var vy : float;
var ajs : int = 1;
var ajflippyfloppin : bool = false
var ducking : bool = false
var inchimny : bool = false

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPHITBUF)
	if bufs.try_eat([JUMPHITBUF,FLORBUF]):
		vy = -1.0
	elif ajs>0 and bufs.try_eat([JUMPHITBUF]):
		vy = -1.0
		ajs -= 1
		ajflippyfloppin = true
	var onfloor : bool = (vy >= 0 and
	mover.cast_fraction(self, solidcast, VERTICAL, 1) < 1
	)
	var isduck : bool = onfloor and (Pin.get_plant_held() or ducking)
	if isduck: ducking = true
	elif ducking:
		ducking = false
		onfloor = false
		vy = -min(0.5,abs(vx)+0.1)
		bufs.setmin(FLORBUF,20)
	if ajflippyfloppin:
		vx = move_toward(vx, dpad.x * 1.0, 0.005) # sliiight control
	else:
		if isduck:
			if abs(vx) > 0.5 and dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, 0.0, 0.01)
		elif onfloor:
			if dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, dpad.x * 1.0, 0.05)
		else:
			if dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, dpad.x * 1.0, 0.02)
	
	vy = move_toward(vy, 2.0, 0.01)
	if vy < 0 and not Pin.get_jump_held():
		vy += 0.02 # faster fall! end your jump early
	elif vy > 0:
		vy += 0.02
		if ajflippyfloppin: vy += 0.01 # flippyfloppin falls a lil xtra fast
	
	if onfloor:
		bufs.on(FLORBUF)
		if vy > 1 and ajflippyfloppin:
			vy = -0.5 # boink
			ajs = 1; ajflippyfloppin = false;
			onfloor = false; bufs.setmin(FLORBUF,20)
	
	if vx and!mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		if isduck:
			vx *= -0.75
		elif ajflippyfloppin or abs(vx) >= 1:
			vx *= -0.75
			spr.flip_h = vx < 0
			vy *= 0.5
			vy -= 0.4
			ajs = 0
			ajflippyfloppin = true;
			onfloor = false
		else:
			vx=0; # it's fine to just stop, lol
	if vy and!mover.try_slip_move(self, solidcast, VERTICAL, vy):
		if vy > 1 and ajflippyfloppin:
			vy = -0.5 # boink
			ajs = 1; ajflippyfloppin = false;
			onfloor = false; bufs.setmin(FLORBUF,20)
		else:
			vy=0;
	
	if onfloor:
		ajs = 1
		ajflippyfloppin = false
		if isduck:
			if spr.frame == 20: spr.setup([20])
			else: spr.setup([21,20],5)
		elif (dpad.x or vx):
			if len(spr.frames) != 2:
				match spr.frame:
					23: spr.setup([22,23],8)
					_:  spr.setup([23,22],8)
		else:
			spr.setup([22,22,22,23],30)
	else:
		if ajflippyfloppin:
			if vy > 0: spr.setup([13,14,15,23],20)
			else: spr.setup([13,14,15,23],6)
		else:
			spr.setup([23])