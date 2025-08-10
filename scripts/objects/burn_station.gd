extends BaseStation
class_name BurnStation

signal burned

func _init() -> void:
	is_on = true

func burn() -> void:
	burned.emit()
