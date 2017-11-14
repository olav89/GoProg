#
# Script for the PC screen
#
#

extends Control

const PATH_BUTTON_CONTAINER = "Panel/CodeBtn"
const PATH_EDITOR = "Panel/Editor"
const PATH_DEBUG = "Panel/Debug"
const PATH_HELP_GROUP = "Panel/btnHelpGroup"
const PATH_CONFIRM_DIALOG = "Panel/AcceptDialog"

var player_node = null

var help_buttons = [
	["Inverting Gravity", 
	"""
	To invert gravity use the following functions:
	invert_gravity_room(), invert_gravity_player()
	"""],
	["Moving Cube",
	"""
	To move the cube use either of the functions:
	move_cube_left(d), move_cube_right(d),
	move_cube_forward(d), move_cube_backward(d)
	where d is the distance you want to move it.
	"""]
	]

func setup(player):
	player_node = player

func _ready():
	get_node(PATH_EDITOR).set_wrap(true)
	get_node(PATH_DEBUG).set_readonly(true)
	
	for help in help_buttons:
		var b = Button.new()
		b.set_text(help[0])
		b.connect("pressed", self, "popup_help", [b, help[1]])
		get_node(PATH_HELP_GROUP).add_child(b)

func popup_help(b, text):
	get_node(PATH_CONFIRM_DIALOG).set_text(text)
	get_node(PATH_CONFIRM_DIALOG).show()

func get_editor_text():
	var res = []
	var count = get_node(PATH_EDITOR).get_line_count()
	for i in range(count):
		var line = get_node(PATH_EDITOR).get_line(i)
		if line.length() > 0:
			res.append(line)
	return res
	
func set_editor_debug_text(s):
	get_node(PATH_DEBUG).set_text(s)

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
	get_node("/root/logger").log_debug("PC Screen code built")
	_hide()
	if player_node != null:
		player_node.status_bar.change_status_activate() # notify player node to change status
	else:
		get_node("/root/logger").log_error("player_node undefined in PCScreen.gd")

# Event for the Clear button
func _on_btnClear_pressed():
	get_node(PATH_EDITOR).set_text("")
	get_node("/root/logger").log_debug("PC Screen clear")


func _on_btnBuild_pressed():
	get_tree().call_group(0, "execute_code_group", "fix_code")
