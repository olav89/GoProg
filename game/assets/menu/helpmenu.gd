#
# Script for the help menu
# Event methods are linked to buttons through Godot
#
extends Control

var PATH_CONTROL_HELP_PAGE = "res://assets/menu/helpcontrols.tscn"
var PATH_VC_HELP_PAGE = "res://assets/menu/victoryhelpscreen.tscn"
var PATH_IN_GAME_MENU = "res://assets/menu/ingamemenu.tscn"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_btnControls_pressed():
	get_node("ControlScreen")._show()


func _on_btnVC_pressed():
	get_node("VictoryHelp")._show()


func _on_btnBack_pressed():
	hide()
	

func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
