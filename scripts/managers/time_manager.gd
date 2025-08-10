extends Node
class_name TimeManager

@export_range(0.05, 2, 0.05) var delay : float = 0.1 : set = _update_delay 
@export var auto_start : bool = false
@export var max_time = 200

var is_running : bool = false
var timer : Timer
var time : int = 0

func _ready() -> void:
	_create_timer()
	EventBus.time_changed.emit(time, max_time)
	if auto_start:
		_start()

func _restart() -> void:
	is_running = false
	timer.stop()
	time = 0
	EventBus.time_changed.emit(time, max_time)

func _start() -> void:
	if is_running: return
	is_running = true
	timer.start()

func _timeout() -> void:
	time += 1
	if max_time > 0 and time > max_time:
		EventBus.out_of_time.emit()
		timer.stop()
	EventBus.step.emit(time)
	EventBus.time_changed.emit(time, max_time)

func _create_timer() -> void:
	timer = Timer.new()
	timer.timeout.connect(_timeout)
	timer.wait_time = delay
	timer.autostart = false
	timer.one_shot = false
	add_child(timer)

func _update_delay(new_value : float) -> void:
	delay = new_value
	if timer:
		timer.wait_time = new_value

func _stop() -> void:
	if timer:
		timer.stop()

func _enter_tree() -> void:
	EventBus.delay_changed.connect(_update_delay)
	EventBus.start.connect(_start)
	EventBus.restart.connect(_restart)
	EventBus.all_station_satisfied.connect(_stop)
	EventBus.train_crashed.connect(_stop)

func _exit_tree() -> void:
	EventBus.delay_changed.disconnect(_update_delay)
	EventBus.start.disconnect(_start)
	EventBus.restart.disconnect(_restart)
	EventBus.all_station_satisfied.disconnect(_stop)
	EventBus.train_crashed.disconnect(_stop)
