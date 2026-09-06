class_name QwertzTypingHypotheses
extends RefCounted

## A transparent descriptive lookup for the P2a trials. Counts are route
## annotations, not a claim about a person's speed, comfort or ergonomics.

const KEY_DATA := {
	"Q": {"hand": "left", "finger": "little", "row": "top"}, "W": {"hand": "left", "finger": "ring", "row": "top"},
	"E": {"hand": "left", "finger": "middle", "row": "top"}, "R": {"hand": "left", "finger": "index", "row": "top"},
	"T": {"hand": "left", "finger": "index", "row": "top"}, "Z": {"hand": "right", "finger": "index", "row": "top"},
	"U": {"hand": "right", "finger": "index", "row": "top"}, "I": {"hand": "right", "finger": "middle", "row": "top"},
	"O": {"hand": "right", "finger": "ring", "row": "top"}, "P": {"hand": "right", "finger": "little", "row": "top"},
	"A": {"hand": "left", "finger": "little", "row": "home"}, "S": {"hand": "left", "finger": "ring", "row": "home"},
	"D": {"hand": "left", "finger": "middle", "row": "home"}, "F": {"hand": "left", "finger": "index", "row": "home"},
	"G": {"hand": "left", "finger": "index", "row": "home"}, "H": {"hand": "right", "finger": "index", "row": "home"},
	"J": {"hand": "right", "finger": "index", "row": "home"}, "K": {"hand": "right", "finger": "middle", "row": "home"},
	"L": {"hand": "right", "finger": "ring", "row": "home"},
	"Y": {"hand": "left", "finger": "little", "row": "bottom"}, "X": {"hand": "left", "finger": "ring", "row": "bottom"},
	"C": {"hand": "left", "finger": "middle", "row": "bottom"}, "V": {"hand": "left", "finger": "index", "row": "bottom"},
	"B": {"hand": "left", "finger": "index", "row": "bottom"}, "N": {"hand": "right", "finger": "index", "row": "bottom"},
	"M": {"hand": "right", "finger": "index", "row": "bottom"},
}

const FAMILIAR_SEQUENCE_HYPOTHESES := ["ASDFGH", "QWERT"]


static func key_description(letter: String) -> Dictionary:
	var normalized := letter.to_upper()
	if normalized.length() != 1:
		return {}
	var description: Dictionary = KEY_DATA.get(normalized, {})
	return description.duplicate(true)


static func describe(sequence: String) -> Dictionary:
	var letters := sequence.to_upper()
	var hand_changes := 0
	var row_changes := 0
	var finger_changes := 0
	var previous := {}
	for index in letters.length():
		var letter := letters.substr(index, 1)
		var key := key_description(letter)
		if key.is_empty():
			return {"valid": false, "unknown_letter": letter, "input_steps": letters.length()}
		if not previous.is_empty():
			if key["hand"] != previous["hand"]:
				hand_changes += 1
			if key["row"] != previous["row"]:
				row_changes += 1
			if key["finger"] != previous["finger"] or key["hand"] != previous["hand"]:
				finger_changes += 1
		previous = key
	return {"valid": true, "input_steps": letters.length(), "hand_changes": hand_changes, "row_changes": row_changes, "finger_changes": finger_changes, "familiar_sequence_hypothesis": FAMILIAR_SEQUENCE_HYPOTHESES.has(letters)}
