@icon("res://assets/icons/control/icon_text_panel.png")
extends Control

@onready var animated_control: AnimatedControl = $AnimatedControl

@onready var rewrite_label: RewriteLabel = %RewriteLabel
@onready var next_level_button: HoverButton = %NextLevelButton
@onready var retry_button: HoverButton = %RetryButton


func _train_crashed(_reason: String = "") -> void:
	_failed_level()
	rewrite_label.change_text("Oh no !\nYou cannot do that")

func _out_of_time() -> void:
	_failed_level()
	rewrite_label.change_text("Oh no !\nIt was too long")

func _failed_level() -> void:
	next_level_button.visible = false
	retry_button.visible = true
	animated_control.animate_show()
	

func _restart() -> void:
	animated_control.animate_hide()
	rewrite_label.change_text("")
	next_level_button.visible = false
	retry_button.visible = false
	
func _all_station_happy() -> void:
	animated_control.animate_show()
	if LevelManager.is_last_level():
		rewrite_label.change_text("You completed\nthe game !!\nThank you for playing")
	else:
		rewrite_label.change_text("Level %d\nCompleted !" % (LevelManager.current_level_id + 1))
		retry_button.visible = false
		next_level_button.visible = true
	

func _on_next_level_button_pressed() -> void:
	animated_control.animate_hide()
	LevelManager.get_to_next_level()

func _on_retry_button_pressed() -> void:
	EventBus.restart.emit()


func _enter_tree() -> void:
	#EventBus.train_crashed.connect(_train_crashed)
	#EventBus.out_of_time.connect(_out_of_time)
	EventBus.all_station_satisfied.connect(_all_station_happy)
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	#EventBus.train_crashed.disconnect(_train_crashed)
	#EventBus.out_of_time.disconnect(_out_of_time)
	EventBus.all_station_satisfied.disconnect(_all_station_happy)
	EventBus.restart.disconnect(_restart)
