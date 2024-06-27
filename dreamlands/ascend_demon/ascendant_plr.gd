extends NavdiSolePlayer

enum {
	FLORBUF = 1000, PINJUMPBUF, PLANTINGBUF, ONWALBUF, DEADBUF,
	GREENUNSTICKBUF,
	PLANT_WHILEBUF = 2000, INAIR_VARVELY,
		ONGROUND_BLINKING, ONGROUND_RUNNING, SPLATTED,
		ONWALL,
}

var greens_triggered : int = 0

var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, PINJUMPBUF,5, PLANTINGBUF,16, ONWALBUF,4, DEADBUF,60,
	GREENUNSTICKBUF,23,
])
var last_onwall : int

var splatted : bool = false # (dead)

const TERMINAL_VELOCITY : float = 2.75

var sprst : TinyState = TinyState.new(ONGROUND_BLINKING, func(_then,now):
	match now:
		PLANT_WHILEBUF: $spr.setup([32])
		ONGROUND_RUNNING:
			if $spr.frame in [0,1]: $spr.setup([2,3,4,5],5)
			else: $spr.setup([4,5,2,3],5)
		ONGROUND_BLINKING: $spr.setup([0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,],9)
		INAIR_VARVELY: pass # update_inair_spr()
		SPLATTED: pass # update_splatted_spr()
		ONWALL: $spr.setup([30,31,30,30,],11)
)

var vel : Vector2
var terminal_velocity : bool

const GRAVITY : float = 0.06
const QUICKFALL_GRAVITY : float = 0.12

func _ready() -> void: super._ready()
func _physics_process(_delta: float) -> void:
	if splatted and not bufs.has(DEADBUF):
		if try_lightningboltme():
			splatted = false; vel.y = -2.0;
		else:
			bufs.on(DEADBUF)
	
	# frame-only values
	var dpad : Vector2
	var onfloor : bool = vel.y >= 0 and $mover.cast_fraction(self,$mover/solidcast,VERTICAL,1.0)<1
	var onwall : int = 0
	var do_planting : bool = bufs.has(PLANTINGBUF)
	if terminal_velocity:
		if vel.y < TERMINAL_VELOCITY: terminal_velocity = false;
	elif vel.y > TERMINAL_VELOCITY:
		terminal_velocity = true; vel.x = 0.0
	var xcontrol : float = 0.02 if terminal_velocity else 0.1
	var do_inputs : bool = (not bufs.has(PLANTINGBUF) and not splatted)
	var jumpheld : bool
	var do_wallclingupdate: bool = true
	var do_velupdate : bool = true
	var do_jumpupdate : bool = true
	var do_sprupdate : bool = true
	if do_planting:
		if vel.y >= 1.5:
			bufs.clr(PLANTINGBUF)
	if do_inputs:
		if onfloor and Pin.get_plant_hit():
			# cancel remainder of inputs
			try_lightningboltme()
		else:
			dpad = Pin.get_dpad()
			if Pin.get_jump_hit(): bufs.on(PINJUMPBUF)
			jumpheld = Pin.get_jump_held()
	if do_wallclingupdate:
		if (
			(dpad.x != 0) and
			(vel.x * dpad.x >= 0) and
			(not onfloor) and
			$mover.cast_fraction( self, $mover/solidcast,
				HORIZONTAL, dpad.x )<1
		):
			onwall = dpad.x
			last_onwall = onwall
			bufs.on(ONWALBUF)
	if do_velupdate:
		vel.x = move_toward(vel.x, 1.0 * dpad.x, 0.1)
		if onwall:
			vel.y = move_toward(vel.y * 0.95, 0.2, 0.02)
		else:
			vel.y = move_toward(vel.y, 3.0, GRAVITY)
		if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, QUICKFALL_GRAVITY)
		if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
			vel.x=0
		if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
			vel.y=0
			if terminal_velocity:
				splat()
	if do_jumpupdate:
		if onwall: if bufs.try_eat([PINJUMPBUF]):
			vel.x = -0.8 * onwall
			vel.y = -1.25
			onwall = 0
			onfloor = false
		if onfloor: bufs.on(FLORBUF)
		if bufs.try_eat([FLORBUF,PINJUMPBUF]):
			vel.y = -1.60
			onfloor = false
		if bufs.try_eat([ONWALBUF,PINJUMPBUF]):
			vel.x = -1.0 * last_onwall
			vel.y = vel.y * 0.5 - 1.25
			onwall = 0
			onfloor = false
	if do_sprupdate:
		var spr : SheetSprite = $spr
		if dpad.x: spr.flip_h = dpad.x < 0
		if splatted:
			sprst.goto(SPLATTED); update_splatted_spr()
		elif bufs.read(PLANTINGBUF) > 3:
			sprst.goto(PLANT_WHILEBUF)
		elif onwall:
			sprst.goto(ONWALL)
		elif onfloor:
			if dpad.x: sprst.goto(ONGROUND_RUNNING)
			else: sprst.goto(ONGROUND_BLINKING)
		else:
			sprst.goto(INAIR_VARVELY); update_inair_spr()

func update_splatted_spr():
	if vel.y <= 0: $spr.setup([9])
	else: $spr.setup([6])
func update_inair_spr():
	if vel.y < 0: $spr.setup([5])
	elif vel.y < 0.5: $spr.setup([2])
	elif vel.y < TERMINAL_VELOCITY: $spr.setup([3])
	else: $spr.setup([7,8],5)
	
func try_lightningboltme() -> bool:
	bufs.on(PLANTINGBUF)
	vel.x = 0.0 # stop in place
	vel.y = -0.8
	var floor_cell = $mazer.find_best_floor_cell_if_any(position, $mover/solidcast.shape)
	var maze : Maze = $mazer.get_maze()
	if floor_cell:
		position.x = lerp(position.x, maze.map_to_center(floor_cell).x, 0.8)
		lightningboltradius(maze, floor_cell + Vector2i.UP)
		return true
	else:
		return false
	#y -= 3
	#while y >= 0:
		#lightningboltcell(maze, Vector2i(x, y))
		#y -= 1

func freezeradius(maze : Maze, cell : Vector2i):
	var snowflake = FREEZEPOP_PFB.instantiate().setup(maze, cell)
	LiveDream.GetDream(self).add_child(snowflake)
	freezecell(maze, cell)
	for r in [1,2]:
		for dx in [-r,0,r]:
			for dy in [-r,0,r]:
				freezecell(maze, cell + Vector2i(dx,dy))

func freezecell(maze : Maze, cell : Vector2i):
	var tid = maze.get_cell_tid(cell)
	if (tid >= 10 and tid < 20) or (tid == 21):
		maze.set_cell_tid(cell, tid+30)

func exploderadius(maze : Maze, cell : Vector2i):
	var boom = BIGEXPLOSION_PFB.instantiate().setup(maze, cell)
	LiveDream.GetDream(self).add_child(boom)
	var x : int = cell.x
	var y : int = cell.y
	for dy in [2,1,0,-1,-2]:
		for dx in [0,-1,1,-2,2]:
			lightningboltcell(maze, Vector2i(x+dx, y+dy), true)

func lightningboltradius(maze : Maze, cell : Vector2i):
	greens_triggered = 0
	var bolt = LIGHTNINGBOLT_PFB.instantiate().setup(maze, cell)
	LiveDream.GetDream(self).add_child(bolt)
	var x : int = cell.x
	var y : int = cell.y
	for dy in [1,0,-1]:
		for dx in [0,-1,1]:
			lightningboltcell(maze, Vector2i(x+dx, y+dy))
	if greens_triggered > 1:
		bufs.on(GREENUNSTICKBUF)

func splat():
	splatted = true; bufs.setmin(DEADBUF, randi_range(60,120))
	terminal_velocity = false
	vel.y = -1.5

func lightningboltcell(maze : Maze, cell : Vector2i, is_explosion : bool = false):
	var playercell = maze.local_to_map(position)
	if cell == playercell and is_explosion:
		splat()
	var tid = maze.get_cell_tid(cell)
	match tid:
		11,12:
			maze.set_cell_tid(cell, 10)
		21:
			maze.set_cell_tid(cell, 20)
		
		13:
			maze.set_cell_tid(cell, 23)
			await get_tree().create_timer(0.25).timeout
			freezeradius(maze, cell)
		15:
			maze.set_cell_tid(cell, 25)
			await get_tree().create_timer(0.15).timeout
			exploderadius(maze, cell)
		16:
			maze.set_cell_tid(cell, 26)
			await get_tree().create_timer(0.10).timeout
			lightningboltradius(maze, cell)
		17:
			if is_explosion:
				maze.set_cell_tid(cell, 27)
			elif not bufs.has(GREENUNSTICKBUF):
				greens_triggered += 1
				await get_tree().create_timer(0.05).timeout
				for dy in [1,0,-1]:
					for dx in [0,-1,1]:
						var cel2 : Vector2i = cell + Vector2i(dx,dy)
						if cel2 == playercell:
							maze.set_cell_tid(cel2, 28)
						elif not maze.is_cell_solid(cel2):
							maze.set_cell_tid(cel2, 18)
		18: maze.set_cell_tid(cell, 28)
		19: maze.set_cell_tid(cell, 29)
		
		40,41,42,43,44,45,46,47,48,49, 51: maze.set_cell_tid(cell, tid-30)

const LIGHTNINGBOLT_PFB = preload("res://dreamlands/ascend_demon/lightningbolt.tscn")
const BIGEXPLOSION_PFB = preload("res://dreamlands/ascend_demon/big_explosion.tscn")
const FREEZEPOP_PFB = preload("res://dreamlands/ascend_demon/freezepop.tscn")
