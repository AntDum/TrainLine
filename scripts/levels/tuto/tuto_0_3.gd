extends Tuto

@onready var n_on_fuel: Notification = $NOnFuel
@onready var n_on_top: Notification = $NOnTop

const n_on_fuel_texts = [""]

const n_on_top_texts = [
	"This is the final tutorial,\nthe next level will be the real game!",
	"The gem you transport are magical,\neach color correspond to a power.",
	"Try to deliver the blue gem,\nI'm sure you'll understand what it does."]

var tweener : Tween
var current_step: int = 0

func next_step():
	current_step += 1
	var last_step = true
	if current_step < len(n_on_fuel_texts):
		n_on_fuel.show_notification(n_on_fuel_texts[current_step])
		last_step = false
	if current_step < len(n_on_top_texts):
		n_on_top.show_notification(n_on_top_texts[current_step])
		last_step = false
	if last_step:
		print("Last step reached. Terminating tutorial.")
		hide()
		$NextButton.queue_free()


func launch_tuto() -> void:
	current_step = -1
	next_step()
	$NextButton.show()
