extends NavdiSolePlayer

enum {FLORBUF=1,JUMPBUF,LANDBUF,WALKBUF,}
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, JUMPBUF,4, LANDBUF,4, WALKBUF,30,
])
var vx:float; var vy:float;
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if dpad.x: bufs.on(WALKBUF)
	vx=move_toward(vx,dpad.x*1.0,0.2)
	vy=move_toward(vy,1.9,0.05)
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]): vy=-1.4
	elif bufs.try_eat([JUMPBUF]): vy=-0.9
	if vy>=0 and $mover.cast_fraction(self,$mover/solidc,VERTICAL,1)<1:
		if not bufs.has(FLORBUF): bufs.on(LANDBUF); $feet.ani_index=0
		bufs.on(FLORBUF)
	
	if vx and!$mover.try_slip_move(self,$mover/solidc,HORIZONTAL,vx):
		vx=0
	if vy and!$mover.try_slip_move(self,$mover/solidc,VERTICAL,vy):
		vy=0
	
	if bufs.has(LANDBUF): $head.position.y = 1
	else: $head.position.y = 0
	
	if dpad.x:
		$feet.flip_h = dpad.x < 0
		$head.flip_h = dpad.x < 0
	
	if !bufs.has(FLORBUF) or dpad.x!=0 or $feet.frame != 22:
		$feet.playing = true
		if bufs.has(FLORBUF) and vx == 0:
			$feet.playing = false
			if bufs.read(WALKBUF)==1: vy=-0.5
		if !bufs.has(FLORBUF) and (vy >= 0 or vx == 0) and $feet.frame != 22:
			$feet.playing = false
	else:
		$feet.playing = false
		$feet.ani_subindex = 4
