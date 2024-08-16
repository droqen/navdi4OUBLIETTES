extends NavdiSolePlayer

var vx : float; var vy : float;

func _physics_process(_delta: float) -> void:
	var dpad : Vector2i; var jump : bool; var jumpheld : bool;
	dpad = Pin.get_dpad();
	jump = Pin.get_jump_hit();
	jumpheld = Pin.get_jump_held();
	var mover : NavdiBodyMover = $mover;
	var solidcast : ShapeCast2D = $mover/solidcast;
	var spr : SheetSprite = $spr;
	vx = move_toward(vx, dpad.x * 1.2, 0.2)
	vy = move_toward(vy, 3.0, 0.08)
	if dpad.x: spr.flip_h = dpad.x < 0
	if not mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		vx = 0
	if not mover.try_slip_move(self, solidcast, VERTICAL, vy):
		vy = 0
