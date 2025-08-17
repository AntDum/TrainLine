@icon("res://assets/icons/control/icon_screen_effect.png")
extends Control
class_name HUD

@onready var counter: Label = %counter
@onready var station: Label = %station

@onready var current_mode_label: Label = %CurrentMode

@onready var mode_button: HoverButton = %ModeButton
@onready var clear_button: HoverButton = %ClearButton
@onready var fast_forward_button: HoverButton = %FastForwardButton
@onready var start_button: HoverButton = %StartButton


const ADD_CURSOR = preload("res://assets/sprites/cursors/add_cursor.png")
const REMOVE_CURSOR = preload("res://assets/sprites/cursors/remove_cursor.png")
const SWAP_CURSOR = preload("res://assets/sprites/cursors/swap_cursor.png")

var current_station = 0
var current_max = 0

var modes = [
	ModeHelper.Mode.EDIT,
	ModeHelper.Mode.REMOVE,
	ModeHelper.Mode.TOGGLE
]
var current_mode = 0;

var started : bool = false
var tuto_going := false;
var failed := false

var tween_restart_button : Tween

func _ready() -> void:
	_update_station(current_station, current_max)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		_on_start_button_pressed()

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


func _on_fast_forward_button_pressed() -> void:
	if tuto_going: return
	if failed: 
		_show_restart_button()
		return
	if not started:
		EventBus.start.emit()

func _on_fast_press() -> void:
	if tuto_going: return
	EventBus.fast_forward_on.emit()

func _on_mode_button_pressed() -> void:
	EventBus.change_mode.emit(modes[(current_mode + 1) % 3])

func _on_fast_released() -> void:
	if tuto_going: return
	EventBus.fast_forward_off.emit()
	
func _on_clear_clicked() -> void:
	if tuto_going: return
	if failed: 
		_show_restart_button()
		return
	EventBus.clear.emit()

func _failed(_reason: String = "") -> void:
	failed = true
	_started()

func _started() -> void:
	started = true
	start_button.text = "RETRY"

func _restart() -> void:
	started = false
	start_button.text = "START"
	failed = false

func _show_restart_button() -> void:
	if tween_restart_button:
		tween_restart_button.kill()
	
	start_button.pivot_offset = start_button.size / 2
	tween_restart_button = (create_tween()
		.set_parallel(false)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_ELASTIC))
	tween_restart_button.tween_property(start_button, "scale", Vector2(1.3, 1.3), 0.3).from(Vector2(1, 1))
	tween_restart_button.parallel().tween_property(start_button, "modulate", Color(0, 1, 0), 0.3).from(Color(1, 1, 1))
	tween_restart_button.tween_property(start_button, "modulate", Color(1, 1, 1), 0.2)
	tween_restart_button.parallel().tween_property(start_button, "scale", Vector2(1, 1), 0.2)
	
func _started_tuto() -> void:
	tuto_going = true
	mode_button.disabled = true
	clear_button.disabled = true
	fast_forward_button.disabled = true
	start_button.disabled = true

func _finished_tuto() -> void:
	tuto_going = false
	mode_button.disabled = false
	clear_button.disabled = false
	fast_forward_button.disabled = false
	start_button.disabled = false

func _mode_changed(mode: ModeHelper.Mode) -> void:
	current_mode = modes.find(mode)
	match mode:
		ModeHelper.Mode.EDIT:
			Input.set_custom_mouse_cursor(ADD_CURSOR)
			current_mode_label.text = "INSERT"
		ModeHelper.Mode.REMOVE:
			Input.set_custom_mouse_cursor(REMOVE_CURSOR)
			current_mode_label.text = "REMOVE"
		ModeHelper.Mode.TOGGLE:
			Input.set_custom_mouse_cursor(SWAP_CURSOR)
			current_mode_label.text = "SWAP"

func _enter_tree() -> void:
	EventBus.started_tuto.connect(_started_tuto)
	EventBus.finished_tuto.connect(_finished_tuto)
	EventBus.time_changed.connect(_update_time)
	EventBus.station_happy.connect(_update_station)
	EventBus.out_of_time.connect(_failed)
	EventBus.train_crashed.connect(_failed)
	EventBus.start.connect(_started)
	EventBus.restart.connect(_restart)
	EventBus.change_mode.connect(_mode_changed)
	EventBus.need_restart.connect(_show_restart_button)
	
func _exit_tree() -> void:
	EventBus.started_tuto.disconnect(_started_tuto)
	EventBus.finished_tuto.disconnect(_finished_tuto)
	EventBus.time_changed.disconnect(_update_time)
	EventBus.station_happy.disconnect(_update_station)
	EventBus.out_of_time.disconnect(_failed)
	EventBus.train_crashed.disconnect(_failed)
	EventBus.start.disconnect(_started)
	EventBus.restart.disconnect(_restart)
	EventBus.change_mode.disconnect(_mode_changed)
	EventBus.need_restart.disconnect(_show_restart_button)
