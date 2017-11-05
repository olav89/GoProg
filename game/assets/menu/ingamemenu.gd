#
# Script for the ingame menu
# Event methods are linked to buttons through Godot
#

extends Control

var PATH_MAIN_MENU = "res://assets/menu/mainmenu.tscn"
var PATH_HELP_MENU = "res://assets/menu/helpmenu.tscn"
var PATH_LVL_SELECT = "res://assets/menu/levelmenu.tscn"

func _ready():
	pass

func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _hide():
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
	_hide()

#Event for the Help Button
func _on_btnHelp_pressed():
	# Hides ingame menu shows help menu
	#_hide()
	get_node("HelpMenu")._show()



func _on_btnSelectlvl_pressed():
	get_tree().change_scene(PATH_LVL_SELECT)
	

func _on_btnSaveGame_pressed():
	saveGame()

func saveGame():
	var savegame = File.new()
	savegame.open("user://savegame.save",File.WRITE)
	var savenodes = get_parent().get_tree().get_nodes_in_group("Persist")
	for i in savenodes:
		var nodedata = i.save()
		savegame.store_line(nodedata.to_json())
	savegame.close()
	
func load():
	var savegame= File.new()
	var if !savegame.file_exists("user://savegame.save"):
		return #ERROR NO FILE
	
	var savenodes = get_parent().get_tree().get_nodes_in_group("Persist")


func save():
	var savedict = {
		filename = get_filename(),
		parent = get_parent().get_path(),
		posx = get_pos().x,
		posy = get_pos().y,
	}
	return savedict
