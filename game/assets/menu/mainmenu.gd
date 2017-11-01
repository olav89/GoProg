#
# Script for Main Menu
#
#

extends TextureFrame

const PATH_LEVEL_MENU = "res://assets/menu/levelmenu.tscn"

func _ready():
	pass

func _on_btnStart_pressed():
	get_tree().change_scene(PATH_LEVEL_MENU)

func _on_btnQuit_pressed():
	get_tree().quit()
