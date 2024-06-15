extends Node
class_name MazeGuide

var astar : AStar2D
var path : MazePath = MazePath.new()

@export var maze_bake : MazeBake
var maze : Maze :
	get(): return maze_bake.maze
@export var nav_bit : int = 0
@export var shapecast : ShapeCast2D

var mouse : Node2D : # maze mouse.
	get() : return get_parent() as Node2D

var _nogoal : bool = true # default state
var _goal : Vector2
var _goalcell : Vector2i
@onready var goal : Vector2 = mouse.position :
	set(v) :
		_nogoal = false
		_goal = v
		_goalcell = maze.local_to_map(_goal)
		# recalculate path?
	get() : return _goal
var goalcell : Vector2i :
	set(v) :
		_nogoal = false
		_goalcell = v
		_goal = maze.map_to_center(_goalcell)
		# recalculate path?
	get() : return _goalcell

var tonext : Vector2 :
	get() :
		if _nogoal: return Vector2.ZERO
		path.repath(maze_bake.astar, mouse.position, goal)
		var best_path : Vector2 = Vector2.ZERO
		if shapecast:
			if is_clear_to(path.goal):
				var to_goal : Vector2 = path.goal - mouse.position
				if to_goal.length_squared() < 1:
					return Vector2.ZERO # stop. you're done.
				else:
					return to_goal
			
			for i in range(path.path.size()-1,1-1,-1):
				if is_clear_to(path.path[i]):
					best_path = path.path[i] - mouse.position
					break
		if best_path.length() > 10: return best_path # else . . . 
		var next_path_center : Vector2 = mouse.position
		match path.path.size():
			0: pass
			1: next_path_center = path.path[0]
			2,_: next_path_center = path.path[1]
		return next_path_center - mouse.position

func is_clear_to(target:Vector2) -> bool:
	var to_target : Vector2 = target - mouse.position
	if to_target.length() <= 2.0: return true
	shapecast.position = mouse.position + to_target.normalized()
	shapecast.target_position = target - mouse.position - 2.0 * to_target.normalized()
	shapecast.force_shapecast_update()
	return not shapecast.is_colliding()

#func _ready():
	#var data = map.get_cell_tile_data(Vector2i(0,0))
	#data.get_navigation_polygon()

func has_goal() -> bool: return not _nogoal

func _ready():
	if not shapecast: shapecast = get_node_or_null("ShapeCast2D")

func clear():
	_nogoal = true
