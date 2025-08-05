extends Node2D
class_name Level

@onready var tuto: Tuto = $CanvasLayer/Tuto

func _ready() -> void:
	AudioManager.play_music("main_music")
	if tuto:
		tuto.launch_tuto()
