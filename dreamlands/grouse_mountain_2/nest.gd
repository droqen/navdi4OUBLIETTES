extends Node2D

@onready var all_chicks = [$chick1, $chick2, $chick3]

var hungry_chick_count : int = 3

const CLMESSAGES = [
	"\n ~the end :)",
	"my children!\njust one is still hungry",
	"my children!\ntwo are still hungry",
	"my children!\nthree are still hungry",
]

func _ready():
	for chick in all_chicks:
		chick.ate.connect(func():
			hungry_chick_count -= 1
			$hungryBabiesCL.text = CLMESSAGES[hungry_chick_count]
			if hungry_chick_count == 0:
				$hungryBabiesCTZ.disable_on_no_overlap = false
				$hungryBabiesCL.visible_characters = 0
			else:
				$hungryBabiesCL.visible_characters = 12
			#all_chicks.erase.call_deferred(chick)
		)

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	if player:
		var hungry_count : int = all_chicks.size()
		for i in range(hungry_count):
			var minx : int = -10
			var maxx : int = 12
			if i-1 >= 0: minx = all_chicks[i-1].position.x + 5
			if i+1 < hungry_count: maxx = all_chicks[i+1].position.x - 5
			all_chicks[i].manual_process(player, minx, maxx)
