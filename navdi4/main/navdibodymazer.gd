extends Marker2D
class_name NavdiBodyMazer

func get_maze() -> Maze:
	var room : DreamRoom = LiveDream.GetRoom(self)
	if not room: push_error("navdibodymazer - no room"); return;
	var maze : Maze = room.get_maze()
	if not room: push_error("navdibodymazer - no maze"); return;
	return maze;

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
