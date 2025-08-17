@icon("res://assets/icons/node/icon_audio.png")
extends Node
class_name RandomAudioPlayer

func play_sound(name: String) -> void:
	var node_sound : Node = get_node(name)
	if not node_sound:
		push_warning("Unknown sound : %s" % name)
		return
	if node_sound.get_child_count() == 0:
		push_warning("No audio player: %s" % name)
		return
	node_sound.get_children().pick_random().play()
