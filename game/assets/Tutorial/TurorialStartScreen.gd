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

func _on_btn_to_game_pressed():
	_hide()
	if get_parent().tcheck1 and not get_parent().tcheck2:
		get_parent().set_jcheck(true)
	if not get_parent().tcheck1:
		get_parent().set_jcheck2(true)
	

