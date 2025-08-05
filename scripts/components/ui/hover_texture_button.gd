extends TextureButton
class_name HoverTextureButton

var tween : Tween
@export var scaling : float = 1.2

func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

func _reset() -> void:
	pivot_offset = size / 2
	if tween:
		tween.kill()

func _on_pressed() -> void:
	AudioManager.play_sound("click")

func _on_mouse_entered() -> void:
	_reset()
	AudioManager.play_sound("hover")
	tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * scaling, 0.15)

func _on_mouse_exited() -> void:
	_reset()
	tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
