extends Node2D
class_name Level

@onready var tuto: Tuto = $CanvasLayer/Tuto
@onready var goblin: Goblin = $Goblin

func _ready() -> void:
	AudioManager.play_music("main_music")
	await get_tree().process_frame
	if goblin:
		goblin_theorie()
	if tuto:
		print("Launching tutorial")
		tuto.launch_tuto()
		await EventBus.finished_tuto
	EventBus.change_mode.emit(ModeHelper.Mode.EDIT)

func goblin_theorie() -> void:
	goblin.say_script([
		"Hello ! I'm friendly !",
		"How could you say that I'm not ?",
		"Look I will guide you here ! This is a very very long text to try and test my little goblin capabilities",
		"Just trust me !"
	], 3)
