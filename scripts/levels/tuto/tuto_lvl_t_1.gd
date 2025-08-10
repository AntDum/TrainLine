extends Tuto

@onready var n_on_cart: Notification = $NOnCart
@onready var n_on_stock: Notification = $NOnStock
@onready var n_on_depot: Notification = $NOnDepot
@onready var n_on_top: Notification = $NOnTop

const n_on_cart_texts = ["","","Your minecart\nv",""]

const n_on_stock_texts = ["","","The gem\nv",""]

const n_on_depot_texts = ["","","^\nThe delivery\nstation",""]

const n_on_top_texts = [
	"Hello, I'm here to explain you\nhow to play.",
	"Your goal is to deliver every\ngem to the corresponding station.",
	"",
	"Press left click and drag to\nplace new rails.",
	"When you're done,\npress the \"START\" button.",
	"Good Luck !"]

var tweener : Tween
var current_step: int = 0

func next_step():
	current_step += 1
	var last_step = true
	
	if current_step < len(n_on_cart_texts):
		n_on_cart.show_notification(n_on_cart_texts[current_step])
		last_step = false
	if current_step < len(n_on_stock_texts):
		n_on_stock.show_notification(n_on_stock_texts[current_step])
		last_step = false
	if current_step < len(n_on_depot_texts):
		n_on_depot.show_notification(n_on_depot_texts[current_step])
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
