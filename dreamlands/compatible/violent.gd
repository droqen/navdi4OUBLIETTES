extends NavdiSolePlayer

enum { FLORBUF, JUMPBUF, BOMBBUF, NOBOMBSLEFTBUF, }

@onready var bufs = Bufs.Make(self).setup_bufons(
	[FLORBUF,4,JUMPBUF,4, BOMBBUF,10,NOBOMBSLEFTBUF,40]
)

var bombcount : int = 9;

var vx : float; var vy : float;

var active_bomb_timers : Dictionary

var lastroom : DreamRoom

func _ready() -> void:
	super._ready()
	#if is_instance_valid(self):
		#DreamLand.

func exit_room(room : DreamRoom) -> void:
	var maze : Maze = room.maze;
	if maze:
		for bombcel in active_bomb_timers.keys():
			match maze.get_cell_tid(bombcel):
				20,21: explode(maze, bombcel, 1)
				30,31,32,33:explode(maze, bombcel, 2)
				40,41,42,43,44,45:explode(maze, bombcel, 3)
	active_bomb_timers.clear()

func _physics_process(_delta: float) -> void:
	var room : DreamRoom = LiveDream.GetRoom(self)
	var maze : Maze;
	if room :
		maze = room.maze
		prints(lastroom, room)
		if lastroom != room:
			if lastroom: exit_room(lastroom)
			lastroom = room
	if bufs.has(NOBOMBSLEFTBUF):
		if bufs.read(NOBOMBSLEFTBUF) % 4 < 2: $Label.hide()
		else : $Label.show(); $Label.text = "nop"
	else:
		$Label.show()
		$Label.text = "%d/9" % bombcount
	var dpad : Vector2i; var jump : bool; var jumpheld : bool; var bombbutt : bool;
	if not bufs.has(BOMBBUF):
		dpad = Pin.get_dpad();
		if Pin.get_jump_hit(): jump=true; bufs.on(JUMPBUF);
		if Pin.get_jump_held(): jumpheld=true;
		if Pin.get_plant_hit(): bombbutt=true;
	var mover : NavdiBodyMover = $mover;
	var solidcast : ShapeCast2D = $mover/solidcast;
	var spr : SheetSprite = $spr;
	var onfloor : bool = vy >= 0 and mover.cast_fraction(self, solidcast, VERTICAL, 1) < 1
	if bufs.try_eat([FLORBUF,JUMPBUF]):
		vy = -2.0; onfloor = false;
	if onfloor: bufs.on(FLORBUF);
	if vy < 0 and not jumpheld:
		vy += 0.18
	if onfloor: vx = move_toward(vx, dpad.x * 1.2, 0.05)
	else: vx = move_toward(vx, dpad.x * 1.2, 0.01)
	vy = move_toward(vy, 3.0, 0.08)
	
	if maze:
		if onfloor:
			var florcel = get_florcel(maze)
			var yesbomb : bool = bombcount > 0
			#if florcel:
				#if maze.get_cell_tid(florcel) == 13:
					#maze.set_cell_tid(florcel, -1)
					#vy = -0.5
					#yesbomb = false
			
			if Pin.get_plant_hit():
				if yesbomb:
					match maze.get_cell_tid(florcel):
						20,21: maze.set_cell_tid(florcel, 30); active_bomb_timers[florcel] = 175; bombcount -= 1;
						30,31,32,33: maze.set_cell_tid(florcel, 40); active_bomb_timers[florcel] = 175; bombcount -= 1;
						40,41,42,43,44,45: yesbomb = false; active_bomb_timers[florcel] = 175;
						13: maze.set_cell_tid(florcel,14); position.y += 2; # fall thru, oops
						-1: yesbomb = false; pass # nothing here
						_: maze.set_cell_tid(florcel, 20); active_bomb_timers[florcel] = 175; bombcount -= 1;
					if yesbomb:
						position.x = lerp(position.x, maze.map_to_local(florcel).x, 0.5)
						vx = 0
						bufs.on(BOMBBUF)
				if not yesbomb:
					bufs.on(NOBOMBSLEFTBUF)
	if bufs.has(BOMBBUF):
		vx = 0
	
	if dpad.x: spr.flip_h = dpad.x < 0
	if not mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		vx = 0
	if not mover.try_slip_move(self, solidcast, VERTICAL, vy):
		vy = 0
	if bufs.has(FLORBUF):
		if bufs.has(BOMBBUF):
			spr.setup([4,0,0],5)
			
			if bufs.read(BOMBBUF) == 4: vy = -1.2
		elif dpad.x:
			if spr.frames.size() != 4: match spr.frames[0]:
				2: spr.setup([1,3,1,2],8)
				_: spr.setup([2,1,3,1],8)
			else:
				spr.ani_period = 8
		else:
			spr.setup([1])
	else:
		if dpad.x: spr.setup([1,2,1,3],3)
		else: spr.setup([3])
		
	# update active bomb timers
	if maze:
		for bombcel in active_bomb_timers.keys():
			var t : int = active_bomb_timers[bombcel]
			if t % 24 == 0 or (t < 100 and t % 12 == 0) or (t < 50 and t % 4 == 0):
				var tid : int = maze.get_cell_tid(bombcel)
				match tid:
					20,21:
						maze.set_cell_tid(bombcel, (tid-20+1)%2+20);
						if t == 0: explode(maze, bombcel, 1)
					30,31,32,33:
						maze.set_cell_tid(bombcel, (tid-30+1+(randi()%3))%4+30);
						if t == 0: explode(maze, bombcel, 2)
					40,41,42,43,44,45:
						maze.set_cell_tid(bombcel, (tid-40+1+(randi()%5))%6+40);
						if t == 0: explode(maze, bombcel, 3)
			if t <= 0: active_bomb_timers.erase(bombcel)
			else: active_bomb_timers[bombcel] = t - 1

func get_florcel(maze:Maze) -> Vector2i:
	var cells = []
	for dx in [0,-4,4]:
		var dpos = position + Vector2(dx,0)
		var dcel = maze.local_to_map(dpos)
		if cells.has(dcel): continue
		else: cells.append(dcel)
	for cel in cells:
		if not maze.is_cell_solid(cel):
			var florcel = cel + Vector2i.DOWN
			if maze.is_cell_solid(florcel):
				return florcel
	return Vector2i.ZERO

func explode(maze : Maze, cel : Vector2i, celradius : int) -> void:
	for dx in range(-celradius,celradius+1):
		for dy in range(-celradius,celradius+1):
			var cel2 : Vector2i = cel + Vector2i(dx,dy)
			var damage : int = 2
			if abs(dx) == celradius or abs(dy) == celradius: damage = 1
			if damage == 2:
				maze.set_cell_tid(cel2, -1)
			elif damage == 1:
				if maze.is_cell_solid(cel2):
					match maze.get_cell_tid(cel2):
						20,21:
							explode.call_deferred(maze, cel2, 1)
						30,31,32,33:
							explode.call_deferred(maze, cel2, 2)
						40,41,42,43,44,45:
							explode.call_deferred(maze, cel2, 3)
						13:
							maze.set_cell_tid(cel2, -1);
						_:
							maze.set_cell_tid(cel2, 13);
				else:
					maze.set_cell_tid(cel2, -1);
			else:
				pass # no damage. do nothing. case should never happen tho.
