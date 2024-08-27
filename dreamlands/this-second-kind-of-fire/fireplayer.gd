extends NavdiSolePlayer

enum { FLORBUF, JUMPHITBUF, FLICKERBUF, UPDRAFTBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons(
	[ FLORBUF,4, JUMPHITBUF,4, FLICKERBUF,30, UPDRAFTBUF,4, ]
)

func _ready() -> void:
	super._ready()
	$hit_area.area_entered.connect(func(spikes_area):
		die()
	)

var vx : float; var vy : float; var jumped_normal : bool;
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPHITBUF)
	if vy < 0:
		if not Pin.get_jump_held(): vy += 0.10 # fastfal;
	else: jumped_normal = false
	if bufs.try_eat([JUMPHITBUF,FLORBUF,]): vy=-1.5; jumped_normal = true;
	if bufs.try_eat([UPDRAFTBUF,JUMPHITBUF,]): vy=-1.0; jumped_normal = false;
	for i in range($updraft_caster.get_collision_count()):
		if "fire" in $updraft_caster.get_collider(i).name:
			bufs.on(UPDRAFTBUF); break;
	vx=move_toward(vx,dpad.x,0.1)
	vy=move_toward(vy,2.0,0.05)
	if bufs.has(UPDRAFTBUF):
		if vy > 0: vy *= 0.99
		vy -= 0.01
	if dpad.x: $spr.flip_h=dpad.x<0
	if bufs.has(FLICKERBUF):
		show()
		var f = bufs.read(FLICKERBUF)
		if f > 20 and f % 3 <= 1: hide()
		elif f < 20 and f % 3 > 1: hide()
		if f > 20: vx = 0; vy = 0;
	else:
		show()
	if vx and!$mover.try_slip_move(self,$mover/cast,HORIZONTAL,vx):
		vx = 0
	if vy and!$mover.try_slip_move(self,$mover/cast,VERTICAL,vy):
		vy = 0
	var tofloor:float=$mover.cast_fraction(self,$mover/cast,VERTICAL,1)
	var onfloor:bool=vy>=0 and tofloor<1
	if onfloor:position.y+=tofloor; bufs.on(FLORBUF);

	if onfloor:
		if dpad.x: $spr.setup([26,27,28,25])
		else: $spr.setup([24])
	else:
		if bufs.has(UPDRAFTBUF): $spr.setup([36,37],7)
		else: $spr.setup([25])

func die() -> void:
	var check = LiveDream.GetRoom(self).get_node_or_null(F2FlagCheckpoint.ActiveCheckName)
	if check:
		position = check.position + Vector2.UP * 10
		prints('died with check', F2FlagCheckpoint.ActiveCheckName, ' found @ ',check.position)
		prints('therefore im at',position)
	else:
		prints('died with no check found @', F2FlagCheckpoint.ActiveCheckName)
	vx = 0; vy = 0;
	bufs.on(FLICKERBUF)

func just_died() -> bool:
	return bufs.has(FLICKERBUF)
