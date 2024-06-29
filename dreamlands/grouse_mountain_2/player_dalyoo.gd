extends NavdiSolePlayer

enum { GRASSRUSTLEBUF=1000, JUMPBUF, FLORBUF,
	JUMPDELAYBUF, PLANTDELAYBUF, POSTPLANT, }

var bufs : Bufs = Bufs.Make(self).setup_bufons([GRASSRUSTLEBUF,10,
	JUMPBUF,5, FLORBUF,5, JUMPDELAYBUF,22,
	PLANTDELAYBUF,30, POSTPLANT,15,
])
var vel : Vector2

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor : bool = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1.0) < 1.0
	if onfloor: bufs.on(FLORBUF)
	if bufs.has(POSTPLANT):
		dpad.x = 0
	elif bufs.has(PLANTDELAYBUF):
		dpad.x = 0
		if bufs.read(PLANTDELAYBUF) == 1:
			bufs.on(POSTPLANT)
	elif bufs.has(JUMPDELAYBUF):
		dpad.x = 0
		if bufs.read(JUMPDELAYBUF) == 1:
			bufs.clr(FLORBUF); onfloor = false; vel.y = -1.35
	elif visible and bufs.try_eat([JUMPBUF, FLORBUF]):
		bufs.on(JUMPDELAYBUF)
	elif visible and onfloor and Pin.get_plant_hit():
		bufs.on(PLANTDELAYBUF)
	vel.x = move_toward(vel.x, dpad.x * 0.5, 0.02)
	vel.y = move_toward(vel.y, 2.0, 0.02)
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
		
	var maze : Maze = get_maze()
	if (
	not bufs.has(PLANTDELAYBUF)
	and not bufs.has(POSTPLANT)
	and not bufs.has(JUMPDELAYBUF)
	and get_is_hidden_in_grass(maze)
	):
		hide()
		if bufs.read(GRASSRUSTLEBUF) <= 1: bufs.on(GRASSRUSTLEBUF)
	else:
		show()
		if bufs.read(GRASSRUSTLEBUF) == 1 and maze:
			for cell in maze.get_used_cells_by_tids([44]):
				maze.set_cell_tid(cell, 43)
			for cell in maze.get_used_cells_by_tids([13]):
				maze.set_cell_tid(cell, 12)
		var spr = $SheetSprite
		if dpad.x: spr.flip_h = dpad.x < 0
		if bufs.has(JUMPDELAYBUF): spr.setup([19])
		elif bufs.has(PLANTDELAYBUF): spr.setup([20])
		elif bufs.has(POSTPLANT): spr.setup([21])
		elif onfloor:
			if dpad.x or vel.x: spr.setup([16,17,18,19],14)
			else: spr.setup([15])
		else:
			bufs.clr(JUMPDELAYBUF)
			spr.setup([18])

func on_replace_player(prev_player):
	prints('replace',position)
	visible = prev_player.visible
	position = prev_player.position
	vel = prev_player.vel
	if position.y < 122:
		position.y = 122
		print("/!\\ player_dalyoo.gd moved position down")
	prints('TODO replacing player',prev_player)

func get_maze() -> Maze:
	var room : DreamRoom = LiveDream.GetRoom(self)
	if room: return room.maze
	else: return null # no maze.
func get_is_hidden_in_grass(maze : Maze) -> bool:
	if maze == null: return false # no maze.
	var rect = RectangleShape2D.new()
	rect.size = Vector2(7,8)
	var grass_dict : Dictionary
	var nograss_dict : Dictionary
	for cell in $mazer.find_all_overlapping_cells(position + Vector2(0,-5), rect):
		var tid = maze.get_cell_tid(cell)
		match tid:
			12,13:
				grass_dict[cell.y] = true
				if bufs.read(GRASSRUSTLEBUF) <= 1:
					maze.set_cell_tid(cell, 12 if tid!=12 else 13)
			43,44:
				grass_dict[cell.y] = true
				if bufs.read(GRASSRUSTLEBUF) <= 1:
					maze.set_cell_tid(cell, 43 if tid!=43 else 44)
			_:
				nograss_dict[cell.y] = true
	if not grass_dict.is_empty():
		if bufs.read(GRASSRUSTLEBUF) <= 1:
			bufs.on(GRASSRUSTLEBUF)
	# else:
	return grass_dict.keys().size() > (0 if nograss_dict.is_empty() else 1)
