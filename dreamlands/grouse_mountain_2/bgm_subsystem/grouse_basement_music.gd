extends Node

enum { SWEEPINGBUF }

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	SWEEPINGBUF,4,
])
var lerpval : float = 0.0
var exitval : float = 0.0

func set_sweep(_lerpval : float, _exitval : float):
	bufs.on(SWEEPINGBUF)
	self.lerpval = _lerpval
	self.exitval = _exitval
	# no music
	#if not $AudioStreamPlayer.playing:
		#$AudioStreamPlayer.volume_db = -40
		#$AudioStreamPlayer.play(27 / 8 * 3)

func _physics_process(delta: float) -> void:
	var s : AudioStreamPlayer = $AudioStreamPlayer
	if bufs.has(SWEEPINGBUF):
		s.volume_db = lerp(
			s.volume_db,
			lerp(-40, 0, sqrt(clamp(lerpval, 0, 1))),
			0.1)
	else:
		s.volume_db = lerp(
			s.volume_db,
			lerp(-40, 0, sqrt(clamp(exitval, 0, 1))),
			0.1)
		if exitval <= 0 and s.volume_db < -35: s.stop()
