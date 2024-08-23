extends NavdiSolePlayer

enum{
	FLORBUF,JUMPHITBUF,ONWALLBUF,SLASHINGBUF,TUMBLINGBUF,FREEZE_IN_AIR_BUF,
	TUMBLINGAIRJUMPBUF,
	STRIKINGBUF,
	IDLE,WALK,AIR,AIRSLASH,TUMBLING}
var bufs:Bufs=Bufs.Make(self).setup_bufons(
	[FLORBUF,4,JUMPHITBUF,4,ONWALLBUF,4,
	SLASHINGBUF,100,TUMBLINGBUF,40,TUMBLINGAIRJUMPBUF,48,
	FREEZE_IN_AIR_BUF,8,STRIKINGBUF,4]
)
var v:Vector2;
var airslashes:int=0;
@onready var spr:SheetSprite = $spr;
@onready var mover:NavdiBodyMover = $mover
@onready var caster:ShapeCast2D = $mover/solidcast

func take_damage():
	airslashes = 0
	v.x = 1 if spr.flip_h else -1
	bufs.bufdic.clear() # clear all bufs

func _ready() -> void:
	super._ready()
	$hbox.area_entered.connect(func(hit_area):
		if bufs.has(STRIKINGBUF):
			hit_area.get_parent().take_damage() # ha ha eat it
			bufs.on(FREEZE_IN_AIR_BUF)
		else:
			take_damage() # ouch
	)

func _physics_process(_delta: float) -> void:
	var dpad=Pin.get_dpad()
	if Pin.get_jump_hit():bufs.on(JUMPHITBUF)
	var tofloor=mover.cast_fraction(self,caster,VERTICAL,1)
	var onfloor:bool=false
	if v.y>=0 and tofloor<1:
		position.y+=tofloor
		onfloor=true
		airslashes=1
	if bufs.try_eat([FLORBUF,JUMPHITBUF]):onfloor=false;v.y=-1.0
	if not onfloor and airslashes>0 and bufs.try_eat([JUMPHITBUF]):
		airslashes-=1
		v.y = v.y * 0.5 - 0.5
		if dpad.x < 0: v.x = min(v.x, -0.5)
		if dpad.x > 0: v.x = max(v.x,  0.5)
		if v.y > 0: v.y = 0
		v = v.normalized() * 2.7
		if v == Vector2.ZERO:
			v = Vector2(-2.7 if spr.flip_h else 2.7, 0)
		bufs.on(SLASHINGBUF)
		bufs.on(FREEZE_IN_AIR_BUF)
		if v.x: spr.flip_h = v.x < 0
	if onfloor:bufs.on(FLORBUF)
	
	if bufs.has(FREEZE_IN_AIR_BUF):
		pass
	else:
		if v.x and!mover.try_slip_move(self,caster,HORIZONTAL,v.x):
			if bufs.has(TUMBLINGBUF):
				v.y -= 0.05
				v.y = lerp(v.y, clamp(v.y,-2.0,-1.0), 0.5)
			if bufs.has(SLASHINGBUF):
				bufs.on(TUMBLINGBUF)
				bufs.on(TUMBLINGAIRJUMPBUF)
				bufs.clr(SLASHINGBUF)
			v.x = 0
		if v.y and!mover.try_slip_move(self,caster,VERTICAL,v.y):
			if bufs.has(SLASHINGBUF):
				bufs.on(TUMBLINGBUF)
				bufs.on(TUMBLINGAIRJUMPBUF)
				bufs.clr(SLASHINGBUF)
			v.y = 0
	
	if bufs.has(SLASHINGBUF):
		var slash : int = bufs.read(SLASHINGBUF)
		var speed : float = v.length()
		if slash > 96: spr.setup([50])
		elif slash > 92: spr.setup([51])
		elif speed > 1.0:
			bufs.on(STRIKINGBUF)
			spr.setup([54,55],2)
			v *= 0.975
			v.y *= 0.99
		elif speed > 0.1 and abs(v.x) > 0.1:
			spr.setup([56,56,56,56,55,56,56,56,56,56,56,55,],2)
			v *= 0.95
			v.y += 0.03
		else:
			bufs.clr(SLASHINGBUF)
		#if bufs.read(SLASHINGBUF)>96: spr.setu
		#spr.setup([61,62,63,64],8)
	elif bufs.has(TUMBLINGBUF):
		if onfloor:
			var speed : float = v.length()
			if speed < 0.1:
				bufs.clr(TUMBLINGBUF)
				bufs.clr(TUMBLINGAIRJUMPBUF)
				bufs.setmin(TUMBLINGAIRJUMPBUF, 8)
		spr.setup([61,62,63,64],8)
		#v *= 0.975
		#v.y += 0.03
		if v.x: spr.flip_h = v.x < 0
		v.x=move_toward(v.x,dpad.x*0.9,0.09)
		v.y=move_toward(v.y,1.5,0.04)
	else:
		if dpad.x: spr.flip_h = dpad.x < 0
		v.x=move_toward(v.x,dpad.x*0.9,0.09)
		v.y=move_toward(v.y,1.5,0.04)
		if onfloor:
			if dpad.x:
				spr.setup([40,41,42,40],4)
			else:
				spr.setup([30])
		else:
			if airslashes > 0:
				spr.setup([31])
			else:
				spr.setup([71,70,71,71,71,71,71,71,],4)

	if bufs.try_eat([JUMPHITBUF,TUMBLINGAIRJUMPBUF]):
		if v.y > -0.5: v.y = -0.5
		else: v.y -= 1.0
		bufs.clr(TUMBLINGBUF)
