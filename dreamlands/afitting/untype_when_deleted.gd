extends Marker2D

@export var maze : Maze
@export var chatter : ChatterLabel
@export var togglearea : ChatToggleArea

@onready var cell : Vector2i = maze.local_to_map(position)

func _physics_process(_delta: float) -> void:
	if maze.get_cell_tid(cell) <= 0:
		untype()
		queue_free()

func untype():
	if togglearea: togglearea.queue_free()
	if chatter: chatter.printing = false # hopefully backspace?
