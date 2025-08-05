extends VBoxContainer


func _on_button_pressed() -> void:
	var text = $HBoxContainer/TextEdit.text
	$RewriteLabel.change_text(text)
