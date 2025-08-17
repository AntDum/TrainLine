@icon("res://assets/icons/node_2D/goblin.png")
extends Node2D
class_name Goblin

signal finished_writing
signal said_text(text_line: int)
signal finished_script(number_said: int)
signal shushed


@export_multiline var scripts : Array[String] = []
@export var wait_time : float = 3

@export var auto_start : bool = false
@export var start_with_tuto : bool = true

@export var make_comment : bool = true

@onready var root_control: Control = $Control
@onready var rewrite_label: RewriteLabel = %RewriteLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $Control/Panel/MarginContainer

@onready var audio: RandomAudioPlayer = $Audio
@onready var timer: Timer = $PlayAgain/Timer

var dialogue_open := false
var in_script := false

var said_script : int = 0

func _ready() -> void:
	root_control.visible = false
	if auto_start:
		_start()
	if start_with_tuto:
		EventBus.started_tuto.connect(_start)

func _start() -> void:
	say_script(scripts, wait_time)
	
	
func _on_play_again_pressed() -> void:
	say_script(scripts, wait_time)
	
func say_script(texts: Array[String], time: float = -1) -> void:
	if in_script: return
	var line = 0
	in_script = true
	for text in texts:
		say(text)
		await finished_writing
		said_text.emit(line)
		if time > 0:
			await get_tree().create_timer(time).timeout
		line += 1
	shush()
	await shushed
	finished_script.emit(said_script)
	said_script += 1
	in_script = false
	timer.start()

func say(text: String, time: float = -1, sound: String = "Talk") -> void:
	if not dialogue_open:
		animation_player.play("show_dialogue")
		dialogue_open = true
		await animation_player.animation_finished
	rewrite_label.change_text(text)
	await rewrite_label.text_changed
	
	audio.play_sound(sound)
	rewrite_label.reset_size()
	
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
		await animation_player.animation_finished
	shushed.emit()

func _crashed(reason: String) -> void:
	if not make_comment: return
	say(reason, 2, "Angry")

func _out_of_fuel() -> void:
	if not make_comment: return
	say("Horwl ! Not enough fuel", 2, "Angry")


func _on_timer_timeout() -> void:
	say("Press me to talk again !", 3, "Growl")


func _enter_tree() -> void:
	EventBus.train_crashed.connect(_crashed)
	EventBus.out_of_time.connect(_out_of_fuel)

func _exit_tree() -> void:
	EventBus.train_crashed.disconnect(_crashed)
	EventBus.out_of_time.disconnect(_out_of_fuel)
