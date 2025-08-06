extends CPUParticles2D

func _ready() -> void:
	finished.connect(_on_finished)
	restart()

func _on_finished() -> void:
	queue_free()
