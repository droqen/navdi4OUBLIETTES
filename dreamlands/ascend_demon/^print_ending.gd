extends Node

@export var diamond_label : ChatterLabel
@export var starfish_label : ChatterLabel

func _ready() -> void:
	diamond_label = $"../diamond"
	starfish_label = $"../starfish"
	prints(diamond_label, starfish_label)
	await get_tree().create_timer(1).timeout
	prints(diamond_label, starfish_label)
	diamond_label.printing = true
	diamond_label.text = '/\\\n\\/'
	for i in range(VictoryJewel.JewelCount - 1):
		diamond_label.text += '\n'
		diamond_label.text += '/\\\n\\/'
	await diamond_label.doneprinting
	await get_tree().create_timer(1.0).timeout
	if VictoryJewel.JewelCount < 10:
		starfish_label.printing = true
		await starfish_label.doneprinting
		print("windfish awakened.")
		LiveDream.GetDream(self).windfish_awakened.emit()
	else:
		print("windfish awakened.")
		LiveDream.GetDream(self).windfish_awakened.emit()
