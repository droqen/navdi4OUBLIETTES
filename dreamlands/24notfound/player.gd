extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, }

enum { ORNG=30, BEIG=10, PRPL=60, ROUG=50, BLCK=80, }

var myBodyId = BEIG # default

var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4,
	JUMPBUF,4,
])

var vx:float;var vy:float

func _physics_process(_delta: float) -> void:
	if Pin.get_jump_hit():
		if myBodyId != BLCK: vy = -1.0
	var onfloor : bool = vy >= 0.0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1 
	if onfloor : bufs.on(FLORBUF)
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -1.0; onfloor = false;
	if Pin.get_jump_hit():
		if myBodyId == BLCK: bufs.on(JUMPBUF)
	vx = Pin.get_dpad().x * 0.5
	vy = move_toward(vy, 1.0, 0.04)
	if vx and !$mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vx):
		vx = 0
	if vy and !$mover.try_slip_move(self, $mover/solidcast, VERTICAL, vy):
		vy = 0
		
	if vx != 0: $spr.flip_h = vx < 0
	if vx != 0 or !onfloor: $spr.setup([myBodyId+1,myBodyId],15)
	else: $spr.setup([myBodyId])
	
	var body_areas = $bodychangezn.get_overlapping_areas()
	for ba in body_areas:
		match ba.name:
			"orng": myBodyId = ORNG
			"beig": myBodyId = BEIG
			"prpl": myBodyId = PRPL
			"blck": myBodyId = BLCK
			"roug": myBodyId = ROUG
			_: prints("unknown baname",ba.name,ba)