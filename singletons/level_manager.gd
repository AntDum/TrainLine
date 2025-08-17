extends Node

const LEVELS = [
	# TUTO
	^"res://scenes/levels/tutorial/level_tuto_1.tscn",
	^"res://scenes/levels/tutorial/level_tuto_2.tscn",
	^"res://scenes/levels/tutorial/level_tuto_3.tscn",
	^"res://scenes/levels/tutorial/level_tuto_blue.tscn",
	^"res://scenes/levels/tutorial/level_tuto_red.tscn",
	^"res://scenes/levels/tutorial/level_tuto_purple.tscn",
	^"res://scenes/levels/tutorial/level_tuto_white.tscn",
	
	# Blue
	^"res://scenes/levels/slowness/level_1_1.tscn",
	^"res://scenes/levels/slowness/level_1_2.tscn",
	^"res://scenes/levels/slowness/level_1_3.tscn",
	^"res://scenes/levels/slowness/level_1_4.tscn",
	
	# Red
	^"res://scenes/levels/dynamite/level_4_1.tscn",
	^"res://scenes/levels/dynamite/level_4_2.tscn",
	
	# White
	^"res://scenes/levels/mirrors/level_2_1.tscn",
	
	# Purple
	^"res://scenes/levels/portal/level_3_1.tscn",
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
