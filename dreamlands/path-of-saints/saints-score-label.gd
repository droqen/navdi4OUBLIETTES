extends Label

func _ready() -> void:
	@warning_ignore("integer_division")
	if SaintsTransgressions.transgressions > 0:
		text = "your time\n%04d\n\nyour score\n%d\n\nsaints par\n%d\n\n\nyou are not\n\n\nbut the result\nnever changes." % [
			mini(9999, SaintsTransgressions.time / 60),
			SaintsTransgressions.transgressions,
			0
		]
		
	else:
		text = "your time\n%04d\n\nyour score\n%d\n\nsaints par\n%d\n\nyou too\nmay be\n\n\nbut the result\nnever changes." % [
			mini(9999, SaintsTransgressions.time / 60),
			SaintsTransgressions.transgressions,
			0
		]
	var vischars_max : int = len(text)
	visible_characters = 0
	await get_tree().create_timer(0.7).timeout
	while visible_characters < vischars_max:
		match text[visible_characters]:
			'\n': await get_tree().create_timer(0.7).timeout
			' ': await get_tree().create_timer(0.7).timeout
		visible_characters += 1
	LiveDream.GetDream(self).windfish_awakened.emit()
