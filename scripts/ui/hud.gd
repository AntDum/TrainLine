extends Control
class_name HUD

@onready var counter: Label = %counter
@onready var station: Label = %station
@onready var start_button: HoverButton = %StartButton

@export_range(0.01, 1.0, 0.01) var base_delay: float = 0.05
@export_range(0.01, 1.0, 0.01) var slow_delay: float = 0.3

var current_station = 0
var current_max = 0

var started : bool = false

func _ready() -> void:
	_update_station(current_station, current_max)
	EventBus.delay_changed.emit(base_delay)

func _on_start_button_pressed() -> void:
	if started:
		EventBus.restart.emit()
	else:
		EventBus.start.emit()

func _update_time(time : float) -> void:
	counter.text = "%d step" % time

func _update_station(cur: int, max: int) -> void:
	current_station = cur
	current_max = max
	if station:
		station.text = "%d / %d" % [current_station, current_max]


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		EventBus.delay_changed.emit(slow_delay)
	else:
		EventBus.delay_changed.emit(base_delay)

func _failed() -> void:
	started = true
	start_button.text = "RETRY"

func _restart() -> void:
	started = false
	start_button.text = "START"
	

func _enter_tree() -> void:
	EventBus.time_changed.connect(_update_time)
	EventBus.station_happy.connect(_update_station)
	EventBus.out_of_time.connect(_failed)
	EventBus.train_crashed.connect(_failed)
	EventBus.start.connect(_failed)
	EventBus.restart.connect(_restart)
	
func _exit_tree() -> void:
	EventBus.time_changed.disconnect(_update_time)
	EventBus.station_happy.disconnect(_update_station)
	EventBus.out_of_time.disconnect(_failed)
	EventBus.train_crashed.disconnect(_failed)
	EventBus.start.disconnect(_failed)
	EventBus.restart.disconnect(_restart)
