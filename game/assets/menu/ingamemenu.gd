#
# Script for the ingame menu
# Event methods are linked to buttons through Godot
#

extends Control

const PATH_MAIN_MENU = "res://assets/menu/mainmenu.tscn"

func _ready():
	pass

func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/logger").log_debug("Ingame Menu active")

func _hide():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node("/root/logger").log_debug("Ingame Menu inactive")

# Event for the Reset button
func _on_btnReset_pressed():
	get_node("/root/logger").log_info("Resetting scene.")
	# Reloads scene, but beware of changes to physics engine and such
	get_tree().reload_current_scene()

# Event for the Exit button
func _on_btnExit_pressed():
	get_node("/root/logger").log_info("Loading Main Menu.")
	# Changes the scene to main menu
	get_tree().change_scene(PATH_MAIN_MENU)

# Event for the Continue button
func _on_btnContinue_pressed():
	_hide()
