extends Control
class_name AnimatedControl

# Enum for directional choices.
enum Direction { UP, LEFT, DOWN, RIGHT }

# Choose the directions for showing and hiding the control.
@export var show_direction: Direction = Direction.UP
@export var hide_direction: Direction = Direction.DOWN

# How far off-screen the control should start or end its animation.
@export var offset_distance: float = 1000.0
@export var overshoot_distance: float = 50.0

# Helper function to calculate the offset vector based on the direction.
func _get_offset(direction: Direction, strength: float) -> Vector2:
	match direction:
		Direction.LEFT:
			return Vector2(-strength, 0)
		Direction.RIGHT:
			return Vector2(strength, 0)
		Direction.UP:
			return Vector2(0, -strength)
		Direction.DOWN:
			return Vector2(0, strength)
	return Vector2.ZERO

func _reverse(direction: Direction) -> Direction:
	return (direction+2) % 4

# Animate the control into view.
func animate_show() -> void:
	# Save the target position.
	var target_pos = global_position
	# Start off-screen using the chosen show direction.
	global_position = target_pos + _get_offset(show_direction, offset_distance)
	visible = true

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	# First part: overshoot the target by a small amount.
	tween.tween_property(self, "global_position", target_pos + _get_offset(_reverse(show_direction), overshoot_distance), 0.3)
	# Then, settle to the final target position.
	tween.tween_property(self, "global_position", target_pos, 0.1)

# Animate the control out of view.
func animate_hide() -> void:
	# Save the current position.
	var target_pos = global_position

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# First, slightly move the control to give a more organic transition.
	tween.tween_property(self, "global_position", target_pos + _get_offset(_reverse(hide_direction), overshoot_distance), 0.1)
	# Then, move the control off-screen using the chosen hide direction.
	tween.tween_property(self, "global_position", target_pos + _get_offset(hide_direction, offset_distance), 0.3)
	# Once the tween is done, hide the control and reset its position.
	tween.tween_callback(func() -> void:
		visible = false
		global_position = target_pos
	)
