extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(load("res://dreamlands/29-where-hell/hell-land.tscn").instantiate(),
	"rmA")
