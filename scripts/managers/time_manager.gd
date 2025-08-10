extends Node
class_name TimeManager

@export_range(0.01, 1.0, 0.01) var fast_delay: float = 0.05
@export_range(0.01, 1.0, 0.01) var base_delay: float = 0.2

var delay : float : set = _update_delay 
@export var auto_start : bool = false
@export var max_time = 200

var is_running : bool = false
var timer : Timer
var time : int = 0

func _ready() -> void:
	delay = base_delay
	_create_timer()
	await get_tree().process_frame
	EventBus.time_changed.emit(time, max_time)
	EventBus.delay_changed.emit(delay)
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fast_forward"):
		_fast_forward_on()
	elif event.is_action_released("fast_forward"):
		_fast_forward_off()

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

func _fast_forward_on() -> void:
	delay = fast_delay
	EventBus.delay_changed.emit(delay)

func _fast_forward_off() -> void:
	delay = base_delay
	EventBus.delay_changed.emit(delay)

func _stop() -> void:
	if timer:
		timer.stop()

func _enter_tree() -> void:
	EventBus.fast_forward_on.connect(_fast_forward_on)
	EventBus.fast_forward_off.connect(_fast_forward_off)
	EventBus.start.connect(_start)
	EventBus.restart.connect(_restart)
	EventBus.all_station_satisfied.connect(_stop)
	EventBus.train_crashed.connect(_stop)

func _exit_tree() -> void:
	EventBus.fast_forward_on.disconnect(_fast_forward_on)
	EventBus.fast_forward_off.disconnect(_fast_forward_off)
	EventBus.start.disconnect(_start)
	EventBus.restart.disconnect(_restart)
	EventBus.all_station_satisfied.disconnect(_stop)
	EventBus.train_crashed.disconnect(_stop)
