extends Node2D

var fullstrength : int = 10
var lifespan : int = 50
var rootpos : Vector2
func setup(maze:Maze, target_cell:Vector2i, target_pos:Vector2):
	position = maze.map_to_center(target_cell)
	rootpos = position
	$Line2D.clear_points()
	var x = target_pos.x
	var y = target_pos.y
	while y >= -11:
		$Line2D.add_point(Vector2(x,y))
		x += randf_range(-10,10)
		y -= 10
	$Line2D.position = -position
	return self

func _physics_process(_delta: float) -> void:
	#position.x = rootpos.x + randi_range(-1,1+1)
	if fullstrength > 0:
		fullstrength -= 1
		#scale.x = randf_range(1.0,1.25)
	else:
		self_modulate.a = lifespan / 40.0
		#scale.x *= 0.8
	if lifespan > 0:
		lifespan -= 1
	else:
		queue_free()
