extends NavdiSolePlayer

@export var skinned : bool = false
var skinned_progression : float = 0.0

enum{JUMPBUF,  FLORBUF,  LANDBUF,  OUCHBUF, }
@onready var bufs = Bufs.Make(self).setup_bufons(
	[JUMPBUF,4,FLORBUF,4,LANDBUF,8,OUCHBUF,8]
)

var vx : float = 0.0; var vy : float = 0.0;
var prevcell : Vector2i
var time_paused : bool = true

func _ready() -> void:
	super._ready()
	if skinned and SaintsTransgressions.transgressions == 0:
		skinned = false
		LiveDream.GetDream(self).windfish_awakened.emit()

func _physics_process(_delta: float) -> void:
	
	#if Pin.get_plant_held():
		#$score.show()
		#@warning_ignore("integer_division")
		#$score.text = "%d" % SaintsTransgressions.transgressions
		#$SheetSprite.hide()
		#if skinned: $skinless.hide()
		##time_paused = true
		##return
	#elif $score.visible:
		#$score.hide()
		#$SheetSprite.show()
	
	if time_paused:
		if not skinned and (vx or vx):
			time_paused = false
	else:
		SaintsTransgressions.time += 1
	
	if bufs.read(OUCHBUF) % 2 == 1: return
	
	if skinned:
		if skinned_progression < 1:
			skinned_progression += 0.002
			if skinned_progression >= 1:
				LiveDream.GetDream(self).windfish_awakened.emit()
	else:
		var room = LiveDream.GetRoom(self)
		if room:
			var maze = LiveDream.GetRoom(self).maze
			if maze:
				var curcell = maze.local_to_map(position)
				if curcell != prevcell:
					if maze.get_cell_tid(curcell) == 12:
						bufs.on(OUCHBUF)
						SaintsTransgressions.transgressions += 1
					prevcell = curcell
	var spr = $SheetSprite
	var hang_ray = $hang_ray
	var dpad = Pin.get_dpad()
	var onfloor = vy >= 0 and $mover.cast_fraction(self, $mover/cast, VERTICAL, 1) < 1
	var hanging : bool = vy >= 0 and dpad.x != 0 and $mover.cast_fraction(self, $mover/cast, HORIZONTAL, dpad.x) < 1
	if hanging:
		$hang_ray.target_position.x = 10 * sign(dpad.x)
		$hang_ray.force_raycast_update()
		$hang_ray2.target_position.x = 10 * sign(dpad.x)
		$hang_ray2.force_raycast_update()
		if $hang_ray.is_colliding(): hanging = false
		if not $hang_ray2.is_colliding(): hanging = false
	
	if onfloor: bufs.on(FLORBUF)
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if hanging and bufs.try_eat([JUMPBUF]): vy = -1.3; hanging = false;
	if bufs.try_eat([FLORBUF, JUMPBUF]): vy = -2.0; onfloor = false;
	
	vx = move_toward(vx, dpad.x * 0.750, 0.125)
	if vy < 0 and not Pin.get_jump_held(): vy += 0.08
	if hanging: vy = 0
	else: vy = move_toward(vy, 2.5, 0.08)
	
	if dpad.x: spr.flip_h = dpad.x < 0
	if not $mover.try_slip_move(self, $mover/cast, HORIZONTAL, vx):
		vx = 0
	if not $mover.try_slip_move(self, $mover/cast, VERTICAL, vy):
		if vy > 0.5: bufs.on(LANDBUF)
		if vy > 0: vy = 0
		
	if bufs.has(OUCHBUF): spr.setup([16])
	elif not onfloor:
		if hanging: spr.setup([6])
		elif vy < -1: spr.setup([13])
		else: spr.setup([14])
	elif bufs.has(LANDBUF): spr.setup([15])
	elif dpad.x:
		if len(spr.frames)==1:
			match spr.frames[0]:
				2: spr.setup([3,2,4,2],8)
				_: spr.setup([2,4,2,3],8)
	else: spr.setup([2])
	
	if skinned:
		if skinned_progression < randf():
			$SheetSprite.show(); $skinless.hide();
		else:
			$SheetSprite.hide(); $skinless.show();
			$score.hide();
