extends Tuto

@onready var notification: Notification = $Notification
@onready var notifs2: Array[Notification] = [$Notification2, $Notification3, $Notification4]
@onready var notifs3: Array[Notification] = [$Notification5, $Notification6, $Notification7]

var tweener : Tween

func launch_tuto() -> void:
	if tweener:
		tweener.kill()
	var tweener = get_tree().create_tween()
	
	tweener.tween_callback(func(): notification.show_notification("Hey I'm here"))
	tweener.tween_interval(4.2)
	tweener.tween_callback(func(): notification.show_notification("I need to go there"))
	tweener.tween_callback(func(): notifs2[0].show_notification("<-"))
	tweener.tween_callback(func(): notifs2[1].show_notification("<-"))
	tweener.tween_callback(func(): notifs2[2].show_notification("<-"))
	
	tweener.tween_interval(4.2)
	tweener.tween_callback(func(): notification.show_notification("Then there"))
	tweener.tween_callback(func(): notifs3[0].show_notification("<-"))
	tweener.tween_callback(func(): notifs3[1].show_notification("<-"))
	tweener.tween_callback(func(): notifs3[2].show_notification("<-"))
	
	tweener.tween_interval(4.2)
	tweener.tween_callback(func(): notification.show_notification("But no the other way around"))
	
	tweener.tween_interval(2)
	tweener.tween_callback(func(): notification.show_notification("Good luck"))
	
