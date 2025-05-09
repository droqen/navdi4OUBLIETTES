extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF }
@onready var bufs = Bufs.Make(self).setup_bufons([FLORBUF,4,JUMPBUF,4,])
@export var flying_falling_lover : bool = false
@export var starting_vy : float
var faceleft : bool
var vx : float
var vy : float
func _ready() -> void:
	super._ready()
	vy = starting_vy
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit():
		bufs.on(JUMPBUF)
	if flying_falling_lover:
		vx *= 0.95
		vx = move_toward(vx,dpad.x,0.05)
		if vx != 0: faceleft = vx < 0; $spr.flip_h = faceleft;
		if vy < 0:
			vy += 0.006 * (140-position.y) / 140
		else:
			vy += 0.006
			if position.y > 175:
				escape(0)
	else:
		vx = move_toward(vx,dpad.x,0.5)
		if dpad.x != 0: faceleft = dpad.x < 0; $spr.flip_h = faceleft;
		vy = move_toward(vy,4.0,0.17) #default gravity
	var onfloor : bool = vy>=0 and $mover.cast_fraction(self, $mover/cast, VERTICAL, 1)<1
	if onfloor:
		bufs.on(FLORBUF)
	if bufs.try_eat([FLORBUF,JUMPBUF]):
		vy = -2.7
	if!$mover.try_slip_move(self, $mover/cast, HORIZONTAL, vx):
		vx = 0
	if!$mover.try_slip_move(self, $mover/cast, VERTICAL, vy):
		vy = 0
	
	if onfloor:
		if dpad.x:
			if len($spr.frames)!=4:
				match $spr.frame:
					16:
						$spr.setup([15,12,13,14],5)
					_:
						$spr.setup([12,13,14,15],5)
		else:
			$spr.setup([11])
	else:
		$spr.setup([16])
