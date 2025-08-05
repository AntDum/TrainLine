extends Tuto

@onready var n_on_cart: Notification = $NOnCart
@onready var n_on_stock: Notification = $NOnStock
@onready var n_on_depot: Notification = $NOnDepot

var tweener : Tween

func launch_tuto() -> void:
	if tweener:
		tweener.kill()
	var tweener = get_tree().create_tween()
	
	tweener.tween_callback(func(): n_on_cart.show_notification("You cannot edit those"))
	tweener.tween_callback(func(): n_on_stock.show_notification("<-"))
	
	tweener.tween_interval(4.2)
	tweener.tween_callback(func(): n_on_cart.show_notification("You cannot go on those\nwithout a valid cargo"))
	tweener.tween_callback(func(): n_on_depot.show_notification("<-"))
	
