extends TextureFrame

const PATH_LABEL = "Label"

var status_bar_time_remaining = 0
var status_bar_can_change = true
const STATUS_INTERACT = "Press E to interact"
const STATUS_INTERACT_TIME = 1
const STATUS_ACTIVATE = "Press F to activate your code"
const STATUS_ACTIVATE_TIME = 2
const STATUS_WON = "Proceed to the elevator"
const STATUS_WON_TIME = 15

func _ready():
	set_process(true)
func _process(delta):
	if status_bar_time_remaining > 0:
		status_bar_time_remaining -= delta
	elif not is_hidden():
		hide()
		status_bar_can_change = true

func change_status(text, time, permanent=false):
	if status_bar_can_change:
		if permanent:
			status_bar_can_change = false
		get_node(PATH_LABEL).set_text(text)
		show()
		status_bar_time_remaining = time
		get_node("/root/logger").log_debug("Status Bar: " + text + " - " + str(time))

func clear_status():
	status_bar_time_remaining = 0

func change_status_activate():
	change_status(STATUS_ACTIVATE, STATUS_ACTIVATE_TIME)

func change_status_interact():
	change_status(STATUS_INTERACT, STATUS_INTERACT_TIME)

func change_status_won():
	change_status(STATUS_WON, STATUS_WON_TIME, true)
