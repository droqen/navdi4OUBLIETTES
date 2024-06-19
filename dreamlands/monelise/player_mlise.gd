extends NavdiSolePlayer

enum { FLORBUF, PINJUMPBUF, PLANTEDBUF, }

var last_safe_position : Vector2

var vel : Vector2 # velocity
var onfloor : bool
var onwall : int = 0 # -1 : left, 1 : right
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4,
	PINJUMPBUF,4,
	PLANTEDBUF,8,
])

var _stashed_room_links
var _stashed_room_blb

var headfrm : int = 1
var headst : TinyState = TinyState.new(1, func(then,now):
	if now == 2 || then == 2:
		$mover/solidcast.set_collision_mask_value(15, now != 2)
	if now == 0 || then == 0:
		var room = LiveDream.GetRoom(self)
		if room:
			if now != 0:
				_stashed_room_links = room.room_links.duplicate()
				_stashed_room_blb = room.blank_link_behaviour
				prints("h0 - stashing",room,"... ",_stashed_room_links,_stashed_room_blb)
				for i in range(4): room.room_links[i] = ''
				if now == 1:
					room.blank_link_behaviour = room.BlankLinkBehaviour.WRAP
					room.edge_margin = 0
				else:
					room.blank_link_behaviour = room.BlankLinkBehaviour.SIDES_BLOCKED
					room.edge_margin = 5
			else:
				prints("h0 - reverting",room,"... ",_stashed_room_links,_stashed_room_blb)
				room.room_links = _stashed_room_links
				room.blank_link_behaviour = _stashed_room_blb
				room.edge_margin = 0
				prints('h0 - reverted',room,'!',room.room_links)
		else:
			push_error("Wuh-oh! mlise head 1 broken, room may no longer work . . .")
		
	if now == 0:
		$mover.position.y = 1
		($mover/solidcast.shape as RectangleShape2D).size.y = 8
		$HeadSprite.hide()
	else:
		headfrm = now
		$mover.position.y = 1 - 4
		($mover/solidcast.shape as RectangleShape2D).size.y = 8 + 8
		$HeadSprite.setup([headfrm])
		$HeadSprite.show()
, true)

func _ready() -> void:
	super._ready()
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		print("head 1 on ready")
		headst.id = 0
		headst.goto(1, true)

func _physics_process(_delta: float) -> void:
	var x_movement_speed : float = 1.0
	var flor_jump_power : float = 1.4
	var wall_jump_power : float = 1.4
	match headst.id:
		0,2: # headless or "a"
			flor_jump_power = 1.0
			x_movement_speed = 0.66
		4: # "A"
			flor_jump_power = 2.4
	
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
		$HeadSprite.flip_h = $SheetSprite.flip_h
	
	var prev_onfloor = onfloor
	onfloor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1

	if onfloor:
		bufs.on(FLORBUF)
		last_safe_position = position
	
	onwall = 0
	if dpad.x and $mover.cast_fraction(self, $mover/solidcast, HORIZONTAL, sign(dpad.x)) < 1:
		onwall = sign(dpad.x)
	
	if prev_onfloor and not onfloor:
		vel.x *= 0.75; position.y += 0.5 # drop
		print("aaa drop")
	
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
	
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	
	if onfloor and plantaction:
		interact_ground_tile()
	
	$HeadSprite.position.y = lerp($HeadSprite.position.y, -8.0, 0.25)
	
	if bufs.has(PLANTEDBUF):
		$HeadSprite.setup([headfrm+10])
		$SheetSprite.setup([21])
	elif onwall:
		$HeadSprite.setup([headfrm])
		$SheetSprite.setup([40])
	elif onfloor:
		if dpad.x:
			$HeadSprite.setup([headfrm,headfrm+10],7)
			$SheetSprite.setup([20,30],7)
		else:
			$HeadSprite.setup([headfrm,headfrm,headfrm,headfrm+10],30)
			$SheetSprite.setup([10])
	else:
		$HeadSprite.setup([(headfrm+10) if vel.y < 0 else (headfrm)])
		$SheetSprite.setup([20 if vel.y < 0 else 30])

	if position.y > 220:
		position = last_safe_position
		vel = Vector2(0, -0.75)

func interact_ground_tile():
	bufs.on(PLANTEDBUF)
	vel.x *= 0.5
	vel.y = -0.5
	onfloor = false
	var room : DreamRoom = LiveDream.GetRoom(self)
	if not room: push_error("player_mlise - no room"); return;
	var maze : Maze = room.get_maze()
	if not maze: push_error("player_mlise - no maze"); return;
	var player_cell : Vector2i = maze.local_to_map(position)
	var planting : bool = false
	
	 #check left/right
	prints("attempt mark @",player_cell)
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
		if headst.id == 0:
			var underfootid = maze.get_cell_tid(player_cell + Vector2i.DOWN)
			match underfootid:
				1,2,3,4:
					maze.set_cell_tid(player_cell + Vector2i.DOWN, 0)
					headst.goto(underfootid)
					$HeadSprite.position.y = 4
		else:
			position.y -= 5
			vel.y = -1.4
			maze.set_cell(player_cell, 0, maze.tid2coord(headst.id), TileSetAtlasSource.TRANSFORM_FLIP_H if $SheetSprite.flip_h else 0)
			headst.goto(0)
			
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

func is_maze_cell_solid(maze : Maze, cell : Vector2i) -> bool:
	if maze.is_cell_solid(cell): return true
	elif headst.id != 2 and maze.is_cell_solid(cell, 1): return true
	else: return false
