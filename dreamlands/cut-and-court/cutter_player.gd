extends NavdiSolePlayer
enum{
	FLORBUF,JUMPHITBUF,
	IDLE,WALK,JUMP,SWORDDASH,SLASHHH}
var bufs:Bufs=Bufs.Make(self).setup_bufons(
	[FLORBUF,4,JUMPHITBUF,4,]
)
var sworddash_dir : int = 0
var sworddash_chg : int = 0
@onready var spr:SheetSprite = $spr;
@onready var mover:NavdiBodyMover = $mover
@onready var caster:ShapeCast2D = $mover/solidcast
@onready var plrst:TinyState=TinyState.new(IDLE,func(_then,now):
	match now:
		IDLE: spr.setup([30])
		WALK: match spr.frame:
			31: spr.setup([32,33,30,31],14)
			33: spr.setup([30,31,32,33],14)
			_:  spr.setup([31,32,33,30],14)
		JUMP: spr.setup([31]) # will be updated live
		SWORDDASH:
			#spr.setup([40,41,42,40],4)
			sworddash_dir=-1 if spr.flip_h else 1
			sworddash_chg=0
		SLASHHH:
			spr.setup([43])
)
var vx:float; var vy:float;
func _physics_process(_delta: float) -> void:
	var dpad : Vector2 = Pin.get_dpad()
	var pin_dashheld : bool = Pin.get_plant_held()
	if Pin.get_jump_hit(): bufs.on(JUMPHITBUF)
	var tofloor : float = mover.cast_fraction(self,caster,VERTICAL,1)
	var onfloor : bool = vy >= 0 and tofloor < 1
	if onfloor:
		bufs.on(FLORBUF)
		if tofloor > 0: position.y += tofloor
	if plrst.id == SWORDDASH:
		sworddash_chg += 1
		if sworddash_chg < 20:
			spr.setup([33])
		elif sworddash_chg < 50:
			spr.setup([41,42,40,40],4)
		else:
			spr.ani_period = 2
			
		var p : float = sworddash_chg * 0.01
		if (
			not onfloor
			or bufs.try_eat([JUMPHITBUF])
			or not pin_dashheld
			or p >= 1.0
			or mover.cast_fraction(self,caster,HORIZONTAL,sworddash_dir)<1 # hit a wall
		):
			onfloor = false
			vx = lerp(0.5,2.0,p) * dpad.x # heel turn
			vy = -lerp(0.8,2.0,p) # big jump
			if sworddash_chg < 20:
				plrst.goto(JUMP)
			else:
				plrst.goto(SLASHHH) # slash requires minimum 20 chg
		else:
			dpad.x = sworddash_dir
			vx=move_toward(vx,lerp(0.5,2.0,p)*dpad.x,0.2)
			vy=move_toward(vy,0.0,0.05)
	else:
		if bufs.try_eat([FLORBUF,JUMPHITBUF]):
			onfloor = false; vy = -1.3
		vx=move_toward(vx,dpad.x*0.7,0.05)
		vy=move_toward(vy,1.0,0.05)
	if dpad.x:spr.flip_h=dpad.x<0;
	if vx and!mover.try_slip_move(self,caster,HORIZONTAL,vx):
		vx=0
	if vy and!mover.try_slip_move(self,caster,VERTICAL,vy):
		vy=0
	
	if onfloor:
		if pin_dashheld: plrst.goto(SWORDDASH)
		elif dpad.x: plrst.goto(WALK)
		else: plrst.goto(IDLE)
	else:
		if plrst.id==SLASHHH and vy < 0:
			pass
		else:
			plrst.goto(JUMP)
