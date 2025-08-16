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

func say_line(text: String, wait_time: float = 3.0) -> void:
	goblin.goblin_say(text)
	await goblin.finished_writing
	await get_tree().create_timer(wait_time).timeout

func goblin_theorie() -> void:
	await say_line("Hello ! I'm friendly !")
	await say_line("How could you say that I'm not ?")
	await say_line("Look I will guide you here ! This is a very very long text to try and test my little goblin capabilities")
	await say_line("Just trust me !")
	goblin.goblin_shush()
