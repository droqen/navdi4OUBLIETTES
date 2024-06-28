extends Node

@onready var dream : LiveDream = $".."
func _ready():
	var land = load("res://dreamlands/clearing/clearingLand.tscn").instantiate()
	dream.goto_new_land(land, "rmA")
