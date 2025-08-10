extends BaseStation
class_name BurnStation

signal burned

func burn() -> void:
	burned.emit()
