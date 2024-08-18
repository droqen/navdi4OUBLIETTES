extends Node2D

var player : Node2D = null

@export var awaken_on_left : bool = false

func _enter_tree() -> void:
	show()
	player = NavdiSolePlayer.GetPlayer(self)
	if player: update_hide()

func _physics_process(delta: float) -> void:
	if not player: player = NavdiSolePlayer.GetPlayer(self)
	if player and is_instance_valid(player): update_hide()

func update_hide() -> void:
	if awaken_on_left:
		position.x = -180
		if player and is_instance_valid(player):
			if player.position.x <= 175:
				player.queue_free()
				await get_tree().create_timer(1.0).timeout
				LiveDream.GetDream(self).windfish_lucidwake.emit("A")
	else:
		if player.position.x < 178:
			position.x = 180
		else:
			position.x = -180
