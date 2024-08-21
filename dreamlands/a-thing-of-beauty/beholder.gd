extends NavdiSolePlayer

enum {Jumpbuf,Florbuf}
var bufs = Bufs.Make(self).setup_bufons([
	Jumpbuf,4,Florbuf,16,
])

@onready var spr : SheetSprite = $SheetSprite
@onready var mover : NavdiBodyMover = $NavdiBodyMover
@onready var caster : ShapeCast2D = $NavdiBodyMover/ShapeCast2D

var vx:float;var vy:float;

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit():bufs.on(Jumpbuf)
	if Pin.get_plant_held():vy=move_toward(vy,3.0,0.04);bufs.clr(Florbuf);
	if dpad.x:spr.flip_h=dpad.x<0
	if bufs.try_eat([Florbuf, Jumpbuf]): vy=-0.8
	if vy>=0:
		var tofloor : float = mover.cast_fraction(self,caster,VERTICAL,1)
		if tofloor < 1: position.y += tofloor; bufs.on(Florbuf); vy = 0;
	vx=move_toward(vx,dpad.x,0.1)
	vy=move_toward(vy,3.0,0.031)
	if vy!=0 and not mover.try_move(self,caster,VERTICAL,vy):
		vy=0
	if vx!=0 and not mover.try_slip_move(self,caster,HORIZONTAL,vx):
		vx=0
	if bufs.has(Florbuf):
		# on floor
		if dpad.x: spr.setup([31,21,31,],4)
		else: spr.setup([21])
	else:
		var fwdvx:float=vx
		if spr.flip_h:fwdvx=-fwdvx
		if fwdvx>0.5:spr.setup([41])
		elif fwdvx>-0.5:spr.setup([42])
		else:spr.setup([43])
