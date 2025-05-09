extends StaticBody2D

var erk : float = 0
var openness : int = 0

func _physics_process(delta: float) -> void:
	var open : bool = $keyseeker.get_overlapping_areas() || $keyseeker.get_overlapping_bodies()
	$shape.disabled = open
	if open:
		erk += 5 * delta
		if erk > 0.5:
			if openness == 0: openness = 1
			else: openness += 2
			play_blip()
			erk -= 1
		if openness >= 9:
			erk = 0.0
	else:
		erk -= 5 * delta
		if erk < -0.5:
			if openness == 9: openness = 8
			else: openness -= 2
			play_blip()
			erk += 1
		if openness <= 0:
			erk = 0.0
	erk = move_toward(erk, 0.9 if open else 0.0, delta)
	$bottom.position.y = 0 + openness
	$top.position.y = -10 - openness

func play_blip() -> void:
	$AudioStreamPlayer.pitch_scale = remap(openness,0.0,9.0,1.5,2.5)
	$AudioStreamPlayer.play()
