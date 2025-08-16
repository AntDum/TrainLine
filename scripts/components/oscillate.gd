extends Sprite2D
class_name Oscillate

# How far to move up/down in pixels
@export var oscillate_distance: float = 0.6
# How long one full up+down cycle takes
@export var oscillate_speed: float = 8

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	var mod = (1 + oscillate_distance) + sin(_time * TAU / oscillate_speed) * oscillate_distance
	mod = clamp(mod, 1, 5)
	modulate = Color(mod, mod, mod)
