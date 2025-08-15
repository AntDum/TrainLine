@icon("res://assets/icons/node_2D/icon_follow.png")
extends BaseStation
class_name TeleportStation

@export var target_station : TeleportStation = null

func _init() -> void:
	is_on = true
	need_satisfaction = false

func get_destination() -> Vector2i:
	return target_station.coord

func get_global_destination() -> Vector2:
	return rails.to_global(rails.map_to_local(target_station.coord))
