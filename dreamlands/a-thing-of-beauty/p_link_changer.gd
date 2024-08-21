extends Area2D

@export var link_index = 2
@export var link_name = 'rmLeft'

func _ready() -> void:
	area_entered.connect(func(_player_area):
		get_parent().room_links[link_index] = link_name
	)
