extends Label

func _physics_process(_delta: float) -> void:
	var d = Time.get_datetime_dict_from_system(true)
	var start = dhms_to_value(14,0,0,0)
	var now = dhms_to_value(d.day,d.hour,d.minute,d.second)
	var end = dhms_to_value(21,0,0,0)
	var toll : int = int(floor(remap(
		now,
		start,end,
		42000,99999
	)))
	text = "%02d,%03d" % [toll/1000,toll%1000]

func dhms_to_value(
	day:float, hour:float, minute:float, second:float
) -> float:
	return day*86400 + hour*3600 + minute*60 + second
