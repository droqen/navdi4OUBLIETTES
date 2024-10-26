extends NavdiSolePlayer

var vx:float;var vy:float;
func _physics_process(_delta: float) -> void:
	var mover = $NavdiBodyMover
	var castr = $NavdiBodyMover/ShapeCast2D
	vx = Pin.get_dpad().x
	if Pin.get_jump_hit(): vy = -1.0
	if vy < 1.0: vy += 0.1
	if vx and!mover.try_slip_move(self,castr,HORIZONTAL,vx):
		vx = 0
	if vy and!mover.try_slip_move(self,castr,VERTICAL,vy):
		vy = 0
