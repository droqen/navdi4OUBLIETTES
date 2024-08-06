extends Node2D

func _ready() -> void:
	#print("my flame ready")
	$Area2D.area_entered.connect(func (_area):
		#prints("are entered: ",_area)
		var player : NavdiSolePlayer = _area.get_parent()
		player.escape.call_deferred(1)
		#LiveDream.GetDream(self).player_escaped.emit()
	)
