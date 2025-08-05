extends Control

@onready var rewrite_label: RewriteLabel = %RewriteLabel
@onready var next_level_button: HoverButton = $NextLevelButton

func _train_crashed() -> void:
	rewrite_label.change_text("Oh no ! You cannot do that")
	_failed_level()

func _out_of_time() -> void:
	rewrite_label.change_text("Oh no ! It was too long")
	_failed_level()

func _failed_level() -> void:
	pass

func _retry() -> void:
	rewrite_label.change_text("")
	
func _all_station_happy() -> void:
	if LevelManager.is_last_level():
		rewrite_label.change_text("You completed the game !!\nThank you for playing")
	else:
		rewrite_label.change_text("Level Completed !")
		next_level_button.visible = true
	

func _on_next_level_button_pressed() -> void:
	LevelManager.get_to_next_level()


func _enter_tree() -> void:
	EventBus.train_crashed.connect(_train_crashed)
	EventBus.all_station_satisfied.connect(_all_station_happy)
	EventBus.out_of_time.connect(_out_of_time)
	EventBus.restart.connect(_retry)

func _exit_tree() -> void:
	EventBus.train_crashed.disconnect(_train_crashed)
	EventBus.all_station_satisfied.disconnect(_all_station_happy)
	EventBus.out_of_time.disconnect(_out_of_time)
	EventBus.restart.disconnect(_retry)
