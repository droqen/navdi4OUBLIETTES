extends RefCounted
class_name MazePath
var a : int = -1
var b : int = -1
var path : PackedVector2Array
var goal : Vector2

func repath(astar : AStar2D, start_pos : Vector2, target_pos : Vector2) -> bool:
	goal = target_pos
	var a2 : int = astar.get_closest_point(start_pos)
	var b2 : int = astar.get_closest_point(target_pos)
	if a != a2 or b != b2:
		a = a2
		b = b2
		path = astar.get_point_path(a, b, true)
		return true # return true as in 'something changed'
	else:
		# path stays as it is
		return false # return false as in 'no change'

func clear() -> void:
	a = -1; b = -1; path.clear(); goal = Vector2(0,0)
