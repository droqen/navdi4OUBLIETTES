extends Node

var maze : Maze
var room : DreamRoom
var roomname : String
const ATE_FRUIT_PARTICLE = preload("res://dreamlands/08animals/ate_fruit_particle.tscn")

func _ready() -> void:
	maze = get_parent() as Maze
	room = maze.get_parent() as DreamRoom
	roomname = room.name # used for save data.

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	var cell = maze.local_to_map(player.position)
	match maze.get_cell_tid(cell):
		24: eat_fruit_at(cell)
			
func eat_fruit_at(cell):
	maze.set_cell_tid(cell, 3)
	var particle = ATE_FRUIT_PARTICLE.instantiate()
	particle.colour = Color("#e16a6a")
	particle.position = maze.map_to_local(cell)
	room.add_child(particle)
