extends ChatterLabel

@export var print_on_player_floor : bool = true

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	if !printing and print_on_player_floor:
		var player = NavdiSolePlayer.GetPlayer(self)
		if player and player.bufs.has(player.FLORBUF): printing = true
		
