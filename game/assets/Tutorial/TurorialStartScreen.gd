extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func _hide():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _show():
	show()

func _on_btn_to_game_pressed():
	_hide()
