extends AnimatedControl


func _on_close_button_pressed() -> void:
	animate_hide()


func _on_rewrite_button_pressed() -> void:
	$Notification.show_notification("Rewrite clicked !")


func _on_counter_button_pressed() -> void:
	$Notification.show_notification("Counter clicked !")


func _on_hover_button_pressed() -> void:
	$Notification.show_notification("Omg you toggle the side bar !")
	$Sidebar.toggle()
