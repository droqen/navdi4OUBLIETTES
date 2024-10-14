extends RigidBody2D

enum { JUMPBUF=1, FLORBUF, }
var bufs = Bufs.Make(self).setup_bufons([
	JUMPBUF,4,FLORBUF,4,
])

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if linear_velocity.y>=0 and $floorcast.is_colliding():
		bufs.on(FLORBUF)
	if linear_velocity.y<0 and not Pin.get_jump_held():
		gravity_scale = 0.30
	else:
		gravity_scale = 0.10
	linear_velocity.x = move_toward(
		linear_velocity.x, dpad.x * 50, 7)
	angular_velocity = -rotation
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		linear_velocity.y = -70 # jumpspd
	if dpad.x:
		$spr.flip_h = dpad.x < 0
	if bufs.has(FLORBUF):
		if dpad.x: $spr.setup([11,12,13,14],8)
		else: $spr.setup([10])
	else:
		$spr.setup([13])
	
	var newpos = Vector2(
		fposmod(position.x, 180),
		fposmod(position.y, 200)
	)
	if newpos!=position:
		var p = get_parent()
		p.remove_child(self)
		position = newpos
		p.add_child(self)
