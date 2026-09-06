class_name RunIdGenerator
extends RefCounted

## A result ID belongs to the completion snapshot, never to a save attempt.
## The timestamp/counter/random suffix makes independently restarted local
## sessions collision-resistant without deriving identity from score data.

var _counter := 0
var _random := RandomNumberGenerator.new()
var _scripted_ids: Array[String] = []


func _init(scripted_ids: Array = []) -> void:
	_random.randomize()
	for value in scripted_ids:
		_scripted_ids.append(str(value))


func next_id() -> String:
	if not _scripted_ids.is_empty():
		return _scripted_ids.pop_front()
	_counter += 1
	return "run-v1-%d-%d-%d-%08x" % [
		Time.get_unix_time_from_system(),
		Time.get_ticks_usec(),
		_counter,
		_random.randi(),
	]
