extends Tuto

@onready var n_on_cart: Notification = $NOnCart
@onready var n_on_rail: Notification = $NOnRail

var tweener : Tween

func launch_tuto() -> void:
	if tweener:
		tweener.kill()
	var tweener = get_tree().create_tween()
	
	tweener.tween_callback(func(): n_on_cart.show_notification("Those will make you wait"))
	tweener.tween_callback(func(): n_on_rail.show_notification("<-"))
	
