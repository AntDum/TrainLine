extends Node2D
class_name Level

@onready var tuto: Tuto = $CanvasLayer/Tuto

func _ready() -> void:
	AudioManager.play_music("main_music")
	await get_tree().process_frame
	if tuto:
		print("Launching tutorial")
		tuto.launch_tuto()
