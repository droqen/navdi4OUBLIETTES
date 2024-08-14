extends NavdiSolePlayer

enum { JUMPBUF, FLORBUF, LANDBUF, }
@onready var bufs = Bufs.Make(self).setup_bufons(
	[JUMPBUF,4,FLORBUF,4,LANDBUF,8,]
)

var vx : float = 0.0; var vy : float = 2.5; # maxfall

func _physics_process(_delta: float) -> void:
	var spr = $SheetSprite
	var hang_ray = $hang_ray
	var dpad = Pin.get_dpad()
	var onfloor = vy >= 0 and $mover.cast_fraction(self, $mover/cast, VERTICAL, 1) < 1
	var hanging : bool = vy >= 0 and dpad.x != 0 and $mover.cast_fraction(self, $mover/cast, HORIZONTAL, dpad.x) < 1
	if hanging:
		$hang_ray.target_position.x = 10 * sign(dpad.x)
		$hang_ray.force_raycast_update()
		$hang_ray2.target_position.x = 10 * sign(dpad.x)
		$hang_ray2.force_raycast_update()
		if $hang_ray.is_colliding(): hanging = false
		if not $hang_ray2.is_colliding(): hanging = false
	
	if onfloor: bufs.on(FLORBUF)
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if hanging and bufs.try_eat([JUMPBUF]): vy = -1.3; hanging = false;
	if bufs.try_eat([FLORBUF, JUMPBUF]): vy = -2.0; onfloor = false;
	
	vx = move_toward(vx, dpad.x * 0.750, 0.125)
	if vy < 0 and not Pin.get_jump_held(): vy += 0.08
	if hanging: vy = 0
	else: vy = move_toward(vy, 2.5, 0.08)
	
	if dpad.x: spr.flip_h = dpad.x < 0
	if not $mover.try_slip_move(self, $mover/cast, HORIZONTAL, vx):
		vx = 0
	if not $mover.try_slip_move(self, $mover/cast, VERTICAL, vy):
		if vy > 0.5: bufs.on(LANDBUF)
		if vy > 0: vy = 0
		
	if not onfloor:
		if hanging: spr.setup([6])
		elif vy < -1: spr.setup([13])
		else: spr.setup([14])
	elif bufs.has(LANDBUF): spr.setup([15])
	elif dpad.x:
		if len(spr.frames)==1:
			match spr.frames[0]:
				2: spr.setup([3,2,4,2],8)
				_: spr.setup([2,4,2,3],8)
	else: spr.setup([2])
		
