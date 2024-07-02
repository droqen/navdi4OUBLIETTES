extends Node

@onready var dream : LiveDream = $".."
@onready var land : DreamLand = load("res://dreamlands/beatrice/beatrice_land.tscn").instantiate()
#const PLAYER_PFB = preload("res://dreamlands/grouse_mountain_2/player_grouse.tscn")

#var respawn_player_pending : int = 0

func _ready():
	dream.goto_new_land(land, "rmA")
	await dream.player_escaped
	dream.windfish_awakened.emit()
	#dream.goto_new_land(land, "rmNatureEast3")
	#dream.goto_new_land(land, "rmPuzzle3")

#func _physics_process(_delta: float) -> void:
	#if NavdiSolePlayer.GetPlayer(self) == null:
		#respawn_player_pending += 1
		#if respawn_player_pending > 60:
			#dream.set_dreamroom(land.try_get_room_inst("rmA"))
			#respawn_player_pending = 0
			#var newplayer = PLAYER_PFB.instantiate()
			#newplayer.position = Vector2(55,125)
			#land.try_get_room_inst("rmA").add_child(newplayer) 
	#else:
		#respawn_player_pending = 0
