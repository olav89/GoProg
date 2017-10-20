#
# Script for the PC screen
#
#

extends Control

var selection = [] # contains code user has selected

var PATH_BUTTON_CONTAINER = "Panel/CodeBtn"
var PATH_SELECTION_LABEL = "Panel/CodeSelected"

func _ready():
	pass

# Initializer function called by the Level-script
# Input: code_array
# Output: Creates buttons for each element in the input array
func create_codes(code_array):
	var box = get_node(PATH_BUTTON_CONTAINER) 
	for code in code_array:
		var b = Button.new()
		b.set_text(code)
		b.set_theme(load("res://assets/theme/theme_btn_menu.tres"))
		box.add_child(b)
		b.connect("pressed", self, "button_pressed", [b])

# Event for pressed buttons
# Output: Adds code to selection and displays it to the user
func button_pressed(pressed):
	var selected = pressed.get_text()
	
	# checks if code has already been selected
	for s in selection:
		if s == selected:
			return
	
	get_tree().call_group(0, "player", "play_sample_typing")
	
	# if the code has not yet been selected add it and build output
	selection.append(selected)
	var output = "Terminal:\n"
	for s in selection:
		output += ">>> " + s + "\n"
	get_node(PATH_SELECTION_LABEL).set_text(output)

# Event for the Enter button
func _on_btnEnter_pressed():
	hide() # hide pc screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # capture mouse
	get_tree().call_group(0, "player", "change_status_activate")

# Event for the Clear button
func _on_btnClear_pressed():
	selection = [] # clear selection
	get_node(PATH_SELECTION_LABEL).set_text("Terminal:\n") # remove the shown selection
