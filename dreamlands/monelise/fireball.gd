extends Node2D

enum {ST_ROLLING, ST_POPPING}

enum {ROTBUF, POPBUF,}
var bufs = Bufs.Make(self).setup_bufons([ROTBUF,5, POPBUF,30])
var fireballst = TinyState.new(ST_ROLLING, func (_from_,to):
	match to:
		ST_POPPING:
			$SheetSprite.setup([23,24,24],17)
			bufs.on(POPBUF)
, true)
var faceleft : bool = false
func setup(faceleft : bool):
	self.faceleft = faceleft
	$SheetSprite.flip_h = faceleft
	return self

func _physics_process(delta: float) -> void:
	match fireballst.id:
		ST_ROLLING:
			if not bufs.has(ROTBUF):
				$SheetSprite.rotation += PI * (-0.5 if self.faceleft else 0.5)
				bufs.on(ROTBUF)
			if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, -1.5 if self.faceleft else 1.5):
				fireballst.goto(ST_POPPING)
				for i in range($mover/solidcast.get_collision_count()):
					var hit_target = $mover/solidcast.get_collider(i)
					if hit_target.has_method("take_damage"):
						hit_target.take_damage()
		ST_POPPING:
			if not bufs.has(POPBUF):
				queue_free() # byee
		
