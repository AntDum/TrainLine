@tool
extends Label
class_name RewriteLabel

@export_multiline var start_text : String = "":
	set(value):
		start_text = value
		text = value
@export var animate_on_ready : bool = true

@export_group("Animation")
@export var erase_duration : float = 1
@export var in_between_delay : float = 0.1
@export var rewrite_duration : float = 1

var tween : Tween

func _ready() -> void:
	if animate_on_ready:
		text = ""
	change_text(start_text)

func change_text(new_text : String) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	# Erase
	if text.length() > 0:
		tween.tween_property(self, "visible_ratio", 0, erase_duration)
		tween.tween_interval(in_between_delay)	
	else:
		visible_ratio = 0
	# Change Value
	tween.tween_callback(func(): text = new_text)
	
	# Rewrite
	if new_text.length() > 0:
		tween.tween_property(self, "visible_ratio", 1, rewrite_duration)
	else:
		visible_ratio = 1
	
