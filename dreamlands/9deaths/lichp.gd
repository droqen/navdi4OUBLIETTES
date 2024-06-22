extends NavdiSolePlayer

enum { FLORBUF, PINJUMPBUF, PLANTEDBUF, }

signal touched_sparkles

var vel : Vector2 # velocity
var onfloor : bool
var onwall : int = 0 # -1 : left, 1 : right
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4,
	PINJUMPBUF,4,
	PLANTEDBUF,8,
])

func _physics_process(_delta: float) -> void:
	var x_movement_speed : float = 1.0
	var flor_jump_power : float = 1.4
	var wall_jump_power : float = 1.4
	
	var dpad : Vector2i
	var jumpheld : bool
	var plantaction : bool
	
	if bufs.has(PLANTEDBUF):
		pass # skip all inputs
	else:
		dpad = Vector2i(
			(1 if Input.is_action_pressed("right") else 0)
			-(1 if Input.is_action_pressed("left") else 0),
			0
		)
		if Input.is_action_just_pressed("jump"): bufs.on(PINJUMPBUF)
		jumpheld = Input.is_action_pressed("jump")
		plantaction = Input.is_action_just_pressed("plant")

	if dpad.x:
		$SheetSprite.flip_h = (dpad.x < 0)
	
	var prev_onfloor = onfloor
	onfloor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1

	if onfloor:
		bufs.on(FLORBUF)
	
	onwall = 0
	if dpad.x and $mover.cast_fraction(self, $mover/solidcast, HORIZONTAL, sign(dpad.x)) < 1:
		if vel.y >= -1.0:
			onwall = sign(dpad.x)
	
	if prev_onfloor and not onfloor:
		vel.y = 0.0; position.y -= 0.5; # dont drop
		#vel.x *= 0.75; position.y += 0.5 # drop
	
	if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, 0.07)
	
	vel.x = move_toward(vel.x, dpad.x*x_movement_speed, 0.3)
	if onwall:
		vel.y = move_toward(vel.y, 0.2, 0.05)
	else:
		vel.y = move_toward(vel.y, 2.0, 0.05)
	var free_space_overhead : bool = $mover.cast_fraction(self, $mover/solidcast, VERTICAL, -1.5) >= 1

	if free_space_overhead:
		if onwall and bufs.try_eat([PINJUMPBUF]):
			vel.x = onwall * -1.5
			vel.y = min(vel.y, -wall_jump_power) # infinite walljumps
			bufs.clr(FLORBUF)
			onfloor = false
		elif bufs.try_eat([FLORBUF, PINJUMPBUF]):
			if dpad.x: vel.x = lerp(vel.x, dpad.x*1.0, 0.4)
			vel.y = -flor_jump_power
			onfloor = false
	
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	
	if onfloor and plantaction:
		interact_ground_tile()
	
	if bufs.has(PLANTEDBUF):
		$SheetSprite.setup([9])
	elif onwall:
		$SheetSprite.setup([8])
	elif onfloor:
		if dpad.x:
			$SheetSprite.setup([5,4,6,4],7)
		else:
			$SheetSprite.setup([4])
	else:
		if vel.y < 0:
			$SheetSprite.setup([5])
		elif vel.y < 0.2:
			$SheetSprite.setup([15])
		else:
			$SheetSprite.setup([7])
	
	if $spikes_detector.get_overlapping_bodies():
		touched_sparkles.emit()

func interact_ground_tile():
	bufs.on(PLANTEDBUF)
	vel.x *= 0.5
	vel.y = -0.5
	onfloor = false
	var room : DreamRoom = LiveDream.GetRoom(self)
	if not room: push_error("lichp(player) - no room"); return;
	var maze : Maze = room.get_maze()
	if not maze: push_error("lichp(player) - no maze"); return;
	var player_cell : Vector2i = maze.local_to_map(position)
	var planting : bool = false
	
	 #check left/right
	prints("attempt plant @",player_cell)
	if is_maze_cell_solid(maze, player_cell+Vector2i.DOWN):
		planting = true
	else:
		var rect = ($mover/solidcast.shape as RectangleShape2D);
		var possible_other_cells : Array[Vector2i] = [
			maze.local_to_map(position-Vector2(rect.size.x/2,0)),
			maze.local_to_map(position+Vector2(rect.size.x/2,0)),
		]
		for cell in possible_other_cells:
			if (cell != player_cell
			and not is_maze_cell_solid(maze, cell)
			and is_maze_cell_solid(maze, cell + Vector2i.DOWN)):
				player_cell = cell
				planting = true
				break
	
	if planting:
		position.x = lerp(position.x, maze.map_to_center(player_cell).x, 0.8)
		try_plant(room, maze, player_cell + Vector2i.DOWN)
		
	#if marking:
		#var cell : Vector2i
		#var cell_tid : int
		#var marked : bool = false
		#cell.x = player_cell.x
		#for y in range(player_cell.y + 1, ceil(room.room_size.y / maze.tile_set.tile_size.y)):
			#cell.y = y
			#cell_tid = maze.get_cell_tid(cell)
			#match cell_tid:
				#6,7,8:
					#highlight(maze, cell, cell_tid)
					#marked = true
					#break
				#16,17,18:
					#continue
				#_:
					#break
#
#func highlight(maze : Maze, cell : Vector2i, tid : int):
	#maze.set_cell_tid(cell, tid+10)

func try_plant(room : DreamRoom, maze : Maze, cell : Vector2i) -> bool:
	match maze.get_cell_tid(cell):
		16:
			maze.set_cell_tid(cell, 23)
			for dir in [Vector2i.RIGHT,Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,]:
				var cel2 = cell
				for i in range(20):
					cel2 += dir
					match maze.get_cell_tid(cel2):
						1,2,3:
							maze.set_cell_tid(cel2, 33)
						33,34,35,36,37:
							maze.set_cell_tid(cel2, 1 + randi()%3)
			return true
		17,18:
			maze.set_cell_tid(cell, 23)
			return true
	
	return false # failed
	

func is_maze_cell_solid(maze : Maze, cell : Vector2i) -> bool:
	if maze.is_cell_solid(cell): return true
	else: return false
