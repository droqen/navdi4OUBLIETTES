extends Node

@onready var dream : LiveDream = get_parent()
@onready var land : DreamLand = load("res://dreamlands/doctrine/k_land.tscn").instantiate()

func _ready():
	dream.goto_new_land(land, "rmA")
	await dream.player_escaped
	dream.windfish_awakened.emit()
