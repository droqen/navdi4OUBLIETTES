extends Node

var player

func _ready() -> void:
	player = NavdiSolePlayer.GetPlayer(self)

func _physics_process(_delta: float) -> void:
	if player and is_instance_valid(player) and player.position.y > 105:
		player.queue_free()
		player = null
		LiveDream.GetDream(self).windfish_awakened.emit()
