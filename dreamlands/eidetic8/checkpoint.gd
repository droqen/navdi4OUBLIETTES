extends Node2D

enum { NOTACTIVE, ACTIVE, }

var flagst : TinyState = TinyState.new(NOTACTIVE, func(_then,now):
	match now:
		NOTACTIVE:
			$flagspr.setup([4])
			$yay.one_shot = true
			$yay.emitting = false
		ACTIVE:
			$flagspr.setup([5,6,7,8],8)
			$yay.one_shot = true
			$yay.restart() # emitting = true?
			# TODO make other flags not active
			
)

func _ready() -> void:
	$plrdet.area_entered.connect(func(_area):
		flagst.goto(ACTIVE)
	)
