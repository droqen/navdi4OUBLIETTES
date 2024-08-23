extends NavdiSolePlayer
enum{
	FLORBUF,JUMPHITBUF,SLASHSTARTBUF,ONWALLBUF,
	IDLE,WALK,JUMP,SWORDDASH,SLASHHH,TUMBLING,WALLSLIDE,}
var bufs:Bufs=Bufs.Make(self).setup_bufons(
	[FLORBUF,4,JUMPHITBUF,4,ONWALLBUF,4,]
)
var sworddash_dir : int = 0
var sworddash_chg : int = 0
var wallslide_dir : int = 0
@onready var spr:SheetSprite = $spr;
@onready var mover:NavdiBodyMover = $mover
@onready var caster:ShapeCast2D = $mover/solidcast
@onready var plrst:TinyState=TinyState.new(IDLE,func(_then,now):
	if now != SLASHHH:
		$sword_sprite.hide()
		$sword_area/shape.disabled = true
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
			spr.setup([50,51,51],3)
			bufs.setmin(SLASHSTARTBUF,6)
			#$sword_sprite.show()
			#$sword_sprite.flip_h = spr.flip_h
			#$sword_sprite.position.x = -2 if spr.flip_h else 2
			$sword_area.position.x = -4 if spr.flip_h else 4
			$sword_area/shape.disabled = false
		WALLSLIDE:
			spr.setup([60])
		TUMBLING:
			spr.setup([61,62,63,64],8)
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
	var onwall_dir : int = dpad.x
	if not onwall_dir and plrst.id == WALLSLIDE: onwall_dir = wallslide_dir
	if mover.cast_fraction(self,caster,HORIZONTAL,onwall_dir) >= 1:
		onwall_dir = 0
	if onwall_dir != 0: bufs.on(ONWALLBUF)
	if !onfloor and plrst.id!=TUMBLING and bufs.try_eat([ONWALLBUF,JUMPHITBUF]):
		plrst.goto(TUMBLING)
		if vy > 0: vy = 0
		vy -= 1.5
		vx = -1.0 * onwall_dir
		onwall_dir = 0
	match plrst.id:
		SWORDDASH:
			sworddash_chg += 1
			var p : float = sworddash_chg * 0.01
			if sworddash_chg<30:
				spr.setup([43,44,45,46,46],8)
				p = 0.0
			else:
				spr.setup([41,42,40,40],4)
				
			if (
				not onfloor
				or bufs.try_eat([JUMPHITBUF])
				or not pin_dashheld
				or p >= 1.0
				or mover.cast_fraction(self,caster,HORIZONTAL,sworddash_dir)<1 # hit a wall
			):
				onfloor = false
				if p>0:
					vx = lerp(1.2,2.0,p) * dpad.x # heel turn
					vy = -lerp(1.0,1.6,p) # big jump
					plrst.goto(SLASHHH) # slash requires minimum 20 chg
			else:
				if p>0:
					vx=move_toward(vx,lerp(1.2,2.0,p)*sworddash_dir,0.2)
				else:
					if dpad.x: spr.flip_h=dpad.x<0; sworddash_dir=signi(dpad.x);
				vy=move_toward(vy,0.0,0.035)
		TUMBLING:
			if vx: spr.flip_h = vx < 0
			#else: plrst.goto(JUMP)
			# else: no automatic friction at all
			if bufs.try_eat([FLORBUF,JUMPHITBUF]):
				onfloor = false;
				vy = -(1.0 + 0.2 * abs(vx));
				vx *= 0.5
				plrst.goto(JUMP);
			if onfloor:
				if sign(vx) == sign(dpad.x): vx *= 0.991
				elif dpad.x == 0: vx *= 0.95
				else: vx *= 0.8 # negative - intentional stopslow
				if abs(vx) <= 0.5: plrst.goto(JUMP); vy = -0.5
			else:
				if dpad.x: vx=move_toward(vx,(sign(vx)*0.6 + dpad.x*0.4),0.08)
				vy=move_toward(vy,2.0,0.065)
		SLASHHH:
			vx=move_toward(vx,(dpad.x+sworddash_dir)*0.5,0.02)
			vy=move_toward(vy,2.0,0.035)
			if vy > 0:
				plrst.goto(JUMP)
			elif vy > -0.25:
				spr.setup([55])
				if onwall_dir != 0: plrst.goto(WALLSLIDE)
			elif not bufs.has(SLASHSTARTBUF):
				spr.setup([54,55],2)
		_:
			if bufs.try_eat([FLORBUF,JUMPHITBUF]):
				onfloor = false; vy = -0.9
			vx=move_toward(vx,dpad.x*0.7,0.05)
			vy=move_toward(vy,2.0,0.035)
			if dpad.x:spr.flip_h=dpad.x<0;
	if vx and!mover.try_slip_move(self,caster,HORIZONTAL,vx):
		if plrst.id == TUMBLING:
			vx*=-0.5
			if abs(vx)>0.3:
				if vy > 0: vy = 0
				vy-=0.5
		else:
			vx=0
	if vy and!mover.try_slip_move(self,caster,VERTICAL,vy):
		if plrst.id == TUMBLING and vy>0.5: vx *= 1.5
		vy=0
	
	if onwall_dir != 0 and plrst.id in [JUMP,WALLSLIDE]:
		plrst.goto(WALLSLIDE)
		wallslide_dir = onwall_dir
	elif onfloor:
		if plrst.id == TUMBLING: pass
		elif pin_dashheld: plrst.goto(SWORDDASH)
		elif dpad.x: plrst.goto(WALK)
		else: plrst.goto(IDLE)
	else:
		if plrst.id==TUMBLING:
			pass
		elif plrst.id==SLASHHH and vy < 0:
			pass
		else:
			plrst.goto(JUMP)
