extends NavdiSolePlayer

enum {TURNBUF=1, }
var bufs:Bufs = Bufs.Make(self).setup_bufons([
	TURNBUF,7,
])
var faceleft:bool

var vx:float;var vy:float;
func _physics_process(_delta: float) -> void:
			
	var dpad = Pin.get_dpad()
	vx = move_toward(vx,dpad.x*0.8,0.1)
	if vx and!$mover.try_slip_move(self, $mover/scast, HORIZONTAL, vx):
		vx=0;
	if vy and!$mover.try_slip_move(self, $mover/scast, VERTICAL, vy):
		vy=0;
	if vy > 0: vy *= 0.98
	if Pin.get_jump_held():
		vy = move_toward(vy, 0.5, 0.01)
	else:
		vy = move_toward(vy, 1.2, 0.03)
	if Pin.get_jump_hit():
		
		if "Sky" in LiveDream.GetRoom(self).name:
			vy = min(vy, -1.0 + 0.005 * (250-position.y))
		else:
			vy = -1.0
	if randf() < 0.01: $bubblecontainer/bubble.position = Vector2(
		round((position.x+randf()*5)/5)*5,
		round(position.y/5)*5
	)
	$bubblecontainer/bubble.position.x += (randf()-randf())*0.2
	$bubblecontainer/bubble.position.y -= randf()*0.2
	if dpad.x and (dpad.x<0!=faceleft):
		faceleft=!faceleft
		bufs.on(TURNBUF)
		$SheetSprite.flip_h = faceleft
	if bufs.has(TURNBUF):
		$SheetSprite.setup([12],32)
	elif vy < 0:
		$SheetSprite.setup([11])
	else:
		$SheetSprite.setup([10,11],32)
