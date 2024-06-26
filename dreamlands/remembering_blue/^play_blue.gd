extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	var land : DreamLand = load(
		"res://dreamlands/remembering_blue/blueland.tscn").instantiate()
	
	dream.goto_new_land(land, "rmA")
	await dream.player_escaped
	dream.goto_new_land(land, "rmB")
	dream.windfish_awakened.emit()
