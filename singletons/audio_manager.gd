extends Node

var current_music_player : AudioStreamPlayer = null

func play_sound(name: String) -> void:
	var audio_player : AudioStreamPlayer = get_node(name)
	if not audio_player:
		push_warning("Unknown sound : %s" % name)
		return
	audio_player.play()

func stop_sound(name: String) -> void:
	var audio_player : AudioStreamPlayer = get_node(name)
	if not audio_player:
		push_warning("Unknown sound : %s" % name)
		return
	audio_player.stop()

func play_music(name: String) -> void:
	var audio_player = get_node(name)
	if not audio_player:
		push_warning("Unknown sound : %s" % name)
		return
	if audio_player == current_music_player: return
	else:
		if current_music_player: current_music_player.stop()
		audio_player.play()
		current_music_player = audio_player
