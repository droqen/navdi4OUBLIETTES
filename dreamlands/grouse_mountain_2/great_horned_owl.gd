extends Node2D

var vel : Vector2
var faceleft : bool
var caught_player : bool

enum { PATROL, PRE_SWOOP, SWOOP, RECOVERY, 
	BIGFLAPBUF=1000, PREFLAPBUF, SWOOP_EXPIRE_BUF,
}

var bufs : Bufs = Bufs.Make(self).setup_bufons([BIGFLAPBUF,13, PREFLAPBUF,3, ])

var owlst : TinyState = TinyState.new( PATROL, func(_then,now):
	var mt : Vector2 = $owl.position
	match now:
		PATROL:
			if mt.x < randf_range(80,100): mt.x = randf_range(160,170)
			else: mt.x = randf_range(10,20)
			mt.y = -30
		PRE_SWOOP:
			if mt.x < $player_target.position.x:
				# im to the left of player:
				mt = $player_target.position + (50.0) * Vector2(-1,-1)
			else:
				# im to the right of player:
				mt = $player_target.position + (50.0) * Vector2(1,-1)
		SWOOP:
			mt = $player_target.position + Vector2(0,0) # go for it!
		RECOVERY:
			var rise_amount : float = abs(mt.y - randf_range(-30,30))
			if mt.x < randf_range(80,100): mt.x += rise_amount / 2
			else: mt.x -= rise_amount / 2
			mt.y -= rise_amount
			$player_target.position = Vector2(90, 165) # recenter
	$move_target.position = mt
)

func _enter_tree() -> void:
	self.position = Vector2.ZERO # always zero
	faceleft = randf() < 0.5
	$player_target.position = Vector2(90, 165)
	$owl.position = Vector2(randf_range(19,180-19), -30)
	vel = Vector2.ZERO
	owlst.goto(PATROL)
	caught_player = false

func _exit_tree() -> void:
	if true or owlst.id in [PRE_SWOOP, SWOOP]:
		var player = NavdiSolePlayer.GetPlayer(self)
		if player:
			var oldplayerpos : Vector2 = player.position
			var tree = get_tree()
			await tree.create_timer(0.2).timeout
			var newroom = LiveDream.GetRoom(player)
			if newroom: 
				var newowl = null
				for child in newroom.get_children():
					if child.get('owlst'):
						newowl = child
				var pos_offset = player.position - oldplayerpos
				prints("POS OFFSET", pos_offset)
				if newowl:
					newowl.get_node("owl").position = $owl.position + pos_offset
					newowl.get_node("move_target").position = $move_target.position + pos_offset
					newowl.get_node("player_target").position = $player_target.position + pos_offset
					newowl.vel = vel
					newowl.owlst.goto(owlst.id)
					newowl.faceleft = faceleft
	
func try_flap() -> bool:
	if bufs.read(BIGFLAPBUF) > 5: return false; # failed, can't flap that frequently
	if vel.y < 0: vel.y *= 0.5
	vel.y -= 0.8
	bufs.setmin(BIGFLAPBUF,13)
	bufs.setmin(PREFLAPBUF,3)
	return true;

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	var to_mt : Vector2 = $move_target.position - $owl.position
	if player and player.visible:
		$player_target.position = player.position
	var to_plr : Vector2 = $player_target.position - $owl.position
	# movement
	vel.y += 0.03
	if to_mt.y + 2.0*vel.y < -5 or (vel.y > 2.0 and owlst.id != SWOOP):
		if try_flap():
			if to_mt.x:
				vel.x += sign(to_mt.x) * 0.1
	vel.x = move_toward(vel.x, clampf(to_mt.x * 0.1, -2.0, 2.0), 0.02)
	if to_mt: faceleft = to_mt.x < 0
	if vel.y > 0:
		var rotty = vel.angle_to(to_mt)
		vel = vel.rotated(clamp(rotty,-0.12,0.12))
	if to_mt.length() < 10:
		var rotty = vel.angle_to(to_mt)
		vel = vel.rotated(clamp(rotty,-0.22,0.22))
	$owl.position += vel
	
	# flap animation
	if bufs.has(PREFLAPBUF):
		$owl/wing.setup([23])
	elif bufs.has(BIGFLAPBUF):
		$owl/wing.setup([33])
	else:
		$owl/wing.setup([23])
	
	if caught_player:
		$owl/talons.setup([35])
	else:
		$owl/talons.setup([34])
	
	$owl.scale.x = -1 if faceleft else 1
	
	# update state
	match owlst.id:
		PATROL:
			if to_mt.length_squared() < 10 or $owl.position.x < 10 or $owl.position.x > 170:
				owlst.goto(PATROL, true)
			elif $player_target.position.y < randf_range(125,150):
				owlst.goto(PRE_SWOOP)
		PRE_SWOOP:
			# the goal is to get to a 45 degree from the player. then swoop.
			
			if randf()<0.1 and (not player or not player.visible):
				owlst.goto(RECOVERY)
			elif abs(abs(to_plr.x)-abs(to_plr.y)) < 10:
				owlst.goto(SWOOP) # go for it buddy
			elif to_mt.length_squared() < 10:
				if not player or not player.visible:
					owlst.goto(RECOVERY)
				else:
					owlst.goto(PRE_SWOOP, true) # reposition
		SWOOP:
			for area in $owl/player_catcher.get_overlapping_areas():
				if area.get_parent().get('IS_PLAYER_GROUSE'):
					area.get_parent().queue_free()
					caught_player = true
					owlst.goto(RECOVERY)
					break
			if not caught_player:
				$move_target.position = $player_target.position # target.
				if player and player.visible:
					$move_target.position += player.vel * 2.0 + Vector2(0,-3)
				if abs(vel.angle_to(to_mt)) > PI*0.5:
					if not bufs.has(SWOOP_EXPIRE_BUF): bufs.setmin(SWOOP_EXPIRE_BUF,randi() % 20)
				if bufs.read(SWOOP_EXPIRE_BUF) == 1:
					owlst.goto(RECOVERY)
		RECOVERY:
			if to_mt.length_squared() < 10 or to_mt.y > 0:
				owlst.goto(PATROL)
