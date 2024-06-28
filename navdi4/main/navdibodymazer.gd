extends Marker2D
class_name NavdiBodyMazer

func get_maze() -> Maze:
	var room : DreamRoom = LiveDream.GetRoom(self)
	if not room: push_error("navdibodymazer - no room"); return;
	var maze : Maze = room.get_maze()
	if not room: push_error("navdibodymazer - no maze"); return;
	return maze;

func find_all_overlapping_cells(
point : Vector2, rect : RectangleShape2D
)-> Array[Vector2i]:
	var maze : Maze = get_maze()
	var overlapping_cells : Array[Vector2i]
	var mincell = maze.local_to_map(point-rect.size/2)
	var maxcell = maze.local_to_map(point+rect.size/2)
	for x in range(mincell.x, maxcell.x+1):
		for y in range(mincell.y, maxcell.y+1):
			overlapping_cells.append(Vector2i(x,y))
	return overlapping_cells

func find_best_floor_cell_if_any(point : Vector2, rect : RectangleShape2D):
	var maze : Maze = get_maze()
	var target_cell : Vector2i = maze.local_to_map(point)
	if maze.is_cell_solid(target_cell + Vector2i.DOWN):
		return target_cell + Vector2i.DOWN # great!
	# else, try edges of rect.
	var possible_other_cells : Array[Vector2i] = [
		maze.local_to_map(point-Vector2(rect.size.x/2,0)),
		maze.local_to_map(point+Vector2(rect.size.x/2,0)),
	]
	for cell in possible_other_cells:
		if (cell != target_cell
		and not maze.is_cell_solid(cell)
		and maze.is_cell_solid(cell + Vector2i.DOWN)):
			return cell + Vector2i.DOWN # great!
	# else, no hope.
	return null # just to make it explicit.
