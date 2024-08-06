extends Marker2D

const DesertPlayer = preload("res://dreamlands/desert-archive/desert_player.gd")

var gravity_increases : float = 0.0

func _enter_tree() -> void:
	gravity_increases = 0.0

func _physics_process(delta: float) -> void:
	var player : DesertPlayer = DesertPlayer.GetPlayer(self) as DesertPlayer
	if player:
		var to_sun : Vector2 = position - player.position
		if gravity_increases < 1: gravity_increases += 0.05 * delta
		if player.position.y < 40 and gravity_increases < 0.5:
			gravity_increases += 0.15 * delta # faster
		player.vel *= 1.0 - (0.03 * gravity_increases)
		player.vel += to_sun * 0.03 * gravity_increases
		if gravity_increases > 0.25:
			player.scale = lerp(player.scale, Vector2(-.001, -.001), 0.01 * gravity_increases)
			player.modulate = lerp(player.modulate, Color(0,0,0), 0.01 * gravity_increases)
			if player.scale.x <= .05:
				player.queue_free()
				LiveDream.GetDream(self).windfish_awakened.emit()
