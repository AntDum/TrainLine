extends Node2D
class_name FollowMouse

@export var target : Node2D
@export_range(0.0, 1.0, 0.01) var weight : float = 0.8

func _process(delta: float) -> void:
	target.global_position = lerp(target.global_position, get_global_mouse_position(), weight)
