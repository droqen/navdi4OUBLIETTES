extends RefCounted
class_name TinyState
var id : int
var ongo : Callable
func _init(firstid : int, _ongo : Callable, block_starting_ongo : bool = false) -> void:
	self.id = firstid
	self.ongo = _ongo
	if not block_starting_ongo:
		ongo.call_deferred(id,id)
func goto(newid : int, force_ongo_signal : bool = false):
	if self.id != newid or force_ongo_signal:
		var previd = self.id
		self.id = newid
		ongo.call(previd, self.id)
