extends ColorRect
class_name MagicFlip

var current_flip := 0.0 : set = _set_flip

var is_flipped := false

var tween : Tween

const REVERSE = preload("res://resources/shaders/reverse.gdshader")

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = true
	
func _set_flip(val : float) -> void:
	current_flip = val
	material.set_shader_parameter("flip_amount", val)

func _restart() -> void:
	flip_back()

func flip() -> void:
	if is_flipped:
		flip_back()
	else:
		flip_in()

func flip_in() -> void:
	if is_flipped: return
	is_flipped = true
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "current_flip", 1.0, 0.2)

func flip_back() -> void:
	if not is_flipped: return
	is_flipped = false
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "current_flip", 0.0, 0.2)

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)
	EventBus.flip_reality.connect(flip)
	EventBus.flip_back.connect(flip_back)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
	EventBus.flip_reality.disconnect(flip)
	EventBus.flip_back.disconnect(flip_back)
	
