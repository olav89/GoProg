extends Control

func _ready():
	pass

func _hide():
	if(get_node("Panel/lblInPc").is_visible()):
		hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()

func _show():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_parent().get_node("defaultenviroment/Player")._set_is_in_menu(true)

func _on_btn_to_game_pressed():
	_hide()
