@tool
extends Label
class_name RewriteLabel

signal text_changed
signal finished_writing

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
var target_text : String

func _ready() -> void:
	if animate_on_ready:
		text = ""
	change_text(start_text)

func is_writing() -> bool:
	return tween and tween.is_running()

func change_text(new_text : String) -> void:
	if tween:
		tween.kill()
	target_text = new_text
	tween = create_tween()
	# Erase
	if text.length() > 0:
		tween.tween_property(self, "visible_ratio", 0, erase_duration)
		tween.tween_interval(in_between_delay)	
	else:
		visible_ratio = 0
	# Change Value
	tween.tween_callback(func(): text = new_text)
	tween.tween_callback(text_changed.emit)
	# Rewrite
	if new_text.length() > 0:
		tween.tween_property(self, "visible_ratio", 1, rewrite_duration)
	else:
		visible_ratio = 1
	
	tween.tween_callback(finished_writing.emit)

func skip() -> void:
	if not tween:
		return
	
	tween.kill()
	text = target_text
	visible_ratio = 1
	text_changed.emit()
	finished_writing.emit()
