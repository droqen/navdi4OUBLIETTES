extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, TURNBUF, WINGSBUF, }

var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, JUMPBUF,4, TURNBUF,8, WINGSBUF,20,
])

var airjumps:int=1;
var highestypos:float=999;

@export var eternally_flying : bool = false

@onready var mover = $NavdiBodyMover
@onready var caster= $NavdiBodyMover/ShapeCast2D
@onready var sprite= $SheetSprite

var vx:float;var vy:float;

func _ready() -> void:
	super._ready()
	if eternally_flying:
		highestypos = position.y - 20

func _physics_process(_delta: float) -> void:
	#var room = LiveDream.GetRoom(self)
	#if room and room.name == "rmEternalFlight": eternally_flying = true
	var doflap : bool = false;
	if eternally_flying:
		if vx < 0 and position.x < 5: position.x = 125
		if vx > 0 and position.x >= 125: position.x = 5
	if position.y < highestypos: highestypos = position.y
	elif position.y > highestypos + 12 and vy>=0.0: doflap = true
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]): vy=-1.0
	var tofloor = mover.cast_fraction(self,caster,VERTICAL,1)
	var onfloor : bool = vy>=0 and tofloor<1
	if onfloor: position.y += tofloor; bufs.on(FLORBUF); airjumps=1;
	if not onfloor and (bufs.try_eat([JUMPBUF]) or doflap):
		airjumps-=1; vy=-1.0; bufs.on(WINGSBUF)
	vx = move_toward(vx,dpad.x*0.75,0.15)
	vy = move_toward(vy,2.4,0.04)
	if vx and!mover.try_slip_move(self,caster,HORIZONTAL,vx):
		vx = 0
	if vy and!mover.try_slip_move(self,caster,VERTICAL,vy):
		vy = 0
	if dpad.x and sprite.flip_h!=(dpad.x<0):
		sprite.flip_h=not sprite.flip_h
		bufs.on(TURNBUF)
	if onfloor:
		if dpad.x:
			if len(sprite.frames)<6:
				match sprite.frames[0]:
					13: sprite.setup([14,14,13,15,15,13],5)
					16: sprite.setup([13,14,14,13,15,15],5)
					14,17: sprite.setup([13,15,15,13,14,14],5)
		else:
			if len(sprite.frames)<6:
				sprite.setup([13])
			else: match sprite.frame:
				13,16:
					sprite.setup([13])
	else:
		sprite.setup([17])
	var w = bufs.read(WINGSBUF)
	if w > 0:
		$wings.show()
		var r : float = remap(clamp(w,10,20),10,20,0.0,-0.5)
		$wings/LPIVOT.rotation = -r
		$wings/RPIVOT.rotation = r
		if w < 10 and w % 2 == 1: $wings.hide()
		if w > 15: sprite.setup([18])
	else:
		$wings.hide()
