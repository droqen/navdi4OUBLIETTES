extends Node2D
var vx:float;var vy:float;
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	vx = dpad.x; vy = dpad.y;
	if vx and!$NavdiBodyMover.try_slip_move(self,
	$NavdiBodyMover/ShapeCast2D, HORIZONTAL, vx):
		vx = 0
	if vy and!$NavdiBodyMover.try_slip_move(self,
	$NavdiBodyMover/ShapeCast2D, VERTICAL, vy):
		vy = 0
