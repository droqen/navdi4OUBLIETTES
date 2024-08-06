extends NavdiSolePlayer
var vel : Vector2
var recoverfromflipbuf : int = 0
var recoverfromrunbuf : int = 0
var recoverfromfallbuf : int = 0
@export var wallflying : bool = false
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var floor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
	vel.x = move_toward(vel.x, dpad.x, 0.05)
	vel.y = move_toward(vel.y, 2.05, 0.05)
	if floor and Pin.get_jump_hit(): vel.y = -1.5; floor = false;
	if floor and Pin.get_plant_held(): vel.x *= 0.9;
	if not floor and vel.y > 0:
		$SheetSprite.setup([24,25], 10)
		recoverfromfallbuf = 10
		if dpad.x:
			$SheetSprite.flip_h = (dpad.x < 0)
	else:
		if recoverfromfallbuf > 0:
			$SheetSprite.setup([23])
			recoverfromfallbuf -= 1
		elif dpad.x or not floor:
			if dpad.x and $SheetSprite.flip_h != (dpad.x < 0):
				$SheetSprite.flip_h = (dpad.x < 0)
				recoverfromflipbuf = 10
			if recoverfromflipbuf > 0:
				$SheetSprite.setup([22])
				recoverfromflipbuf -= 1
			else:
				$SheetSprite.setup([12,13,14,15],8)
			recoverfromrunbuf = 10
		elif recoverfromrunbuf > 0:
			$SheetSprite.setup([23])
			recoverfromrunbuf -= 1
		else:
			$SheetSprite.setup([2,3,4,5],13)
		
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x * scale.x):
		if wallflying and dpad.x: vel.y -= 0.1
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y * scale.y):
		vel.y = 0
