extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, }
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons( 
	[FLORBUF,6, JUMPBUF,6,]
)

@onready var mover = $mover
@onready var cast = $mover/cast
@onready var spr = $spr
var vx : float
var vy : float
var spin : int = 0

func _physics_process(_delta: float) -> void:
	if Pin.get_jump_hit(): vy = -1
	var dpad = Pin.get_dpad()
	vx = move_toward(vx,dpad.x*0.8,0.15)
	vy = move_toward(vy,1.0,0.02)
	if vy < 0 and !Pin.get_jump_held():
		vy += 0.05
	var onfloor : bool = vy >= 0 and mover.cast_fraction(
		self, cast, VERTICAL,1)<1
	if onfloor: bufs.on(FLORBUF)
	if vx and!mover.try_slip_move(self,cast,HORIZONTAL,vx):
		vx = 0
	if vy and!mover.try_slip_move(self,cast,VERTICAL,vy):
		vy = 0
	if Pin.get_plant_held():
		spr.setup([33])
	else:
		spr.setup([22])
