extends Node2D
class_name Dynamite

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var explosion: CPUParticles2D = $Explosion

func explode() -> void:
	sprite_2d.visible = false
	AudioManager.play_sound("explosion")
	explosion.emitting = true

func reset() -> void:
	sprite_2d.visible = true

func _enter_tree() -> void:
	EventBus.restart.connect(reset)

func _exit_tree() -> void:
	EventBus.restart.disconnect(reset)
