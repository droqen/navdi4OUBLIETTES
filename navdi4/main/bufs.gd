extends Node
class_name Bufs

var default_on : int = 10
var bufdic : Dictionary
var bufons : Dictionary

static func Make(parent : Node) -> Bufs:
	var bufs = Bufs.new()
	parent.add_child(bufs)
	bufs.owner = parent.owner if parent.owner else parent
	return bufs

func setup_bufons(bufon_array : Array) -> Bufs:
	for i in range(0, len(bufon_array)-1, 2):
		bufons[bufon_array[i]] = bufon_array[i+1]
	return self

func _physics_process(_delta: float) -> void:
	for key in bufdic.keys():
		if bufdic[key] > 0:
			bufdic[key] -= 1

func clr(key:int):
	bufdic[key]=0
	
func has(key:int)->bool:
	return bufdic.get(key,0) > 0

func read(key:int)->int:
	return bufdic.get(key,0)

func setmin(key:int,minval:int):
	if bufdic.get(key,0)<minval: bufdic[key]=minval

func on(key:int):
	setmin(key, bufons.get(key, default_on))

func try_eat(keys:PackedInt32Array)->bool:
	for key in keys: if not read(key): return false
	for key in keys: clr(key)
	return true
