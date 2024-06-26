extends Node

@onready var dream : LiveDream = $".."
func _ready():
	var land = load("res://dreamlands/ascend_demon/demontowerland.tscn").instantiate()
	dream.goto_new_land(land, "rmA")
	await dream.player_escaped
	dream.windfish_awakened.emit()
	
