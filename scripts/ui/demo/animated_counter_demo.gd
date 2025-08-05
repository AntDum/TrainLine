extends VBoxContainer


func _on_button_pressed() -> void:
	var value = $HBoxContainer/TextEdit.text
	var pattern = $HBoxContainer/TextEdit2.text
	$AnimatedCounter.pattern = pattern
	$AnimatedCounter.value = value
