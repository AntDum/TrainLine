extends Tuto

@onready var n_on_fuel: Notification = $NOnFuel
@onready var n_on_top: Notification = $NOnTop

const n_on_fuel_texts = ["Your fuel >",""]

const n_on_top_texts = [
	"You only have a limited amount of fuel\nfor your delivery.",
	"If your fuel reaches 0, you loose.",
	"This path is too long\nfor the amount of fuel you have.\nLet's improve it.",
	"Maintain right click to destroy\nrails.",
	"Now, place new rails and press START to try.",]

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
		%StartButton.show()
		hide()
		$NextButton.queue_free()


func launch_tuto() -> void:
	%StartButton.hide()
	current_step = -1
	next_step()
	$NextButton.show()
