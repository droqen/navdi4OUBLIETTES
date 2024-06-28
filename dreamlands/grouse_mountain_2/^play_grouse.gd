extends Node

@onready var dream : LiveDream = $".."
func _ready():
	var land = load("res://dreamlands/grouse_mountain_2/grouseLand.tscn").instantiate()
	dream.goto_new_land(land, "rmA")
