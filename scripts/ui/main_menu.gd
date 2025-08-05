extends Control

func _ready() -> void:
	AudioManager.play_music("main_music")

func _on_play_button_pressed() -> void:
	LevelManager.get_to_first_level()
