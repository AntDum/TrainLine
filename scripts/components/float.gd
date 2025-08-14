@icon("res://assets/icons/node_2D/icon_dialog.png")
extends Sprite2D
class_name FloatingSprite2D

# How far to move up/down in pixels
@export var hover_distance: float = 1.1
# How long one full up+down cycle takes
@export var hover_speed: float = 1.8

var _start_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_start_y = position.y

func _process(delta: float) -> void:
	_time += delta
	position.y = _start_y + sin(_time * TAU / hover_speed) * hover_distance
