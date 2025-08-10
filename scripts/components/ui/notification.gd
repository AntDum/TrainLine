extends Label
class_name Notification

@export var display_duration: float = 42.0
@export var appear_duration: float = 0.3
@export var hide_duration: float = 0.3

var tween: Tween


func show_notification(message: String) -> void:
	text = message
	pivot_offset = size / 2
	
	visible = true
	
	if tween:
		tween.kill()

	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), appear_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).from(Vector2.ZERO)
	tween.tween_interval(display_duration)
	tween.tween_property(self, "scale", Vector2(0, 0), hide_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		visible = false
	)
