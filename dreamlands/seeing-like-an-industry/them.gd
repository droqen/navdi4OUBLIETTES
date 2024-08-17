extends Node2D

var maze : Maze # just assign me the maze.
var lastmovedir : Vector2i
var targetpos : Vector2
var wait : int = 0
@export var initialwait : int = 0

func _ready() -> void:
	wait = initialwait
	maze = LiveDream.GetRoom(self).maze # never change once you have this.
	targetpos = position

func _physics_process(_delta: float) -> void:
	var spr : SheetSprite = $SheetSprite
	if wait > 0:
		wait -= 1
		if lastmovedir.y: spr.setup([14])
		else: spr.setup([33])
		return # no more processing
	position.x = move_toward(position.x, targetpos.x, 1)
	position.y = move_toward(position.y, targetpos.y, 1)
	match lastmovedir:
		Vector2i.RIGHT: spr.flip_h = false; spr.setup([34,35,36,37],4)
		Vector2i.LEFT: spr.flip_h = true; spr.setup([34,35,36,37],4)
		Vector2i.UP: spr.setup([14,15,16,17],8)
		Vector2i.DOWN: spr.setup([17,16,15,14],8)
	if position.distance_squared_to(targetpos) < 0.5:
		position = targetpos
		if randf() < 0.01:
			wait = 60 + randi() % 300
			lastmovedir = Vector2i.ZERO
		else:
			# keep movin
			var cell = maze.local_to_map(position)
			var possibledirs = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
			possibledirs.erase(-lastmovedir)
			possibledirs.shuffle()
			if lastmovedir: possibledirs.append(-lastmovedir)
			for dir in possibledirs:
				if can_move_dir(cell, dir):
					if dir == -lastmovedir: # if i'm forced to do a 180
						if randf() < 0.25: # then *frequently*
							wait = 30 + randi() % 60 # i wait a bit
					targetpos = maze.map_to_local(cell + dir)
					lastmovedir = dir
					break
			#var possible_dirs : Array[int] = [0,1,2,3]
			#possi
			#targetpos = maze.local_to_map()

func can_move_dir(cell : Vector2i, dir : Vector2i) -> bool:
	var cell2 : Vector2i = cell + dir
	
	# prefer not to go very fast west
	if dir.x < 0 and cell2.x < randi_range(3,6): return false
	
	var cell2_standable = maze.is_cell_solid(cell2 + Vector2i(0,1))
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
	
	prints("[them.gd]","can_move_dir","illegal case","at cell,dir:",cell,dir)
	return false
