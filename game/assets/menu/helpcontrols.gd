
# Script for the help controls menu
# Event methods are linked to buttons through Godot

extends Control

func _ready():
	pass

func _show():
	show()

func _hide():
	hide()

#event for the back button
func _on_btnBack_pressed():
	_hide()
	get_parent()._show()
