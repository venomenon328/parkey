class_name CourseIdentity
extends RefCounted

const SCHEMA_VERSION := "course-identity-v1"
const NUMBER_DECIMALS := 3


static func build(course: CourseData, profile: RuleProfile) -> String:
	var canonical := canonical_serialize({
		"schema": SCHEMA_VERSION,
		"graph": course.canonical_graph_data(),
		"layout": course.canonical_layout_data(),
		"rules": profile.identity_data(),
	})
	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(canonical.to_utf8_buffer())
	return "%s:%s" % [SCHEMA_VERSION, hasher.finish().hex_encode()]


static func canonical_serialize(value) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_INT:
			return str(value)
		TYPE_FLOAT:
			var quantized := snappedf(float(value), 0.001)
			if is_equal_approx(quantized, roundf(quantized)):
				return str(int(roundf(quantized)))
			return "%.*f" % [NUMBER_DECIMALS, quantized]
		TYPE_STRING:
			return JSON.stringify(value)
		TYPE_ARRAY:
			var items: Array[String] = []
			for item in value:
				items.append(canonical_serialize(item))
			return "[%s]" % ",".join(items)
		TYPE_DICTIONARY:
			var keys: Array[String] = []
			for raw_key in value.keys():
				keys.append(str(raw_key))
			keys.sort()
			var pairs: Array[String] = []
			for key in keys:
				pairs.append("%s:%s" % [JSON.stringify(key), canonical_serialize(value[key])])
			return "{%s}" % ",".join(pairs)
		_:
			return JSON.stringify(str(value))
