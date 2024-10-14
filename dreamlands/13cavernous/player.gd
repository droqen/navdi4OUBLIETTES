extends NavdiSolePlayerRigid

enum { JUMPBUF=1, FLORBUF, TURNBUF, }
var bufs = Bufs.Make(self).setup_bufons([
	JUMPBUF,4,FLORBUF,4,TURNBUF,8,
])

var crouch : bool = false

@onready var lastfrmpos : Vector2 = position

func _physics_process(_delta: float) -> void:
	if lastfrmpos.distance_to(position) > 5:
		var p = get_parent()
		p.remove_child(self)
		p.add_child(self)
	lastfrmpos = position
	
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		linear_velocity.y = -70 # jumpspd
	if linear_velocity.y>=0 and $floorcast.is_colliding():
		bufs.on(FLORBUF)
	if bufs.has(FLORBUF) and not dpad.x and Pin.get_plant_hit():
		crouch = true
	if crouch and (not bufs.has(FLORBUF) or dpad.x):
		crouch = false
	if linear_velocity.y<0 and not Pin.get_jump_held():
		gravity_scale = 0.30
	else:
		gravity_scale = 0.10
	linear_velocity.x = move_toward(
		linear_velocity.x, dpad.x * 50, 7)
	angular_velocity = -rotation
	if dpad.x:
		if $spr.flip_h != (dpad.x < 0):
			$spr.flip_h = dpad.x < 0
			bufs.on(TURNBUF)
	if bufs.has(FLORBUF):
		if crouch: $spr.setup([22])
		elif bufs.has(TURNBUF): $spr.setup([21])
		elif dpad.x: $spr.setup([11,12,13,14],8)
		else: $spr.setup([10,20],60)
	else:
		$spr.setup([13])
	
	#var newpos = Vector2(
		#fposmod(position.x, 180),
		#fposmod(position.y, 200)
	#)
	#if newpos!=position:
		#var p = get_parent()
		#p.remove_child(self)
		#position = newpos
		#p.add_child(self)
