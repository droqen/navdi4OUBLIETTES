extends NavdiSolePlayer

@export var spawn_tumbling : bool = false

enum{
	FLORBUF,JUMPHITBUF,ONWALLBUF,SLASHINGBUF,TUMBLINGBUF,FREEZE_IN_AIR_BUF,
	TUMBLINGAIRJUMPBUF,
	STRIKINGBUF,
	HURTINVINCBUF,HURTSTUNBUF,JUST_STARTED_TUMBLING_BUF,
	RECENTLY_INVINC_BUF,
	IDLE,WALK,AIR,AIRSLASH,TUMBLING}
var bufs:Bufs=Bufs.Make(self).setup_bufons([
	FLORBUF,4,JUMPHITBUF,4,ONWALLBUF,4,
	SLASHINGBUF,100,TUMBLINGBUF,40,TUMBLINGAIRJUMPBUF,48,
	FREEZE_IN_AIR_BUF,8,STRIKINGBUF,4,
	HURTSTUNBUF,30,HURTINVINCBUF,40,JUST_STARTED_TUMBLING_BUF,2,
])
var last_safe_xpos:float;
var v:Vector2;
var airslashes:int=0;
@onready var spr:SheetSprite = $spr;
@onready var mover:NavdiBodyMover = $mover
@onready var caster:ShapeCast2D = $mover/solidcast

func take_damage():
	airslashes = 0
	#if v.x: spr.flip_h = v.x < 0
	# knock player towards last safe position!
	var kb_dir : float = -1 if (last_safe_xpos<position.x) else 1
	if v.x * kb_dir < 0: v.x = 0
	v.x *= 0.75
	v.x += kb_dir * 1
	spr.flip_h = -v.x < 0
	v.y = -1
	bufs.bufdic.clear() # clear all bufs
	bufs.on(HURTSTUNBUF)
	bufs.on(HURTINVINCBUF)
	bufs.setmin(RECENTLY_INVINC_BUF, bufs.read(HURTINVINCBUF)+2)

func _ready() -> void:
	super._ready()
	$hbox.area_entered.connect(func(hit_area):take_damage())
	$hbox.body_entered.connect(func(hit_body):take_damage())
	$slashbox.area_entered.connect(func(hit_area):
		if bufs.has(STRIKINGBUF):
			hit_area.get_parent().take_damage() # ha ha eat it
			bufs.setmin(SLASHINGBUF,50)
			v = v.normalized()
			if airslashes < 1 : airslashes = 1
			bufs.on(FREEZE_IN_AIR_BUF)
	)
	travelled_dir.connect(func(travel_dir:Vector2i):
		last_safe_xpos -= travel_dir.x * 250
	)
	
	if spawn_tumbling:
		v.y = 1
		bufs.on(TUMBLING)


func _physics_process(_delta: float) -> void:
	var dpad=Pin.get_dpad()
	if bufs.has(HURTSTUNBUF): dpad.x = 0
	if Pin.get_jump_hit():bufs.on(JUMPHITBUF)
	var tofloor=mover.cast_fraction(self,caster,VERTICAL,1)
	var onfloor:bool=false
	if bufs.has(HURTINVINCBUF): bufs.setmin(RECENTLY_INVINC_BUF, 2)
	if v.y>=0 and tofloor<1:
		position.y+=tofloor
		onfloor=true
		airslashes=1
		if not bufs.has(RECENTLY_INVINC_BUF):
			last_safe_xpos=position.x
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
				if v.y > 0.1:
					v.x *= -1.5
					v.y = -0.5
				else:
					v.x = 0
					v.y -= 0.05
					v.y = lerp(v.y, clamp(v.y,-2.0,-1.0), 0.5)
			else:
				v.x = 0
			if bufs.has(SLASHINGBUF):
				bufs.on(TUMBLINGBUF)
				bufs.on(TUMBLINGAIRJUMPBUF)
				bufs.on(JUST_STARTED_TUMBLING_BUF)
				bufs.clr(SLASHINGBUF)
		if v.y and!mover.try_slip_move(self,caster,VERTICAL,v.y):
			if bufs.has(TUMBLINGBUF) and v.y > 0.5:
				v.y *= -0.5
				bufs.on(TUMBLINGBUF) # reset dat
				bufs.on(TUMBLINGAIRJUMPBUF) # reset dat
				#bufs.on(JUST_STARTED_TUMBLING_BUF)
			else:
				v.y = 0
			if bufs.has(SLASHINGBUF):
				bufs.on(TUMBLINGBUF)
				bufs.on(TUMBLINGAIRJUMPBUF)
				#bufs.on(JUST_STARTED_TUMBLING_BUF)
				bufs.clr(SLASHINGBUF)
	
	if bufs.has(HURTSTUNBUF):
		# no inputs
		v.y += 0.05
		spr.setup([73,74],5)
	elif bufs.has(SLASHINGBUF):
		var slash : int = bufs.read(SLASHINGBUF)
		var speed : float = v.length()
		if slash >= 99: spr.setup([72])
		elif slash > 96: spr.setup([50])
		elif slash > 92: spr.setup([51])
		elif speed > 1.0:
			bufs.on(STRIKINGBUF)
			spr.setup([54,55],2)
			v *= 0.975
			v.y *= 0.99
		elif speed > 0.1 and abs(v.x) > 0.1:
			if airslashes > 0:
				spr.setup([55])
			else:
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
		var tumblingframesleft = bufs.read(TUMBLINGBUF) # 40-0
		if tumblingframesleft > 20:
			spr.setup([61,62,63,64],4)
		else:
			spr.setup([61,62,63,64],8)
		#v *= 0.975
		#v.y += 0.03
		if v.y > 0: # falling - worse control
			v.x=move_toward(v.x,dpad.x*0.9,0.02)
		else: # rising - better control
			v.x=move_toward(v.x,dpad.x*0.9,0.09)
			if v.x: spr.flip_h = v.x < 0
		if v.y < 1.5: v.y += 0.04
	else:
		if dpad.x: spr.flip_h = dpad.x < 0
		v.x=move_toward(v.x,dpad.x*0.9,0.09)
		if v.y < 1.5: v.y += 0.04
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

	if (
		not bufs.has(JUST_STARTED_TUMBLING_BUF)
		and bufs.try_eat([JUMPHITBUF,TUMBLINGAIRJUMPBUF])
	):
		if v.y > -0.5: v.y = -0.5
		else: v.y -= 1.0
		bufs.clr(TUMBLINGBUF)
	
	if Pin.get_plant_hit():
		if onfloor:
			onfloor=false
			bufs.on(TUMBLINGBUF)
			bufs.on(TUMBLINGAIRJUMPBUF)
			bufs.on(JUST_STARTED_TUMBLING_BUF)
			v.x=-1.65 if spr.flip_h else 1.65
		else:
			bufs.on(TUMBLINGBUF)
			bufs.on(TUMBLINGAIRJUMPBUF)
			bufs.on(JUST_STARTED_TUMBLING_BUF)
			bufs.clr(SLASHINGBUF)
			bufs.clr(STRIKINGBUF)
			v.x=-1.25 if spr.flip_h else 1.25
			if v.y < 0.50: v.y = 0.50
			v.y += 0.75
	
	match bufs.read(STRIKINGBUF):
		4: $slashbox/shape.disabled = false; $slashbox.position.x = -3 if spr.flip_h else 3;
		0: $slashbox/shape.disabled = true
	if bufs.has(TUMBLINGBUF) and not bufs.has(JUST_STARTED_TUMBLING_BUF):
		bufs.setmin(HURTINVINCBUF,3)
	$hbox/CollisionShape2D.disabled = bufs.has(HURTINVINCBUF) and not bufs.has(JUST_STARTED_TUMBLING_BUF)
	
	if bufs.read(HURTINVINCBUF) % 5 > 3: hide()
	else: show()
