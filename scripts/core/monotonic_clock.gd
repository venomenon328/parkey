class_name MonotonicClock
extends RefCounted

func now_usec() -> int:
	return Time.get_ticks_usec()


class Manual extends MonotonicClock:
	var current_usec := 0

	func now_usec() -> int:
		return current_usec
