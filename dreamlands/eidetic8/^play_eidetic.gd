extends Node

@onready var dream : LiveDream = get_parent()
const LAND = preload("res://dreamlands/eidetic8/eidetic8land.tscn")

func _ready() -> void:
	var land = LAND.instantiate()
	dream.goto_new_land( land, "rmA" )
	dream.player_escaped.connect(func(escape_code):
		match escape_code:
			"respawn":
				NavdiSolePlayer.ClearPlayer(self)
				var room = land.try_get_room_inst(Checkpoint.CheckRoomName)
				if room:
					if dream.dreamroom != room:
						dream.set_dreamroom(room)
					var player = load("res://dreamlands/eidetic8/snowtrudger.tscn").instantiate()
					player.position = room.get_node( Checkpoint.CheckName ).position
					add_child(player)
					player.owner = owner
					player.bufs.on(player.JUMPBUF)
				else:
					print("no room found")
			_:
				dream.windfish_awakened.emit() # game over
	)
	#print("player escaped.")
	#dream.goto_new_land(
		#load(
			#"res://dreamlands/desert-archive/DesertArchiveLAND_Post.tscn"
		#).instantiate(),
		#"rmDeep4"
	#)
