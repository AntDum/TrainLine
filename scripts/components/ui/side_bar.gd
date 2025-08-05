extends Control
class_name Sidebar

@export var slide_duration: float = 0.4
@export var slide_offset: float = 300.0
@export var is_open: bool = false

var tween: Tween

func _ready() -> void:
	visible = is_open

func toggle():
	if tween:
		tween.kill()
	
	tween = create_tween()
	if is_open:
		# Slide out to hide
		tween.tween_property(self, "position:x", -slide_offset, slide_duration).from(0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(func(): is_open = false)
	else:
		# Slide in to show
		visible = true
		tween.tween_property(self, "position:x", 0, slide_duration).from(-slide_offset).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func(): is_open = true)
