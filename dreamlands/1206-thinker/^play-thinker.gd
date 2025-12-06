extends Node
const DREAM = preload("res://dreamlands/1206-thinker/thinker-dream.tscn")
func play(dream:LiveDream):
	dream.goto_new_land(DREAM.instantiate(), "rmA")
