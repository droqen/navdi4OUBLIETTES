extends Node2D

@export var starting_fullstrength : int = 10
@export var starting_lifespan : int = 50
@export var explosion_colours : bool = false
const EXPLOSION_RED = Color("#ed704e")
@onready var fullstrength : int = starting_fullstrength
@onready var lifespan : int = starting_lifespan
@export var minimum_lifespan : int = 0
func setup(maze:Maze, target_cell:Vector2i):
	if maze:
		position = maze.map_to_center(target_cell)
	else:
		position = target_cell as Vector2
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
		if explosion_colours:
			match fullstrength:
				5,7,9:
					$ColorRect2.color = EXPLOSION_RED
				2,3,4,6,8:
					$ColorRect2.color = Color.WHITE
				1:
					$ColorRect2.color = Color.BLACK
		fullstrength -= 1
		#scale.x = randf_range(1.0,1.25)
	else:
		if explosion_colours:
			$ColorRect2.color = Color.DIM_GRAY
			$ColorRect2.color.a = 0.5
			scale.x += 0.01
			scale.y += 0.01
			position.x += randf_range(-0.5,0.5)
			position.y += randf_range(-0.5,0.0)
		self_modulate.a = lifespan * 1.0 / (starting_lifespan - starting_fullstrength)
		#scale.x *= 0.8
	if lifespan > minimum_lifespan:
		lifespan -= 1
	if lifespan <= 0:
		queue_free()
