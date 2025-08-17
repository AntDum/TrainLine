extends BaseStation
class_name BurnStation

signal burned

@export var dynamite : Dynamite

func _init() -> void:
	is_on = true

func burn() -> void:
	burned.emit()
	if dynamite:
		dynamite.explode()
