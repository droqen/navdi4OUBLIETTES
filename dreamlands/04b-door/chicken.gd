extends NavdiSolePlayer

@onready var mover = $mover
@onready var cast = $mover/cast
@onready var spr = $spr
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	TURNBUF,4,FLAPBUF,4,
])
enum { TURNBUF,FLAPBUF, }

var vx : float; var vy : float;
var last_jheld : bool;

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var downheld = Pin.get_plant_held()
	var jheld = Pin.get_jump_held()
	var jreleased : bool = last_jheld and not jheld
	last_jheld = jheld
	if jreleased:
		bufs.on(FLAPBUF)
		vy *= 0.5
	if bufs.has(FLAPBUF):
		vy -= 0.30
	vx = move_toward(vx, dpad.x, 0.1)
	vy = move_toward(vy, 1.2, 0.025)
	if jheld:
		if vy < 0: vy *= 0.85
		else: vy *= 0.90
	elif downheld:
		vy = move_toward(vy, 2.0, 0.030) # more fastfall
	if vx and!mover.try_slip_move(self,cast,HORIZONTAL,vx):
		vx=0
	if vy and!mover.try_slip_move(self,cast,VERTICAL,vy):
		vy=0
	var onfloor:bool = (vy>=0 and mover.cast_fraction(
		self,cast,VERTICAL,1)<1)
	if abs(vx)>=1.0 and onfloor:
		vx = move_toward(vx, dpad.x * 2.0, 0.11)
	if dpad.x and ((dpad.x < 0) != spr.flip_h):
		spr.flip_h = dpad.x < 0
		bufs.on(TURNBUF)
	if bufs.has(TURNBUF):
		spr.setup([13])
	elif onfloor:
		if jheld:
			if dpad.x: spr.setup([41,40,42,40],8)
			else: spr.setup([40])
		elif downheld:
			if dpad.x: spr.setup([51,50,52,50],8)
			else: spr.setup([50])
		else:
			if dpad.x: spr.setup([11,10,12,10],8)
			else: spr.setup([10])
	else:
		if bufs.has(FLAPBUF): spr.setup([16])
		elif jheld: spr.setup([15])
		elif downheld: spr.setup([18])
		else: spr.setup([17])
