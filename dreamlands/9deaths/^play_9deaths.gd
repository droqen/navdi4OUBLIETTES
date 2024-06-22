extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:		
	var land : DreamLand = load(
		"res://dreamlands/9deaths/deathland.tscn").instantiate()
	var firstlevelname = "rm1"
	
	dream.goto_new_land(land, firstlevelname)
	await dream.player_escaped
	dream.goto_new_land(land, "rmEnd")
	
	# end
	prints("9deaths - awaken the wind fish!")
	dream.windfish_awakened.emit()

var player : Node = null
func _physics_process(_delta: float) -> void:
	var cur_player = NavdiSolePlayer.GetPlayer(self)
	if player != cur_player:
		player = cur_player
		if player and player.has_signal("touched_sparkles"):
			player.touched_sparkles.connect(func():
				dream.reload_dreamroom()
			)
