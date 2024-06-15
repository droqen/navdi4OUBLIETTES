extends Node
class_name MazeBake

@export var path_to_maze_container : NodePath
@export var path_diagonally_too : bool = false

var maze : Maze :
	get():
		return get_node(path_to_maze_container).get_child(0) as Maze

var maze_coords_to_pid : Dictionary
var pid_to_maze_coords : Dictionary

var _astar : AStar2D = null
var astar : AStar2D :
	get():
		if _astar == null: _bake()
		return _astar

func _bake():
	maze_coords_to_pid.clear()
	pid_to_maze_coords.clear()
	self._astar = AStar2D.new()
	var pid = 0
	var cells = maze.get_used_cells()
	for maze_coords in cells:
		if maze.is_cell_navigable(maze_coords):
			self._astar.add_point(pid, maze.map_to_center(maze_coords))
			maze_coords_to_pid[maze_coords] = pid
			pid_to_maze_coords[pid] = maze_coords
			pid += 1
	for maze_coords in maze_coords_to_pid.keys():
		connect_cell_to_neighbours(maze_coords)

func connect_cell_to_neighbours(maze_coords : Vector2i):
	var pidA = maze_coords_to_pid[maze_coords]
	for dx in [-1,0,1]: for dy in [-1,0,1]:
		var taxidist = abs(dx) + abs(dy)
		if taxidist == 1 or (path_diagonally_too and taxidist == 2):
			var pidB = maze_coords_to_pid.get(maze_coords + Vector2i(dx,dy), -1)
			if pidB >= 0: _astar.connect_points(pidA, pidB, true)
