extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/wings-groundless/groundLAND.tscn").instantiate(),
		"rmA"
	)
	var leftfrom : String = 'NOWHERE'
	await d.player_escaped.connect(func(escapedfrom):
		match escapedfrom:
			'rmEternalFlight':
				d.windfish_lucidwake.emit(leftfrom)
			_:
				leftfrom = escapedfrom
				d.goto_new_land(
				load("res://dreamlands/wings-groundless/groundLAND.tscn").instantiate(),
					"rmEternalFlight"
				)
	)
