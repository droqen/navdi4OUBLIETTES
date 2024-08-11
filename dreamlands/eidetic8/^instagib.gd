extends Node

func _ready() -> void:
	NavdiSolePlayer.GetPlayer(self).escape("endofgame")
