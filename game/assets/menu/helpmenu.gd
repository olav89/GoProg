#
# Script for the help menu
# Event methods are linked to buttons through Godot
#
extends Control

func _ready():
	pass

#Event for Controls button
func _on_btnControls_pressed():
	get_node("ControlScreen")._show()
	

#Event for Victory Help button
func _on_btnVC_pressed():
	get_node("VictoryHelp")._show()

#Event for Back button
func _on_btnBack_pressed():
	hide()
	get_parent().get_node("IngameMenu").show()

func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _hide():
	hide()
