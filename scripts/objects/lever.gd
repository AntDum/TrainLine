extends Area2D
class_name Lever

signal activate(toggle: bool)

@export var toggled = false

@onready var sprite_lever: Sprite2D = $SpriteLever

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggled = not toggled
		_update_sprite()
		activate.emit(toggled)
		
func _update_sprite() -> void:
	sprite_lever.frame = 0 if not toggled else 1
