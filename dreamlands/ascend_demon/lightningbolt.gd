extends Node2D

@export var starting_fullstrength : int = 10
@export var starting_lifespan : int = 50

@onready var fullstrength : int = starting_fullstrength
@onready var lifespan : int = starting_lifespan
func setup(maze:Maze, target_cell:Vector2i):
	position = maze.map_to_center(target_cell)
	if has_node("Line2D"):
		$Line2D.clear_points()
		var x = position.x
		var y = position.y
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
		self_modulate.a = lifespan * 1.0 / (starting_lifespan - starting_fullstrength)
		#scale.x *= 0.8
	if lifespan > 0:
		lifespan -= 1
	else:
		queue_free()
