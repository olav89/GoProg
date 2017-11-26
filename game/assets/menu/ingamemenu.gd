# Script for the ingame menu
# Event methods are linked to buttons through Godot
extends Control

# Paths
var PATH_MAIN_MENU = "res://assets/menu/mainmenu.tscn"
var PATH_HELP_MENU = "res://assets/menu/helpmenu.tscn"
var PATH_LVL_SELECT = "res://assets/menu/levelmenu.tscn"

func _ready():
	pass

# Custom show function that also changes mouse mode
func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/logger").log_debug("Ingame Menu active")

# Custom hide function that also changes mouse mode
func _hide():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node("/root/logger").log_debug("Ingame Menu inactive")

# Event for the Reset button
func _on_btnReset_pressed():
	get_node("/root/logger").log_info("Resetting scene.")
	get_tree().reload_current_scene() # reload scene

# Event for the Exit button
func _on_btnExit_pressed():
	get_node("/root/logger").log_info("Loading Main Menu.")
	get_tree().change_scene(PATH_MAIN_MENU) # changes scene to main menu

# Event for the Continue button
func _on_btnContinue_pressed():
	_hide()

#Event for the Help Button
func _on_btnHelp_pressed():
	# Hides ingame menu shows help menu
	_hide()
	get_parent().get_node("HelpMenu")._show()

#Event for the Select Level button
func _on_btnSelectlvl_pressed():
	get_tree().change_scene(PATH_LVL_SELECT) # changes scene to level select

#Event for the Settings button
func _on_btnSettings_pressed():
	get_parent().get_node("Settings")._show()
