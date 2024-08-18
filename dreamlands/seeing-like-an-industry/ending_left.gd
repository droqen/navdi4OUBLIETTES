extends Node

@export var but_actually_right : bool = false
@export var ending_string : String = "A"

var player

func _ready() -> void:
	player = NavdiSolePlayer.GetPlayer(self)

func _physics_process(_delta: float) -> void:
	if player and is_instance_valid(player) :
		if (
			(but_actually_right and player.position.x >= 185)
			or
		(not but_actually_right and player.position.x <= 175)
			):
				player.queue_free()
				player = null
				if not but_actually_right:
					await get_tree().create_timer(2.00).timeout
				LiveDream.GetDream(self).windfish_lucidwake.emit(ending_string)
