@tool
extends Label
class_name AnimatedCounter

# 'value' is the target numeric value
@export var value: float = 0.0: set = set_value
# 'pattern' is used to format the displayed number. 
# For integers use "%d", for floats you can use something like "%.2f".
@export var pattern: String = "%d" : set =  _update_pattern

# Internal variable used during tween animation.
var _shown_value: float = 0.0 : set =  _update_shown_value

# Animation settings.
@export_category("Animation")
@export var transition: Tween.TransitionType = Tween.TRANS_LINEAR
@export var easing: Tween.EaseType = Tween.EASE_OUT
@export var duration: float = 1.0

var tween: Tween

# Updates the displayed text based on _shown_value.
func _update() -> void:
	text = pattern % _shown_value

# Called when a new value is set. This method initiates a tween animation.
func set_value(new_value: float) -> void:
	# Store the new value.
	value = new_value
	
	# If an animation is already running, stop it first.
	if tween:
		tween.kill()
	# Create and configure a new tween.
	tween = create_tween().set_trans(transition).set_ease(easing)
	# Animate the _shown_value property to the new 'value' over the specified duration.
	tween.tween_property(self, "_shown_value", value, duration)

# Called when _shown_value changes, updating the label text.
func _update_shown_value(new_value: float) -> void:
	_shown_value = new_value
	_update()

# Called when the pattern is updated in the Inspector.
func _update_pattern(new_pattern: String) -> void:
	pattern = new_pattern
	_update()

# Initialize _shown_value when the node is ready.
func _ready() -> void:
	_shown_value = value
	_update()
