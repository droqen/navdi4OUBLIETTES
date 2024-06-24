extends Node2D

var goto_right : bool = true
var score : int = 0
var flickerbuf : int = 0

func _physics_process(delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	
	if flickerbuf > 0:
		flickerbuf -= 1
		if flickerbuf < 10: $score_label.show()
		else: call('show' if flickerbuf % 10 < 5 else 'hide')
	
	if player.get('last_onfloor'):
		if goto_right:
			if $right.get_overlapping_areas():
				goto_right = false
				score += 1
				reprint_score()
		else:
			if $left.get_overlapping_areas():
				goto_right = true
				score += 1
				reprint_score()
	
	if player.reallydead:
		player.revive($left.position if goto_right else $right.position)
	
func reprint_score():
	$score_label.text = "%d/10" % score
	if score == 10:
		flickerbuf = 60
		LiveDream.GetDream(self).windfish_awakened.emit()
	else:
		flickerbuf = 30
