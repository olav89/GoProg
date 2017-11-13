#
# Script for the PC screen
#
#

extends Control

const PATH_BUTTON_CONTAINER = "Panel/CodeBtn"
const PATH_EDITOR = "Panel/Editor"
const PATH_DEBUG = "Panel/Debug"

var player_node = null

func setup(player):
	player_node = player

func _ready():
	pass

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
