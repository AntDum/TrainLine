extends Node

const LEVELS = [
	^"res://scenes/levels/level_t_1.tscn",
	^"res://scenes/levels/level_t_2.tscn",
	^"res://scenes/levels/level_t_3.tscn",
	^"res://scenes/levels/level_b_1.tscn",
	^"res://scenes/levels/level_editor.tscn",
	^"res://scenes/levels/level_h_1.tscn",
]

var current_level_id = -1

func is_first_level() -> bool:
	return current_level_id == 0

func is_last_level() -> bool:
	return current_level_id == len(LEVELS) - 1

func get_current_level() -> String:
	return LEVELS[current_level_id]

func get_to_first_level() -> void:
	current_level_id = 0
	SceneManager.swap_scene(get_current_level())	

func get_to_next_level() -> void:
	if not is_last_level():
		current_level_id += 1
		SceneManager.swap_scene(get_current_level())
