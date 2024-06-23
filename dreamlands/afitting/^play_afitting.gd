extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:		
	var land : DreamLand = load(
		"res://dreamlands/afitting/a-fitting-land.tscn").instantiate()
	
	dream.goto_new_land(land, "rmEmptyFly")
	await dream.player_escaped
	await get_tree().create_timer(1.0).timeout
	dream.goto_new_land(land, "rm1")
	await dream.player_escaped
	dream.windfish_awakened.emit()
