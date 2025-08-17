@icon("res://assets/icons/control/icon_call.png")
extends Control
class_name Tuto

@export var goblin : Goblin

func _ready() -> void:
	goblin.said_text.connect(_on_goblin_said_text)
	goblin.finished_script.connect(_on_goblin_finished_script)

func _on_goblin_said_text(text_line: int) -> void:
	for child in get_children():
		if child is TutoNotification:
			if child.step == text_line:
				child.show_notification(child.line)

func launch_tuto() -> void:
	EventBus.started_tuto.emit()

func _on_goblin_finished_script(time: int) -> void:
	if time == 0:
		EventBus.finished_tuto.emit()
