extends NavdiSolePlayer

enum { INAIRBUF, }
var bufs = Bufs.Make(self).setup_bufons([INAIRBUF,15,])

var initialized : bool = false
var maze : Maze
var my_cell : Vector2i
var lastmovedir : Vector2i

func _ready() -> void:
	super._ready()
	travelled_dir.connect(func(tdir):
		my_cell -= tdir * Vector2i(36,10)
		maze = null
	)

func _physics_process(_delta: float) -> void:
	if not maze or not is_instance_valid(maze):
		var room = LiveDream.GetRoom(self)
		if room : maze = room.maze
	if maze and is_instance_valid(maze):
		if not initialized:
			my_cell = maze.local_to_map(position) + Vector2i.RIGHT
			initialized = true
		var tomove : Vector2 = maze.map_to_local(my_cell) - position
		if Pin.get_jump_hit() and tomove == Vector2.ZERO: bufs.on(INAIRBUF)
		# now accepting input.
		var dx : int = Pin.get_dpad().x
		var dy : int = (1 if Pin.get_plant_held() else 0) - (1 if Pin.get_jump_held() else 0)
		if tomove.y == 0 and dx < 0 and (dy == 0 or !can_move_dir(my_cell,Vector2i(0,dy))) and !can_move_dir(my_cell,Vector2i(-1,0)):
			tomove.x -= 5
		if abs(tomove.x) < 1.0 and abs(tomove.y) < 1.0:
			position += tomove # done!
			if dx and can_move_dir(my_cell,Vector2i(dx,0)):
				my_cell.x += dx
				lastmovedir = Vector2i(dx,0)
				tomove = lastmovedir
			elif dy and can_move_dir(my_cell,Vector2i(0,dy)):
				my_cell.y += dy
				lastmovedir = Vector2i(0,dy)
				tomove = lastmovedir
		else:
			var xamt : float = abs(tomove.x)
			position.x += clamp(tomove.x,-1,1)
			if xamt < 1:
				position.y += clamp(tomove.y,-(1-xamt),(1-xamt))
	
		if bufs.has(INAIRBUF) and bufs.read(INAIRBUF) < 15:
			$spr.setup([115]);
		elif tomove.x:
			$spr.flip_h = tomove.x < 0; $spr.setup([114,115,116,117],4)
		elif tomove.y < 0:
			$spr.setup([94,95,96,97],8);
		elif tomove.y > 0:
			$spr.setup([97,96,95,94],8);
		elif dy > 0:
			$spr.setup([112])
		else:
			$spr.setup([113])

func can_move_dir(cell : Vector2i, dir : Vector2i) -> bool:
	var cell2 : Vector2i = cell + dir
	
	var cell2_standable = maze.is_cell_solid(cell2 + Vector2i(0,1)) or maze.get_cell_tid(cell2 + Vector2i(0,1)) == 4
	if not cell2_standable: return false
	var cell2_enterable = true
	if maze.is_cell_solid(cell2): match maze.get_cell_tid(cell2):
		2,3: cell2_enterable = true
		_: cell2_enterable = false
	if not cell2_enterable: return false
	
	if dir.x:
		return true # good
	else:
		if dir.y < 0: # going up
			var cell_ladder = maze.get_cell_tid(cell) == 3
			if cell_ladder: return true # good
			else: return false # climbing not allowed from here
		else: # going down
			var cell2_ladder = maze.get_cell_tid(cell2) == 3
			if cell2_ladder: return true # good
			else: return false # climbing down to cell2 not allowed
	
