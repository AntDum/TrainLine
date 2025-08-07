extends Tuto

@onready var n_on_cart: Notification = $Notification
@onready var n_on_rail: Notification = $Notification2

var tweener : Tween

func launch_tuto() -> void:
	if tweener:
		tweener.kill()
	var tweener = get_tree().create_tween()
	
	tweener.tween_callback(func(): n_on_cart.show_notification("You cannot place rail on those"))
	tweener.tween_callback(func(): n_on_rail.show_notification("<-"))
	
