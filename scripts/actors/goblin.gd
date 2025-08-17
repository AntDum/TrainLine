@icon("res://assets/icons/node_2D/goblin.png")
extends Node2D
class_name Goblin

signal finished_writing
signal said_text(text_line: int)

var dialogue_open := false

@export var scripts : Array[String] = []
@export var wait_time : float = 3

@export var auto_start : bool = false

@onready var root_control: Control = $Control
@onready var rewrite_label: RewriteLabel = %RewriteLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $Control/Panel/MarginContainer

func _ready() -> void:
	root_control.visible = false
	if auto_start:
		say_script(scripts, wait_time)

func say_script(texts: Array[String], time: float = -1) -> void:
	var line = 0
	for text in texts:
		say(text)
		await finished_writing
		said_text.emit(line)
		if time > 0:
			await get_tree().create_timer(time).timeout
		line += 1
	shush()

func say(text: String, time: float = -1) -> void:
	if not dialogue_open:
		animation_player.play("show_dialogue")
		dialogue_open = true
		await animation_player.animation_finished
	rewrite_label.change_text(text)
	await rewrite_label.text_changed
	rewrite_label.reset_size()
	var tween = create_tween()
	root_control.offset_bottom = -8 - rewrite_label.size.y/2
	await rewrite_label.finished_writing
	finished_writing.emit()
	if time > 0:
		await get_tree().create_timer(time).timeout
		shush()

func shush() -> void:
	rewrite_label.change_text("")
	await rewrite_label.finished_writing
	if dialogue_open:
		animation_player.play("remove_dialogue")
		dialogue_open = false
