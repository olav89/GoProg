#
# Script for the PC screen
#
#

extends Control

const PATH_BUTTON_CONTAINER = "Panel/CodeBtn"
const PATH_SELECTION_LABEL = "Panel/CodeSelected"
const PATH_SELECTION_LINE_NUM = "Panel/CodeSelected/NumLines"
const TERMINAL = ""

var selection = [] # contains code user has selected
var output_current = TERMINAL
var output_target = TERMINAL

var player_node = null

func setup(player):
	player_node = player

func _ready():
	set_process(true)
	var s = ""
	for i in range(1, 30):
		if i < 10:
			s += "0" + str(i) + "|\n"
		else:
			s += str(i) + "|\n"
	get_node(PATH_SELECTION_LINE_NUM).set_text(s)

func _process(delta):
	if output_current.length() != output_target.length():
		output_current = output_target.substr(0, output_current.length() + 1)
		get_node(PATH_SELECTION_LABEL).set_text(output_current)

# Initializer function called by the Level-script
# Input: code_array
# Output: Creates buttons for each element in the input array
func create_codes(code_array):
	var box = get_node(PATH_BUTTON_CONTAINER) 
	for code in code_array:
		var b = Button.new()
		b.set_text(code)
		#b.set_theme(load("res://assets/theme/theme_btn_menu.tres"))
		box.add_child(b)
		b.connect("pressed", self, "button_pressed", [b])

# Event for pressed buttons
# Output: Adds code to selection and displays it to the user
func button_pressed(pressed):
	var selected = pressed.get_text()
	get_node("/root/logger").log_info("Player selected: " + selected)
	# checks if code has already been selected
	for s in selection:
		if s == selected:
			return
	if player_node != null:
		player_node.play_sample_typing() # notify player node to play typing sound
	else:
		get_node("/root/logger").log_error("player_node undefined in PCScreen.gd")
	# if the code has not yet been selected add it and build output
	selection.append(selected)
	output_target += selected + "\n"
	

func _show():
	show() 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/logger").log_debug("PC Screen active")

func _hide():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node("/root/logger").log_debug("PC Screen inactive")

# Event for the Enter button
func _on_btnEnter_pressed():
	get_node("/root/logger").log_debug("PC Screen code compiled")
	_hide()
	if player_node != null:
		player_node.change_status_activate() # notify player node to change status
	else:
		get_node("/root/logger").log_error("player_node undefined in PCScreen.gd")

# Event for the Clear button
func _on_btnClear_pressed():
	selection = [] # clear selection
	output_current = TERMINAL
	output_target = TERMINAL
	get_node(PATH_SELECTION_LABEL).set_text(output_current)
	get_node("/root/logger").log_debug("PC Screen clear")
