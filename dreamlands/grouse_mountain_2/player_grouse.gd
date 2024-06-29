extends NavdiSolePlayer

const IS_PLAYER_GROUSE : bool = true

signal peck_ended

enum { GRASSRUSTLEBUF=1000, BIGFLAPBUF, PREBIGFLAPBUF, PECKBUF, }

const DROP_WOIM_PFB = preload("res://dreamlands/grouse_mountain_2/item_woim.tscn")
const DROP_JEWEL_PFB = preload("res://dreamlands/grouse_mountain_2/item_jewel.tscn")

enum { ITEM_NONE, ITEM_WORM, ITEM_JEWEL, }

var held_item_st = TinyState.new(
	ITEM_NONE,
	func(then,now):
		match then:
			ITEM_WORM:
				$spr/held_item/worm.hide()
			ITEM_JEWEL:
				$spr/held_item/jewel.hide()
		match now:
			ITEM_WORM:
				$spr/held_item/worm.show()
			ITEM_JEWEL:
				$spr/held_item/jewel.show()
				
)

var vel : Vector2
var bufs : Bufs = Bufs.Make(self).setup_bufons([GRASSRUSTLEBUF,10, BIGFLAPBUF,13, PREBIGFLAPBUF,3, PECKBUF,10,])
func _physics_process(delta: float) -> void:
	var dpad : Vector2
	dpad = Pin.get_dpad()
	if bufs.has(PECKBUF):
		dpad *= 0
		if bufs.read(PECKBUF) == 1: peck_ended.emit()
	if Pin.get_jump_hit():
		vel.y = -1.5
		bufs.on(BIGFLAPBUF)
		bufs.on(PREBIGFLAPBUF)
	vel.x = move_toward(vel.x, dpad.x, 0.1)
	if Pin.get_jump_held() and not bufs.has(BIGFLAPBUF):
		vel.y = move_toward(vel.y * 0.95, 1.0, 0.02)
	else:
		vel.y = move_toward(vel.y, 1.5, 0.09)
	if dpad.x: $spr.scale.x = dpad.x
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
	var onfloor : bool = $mover.cast_fraction(self, $mover/solidcast,
	VERTICAL, 1.0) < 1 and vel.y >= 0
	if onfloor and Pin.get_plant_hit():
		bufs.on(PECKBUF); vel.x = 0;
		peck_pickup()
	
	var maze : Maze = get_maze()
	if get_is_hidden_in_grass(maze):
		hide()
		if bufs.read(GRASSRUSTLEBUF) <= 1: bufs.on(GRASSRUSTLEBUF)
	else:
		show()
		if bufs.read(GRASSRUSTLEBUF) == 1 and maze:
			for cell in maze.get_used_cells_by_tids([13]):
				maze.set_cell_tid(cell, 12)
		if onfloor:
			if bufs.has(PECKBUF):
				$spr.setup([22])
			elif dpad.x:
				$spr.setup([11,10],8)
			else:
				$spr.setup([10])
		else:
			if bufs.has(PREBIGFLAPBUF): $spr.setup([20])
			elif bufs.has(BIGFLAPBUF): $spr.setup([21])
			elif Pin.get_jump_held(): $spr.setup([20,21],7)
			else: $spr.setup([20])

func chick_try_eat() -> bool:
	if held_item_st.id == ITEM_WORM:
		held_item_st.goto(ITEM_NONE) 
		return true # worm got ate!
	# else:
	return false

func _exit_tree() -> void:
	drop_item()

func drop_item() -> Node2D:
	match held_item_st.id:
		ITEM_JEWEL:
			var jewel = DROP_JEWEL_PFB.instantiate()
			jewel.position = self.position + Vector2($spr/peck_zone.position.x * $spr.scale.x, 0)
			LiveDream.GetRoom(self).add_child.call_deferred(jewel)
			held_item_st.goto(ITEM_NONE)
			return jewel
		ITEM_WORM:
			var worm = DROP_WOIM_PFB.instantiate()
			worm.position = self.position + Vector2($spr/peck_zone.position.x * $spr.scale.x, 0)
			LiveDream.GetRoom(self).add_child.call_deferred(worm)
			held_item_st.goto(ITEM_NONE)
			return worm
	return null

func peck_pickup():
	var dropped_item = drop_item()
	for area in $spr/peck_zone.get_overlapping_areas():
		var item = area.get_parent()
		if item == dropped_item: continue
		if try_get_item(item): break # you got somethin'!

func delayed_item_goto(item_enum):
	await peck_ended
	held_item_st.goto(item_enum)

func try_get_item(item):
	if item.get('is_worm'):
		item.queue_free()
		delayed_item_goto(ITEM_WORM)
		return true
	elif item.get('is_jewel'):
		item.queue_free()
		delayed_item_goto(ITEM_JEWEL)
		return true
	else:
		push_error("try_get_item failed - "+item+" is not an item")
		return false

func on_replace_player(prev_player):
	position = prev_player.position
	prints('TODO replacing player',prev_player)

func get_maze() -> Maze:
	var room : DreamRoom = LiveDream.GetRoom(self)
	if room: return room.maze
	else: return null # no maze.
func get_is_hidden_in_grass(maze : Maze) -> bool:
	if maze == null: return false # no maze.
	var rect = RectangleShape2D.new()
	rect.size = Vector2(2,2)
	for cell in $mazer.find_all_overlapping_cells(position + Vector2(0,-2), rect):
		var tid = maze.get_cell_tid(cell)
		match tid:
			12,13:
				if bufs.read(GRASSRUSTLEBUF) <= 1:
					maze.set_cell_tid(cell, 12 if tid!=12 else 13)
				return true
	# else:
	return false
