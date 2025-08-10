extends Control
class_name HUD

@onready var counter: Label = %counter
@onready var station: Label = %station
@onready var start_button: HoverButton = %StartButton


var current_station = 0
var current_max = 0

var started : bool = false

var tuto_going = false;

func _ready() -> void:
	_update_station(current_station, current_max)

func _update_time(time : int, max_time : int) -> void:
	if counter:
		counter.text = "%d fuel" % (max_time - time)

func _update_station(cur: int, max: int) -> void:
	current_station = cur
	current_max = max
	if station:
		station.text = "%d / %d" % [current_station, current_max]

func _on_start_button_pressed() -> void:
	if tuto_going: return
	if started:
		EventBus.restart.emit()
	else:
		EventBus.start.emit()

func _on_fast_press() -> void:
	if tuto_going: return
	EventBus.fast_forward_on.emit()

func _on_fast_released() -> void:
	if tuto_going: return
	EventBus.fast_forward_off.emit()
	
func _on_clear_clicked() -> void:
	if tuto_going: return
	EventBus.clear.emit()

func _failed() -> void:
	started = true
	start_button.text = "RETRY"

func _restart() -> void:
	started = false
	start_button.text = "START"
	
func _started_tuto() -> void:
	tuto_going = true

func _finished_tuto() -> void:
	tuto_going = false

func _enter_tree() -> void:
	EventBus.started_tuto.connect(_started_tuto)
	EventBus.finished_tuto.connect(_finished_tuto)
	EventBus.time_changed.connect(_update_time)
	EventBus.station_happy.connect(_update_station)
	EventBus.out_of_time.connect(_failed)
	EventBus.train_crashed.connect(_failed)
	EventBus.start.connect(_failed)
	EventBus.restart.connect(_restart)
	
func _exit_tree() -> void:
	EventBus.started_tuto.disconnect(_started_tuto)
	EventBus.finished_tuto.disconnect(_finished_tuto)
	EventBus.time_changed.disconnect(_update_time)
	EventBus.station_happy.disconnect(_update_station)
	EventBus.out_of_time.disconnect(_failed)
	EventBus.train_crashed.disconnect(_failed)
	EventBus.start.disconnect(_failed)
	EventBus.restart.disconnect(_restart)
