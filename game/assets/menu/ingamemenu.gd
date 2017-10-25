#
# Script for the ingame menu
# Event methods are linked to buttons through Godot
#

extends Control

var PATH_MAIN_MENU = "res://assets/menu/mainmenu.tscn"

func _ready():
	set_process_input(true)

func _input(event):
	if Input.is_action_pressed("ingame_menu") and is_visible():
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Event for the Reset button
func _on_btnReset_pressed():
	# Reloads scene, but beware of changes to physics engine and such
	get_tree().reload_current_scene()

# Event for the Exit button
func _on_btnExit_pressed():
	# Changes the scene to main menu
	get_tree().change_scene(PATH_MAIN_MENU)

# Event for the Continue button
func _on_btnContinue_pressed():
	hide() # Hide the ingame menu from user
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Capture mouse cursor
