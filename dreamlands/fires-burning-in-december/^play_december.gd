extends Node
func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/fires-burning-in-december/decemberland.tscn"
		).instantiate(),
		"rmA"
	)
	var escape_code = await dream.player_escaped
	dream.windfish_lucidwake.emit(escape_code)
