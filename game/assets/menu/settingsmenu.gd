extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("TextureFrame/volumeSlider").set_value(get_parent().getSoundVolume())

func _show():
	show()

func _hide():
	hide()

func _on_btnBack_pressed():
	_hide()
	get_parent().get_node("IngameMenu")._show()

func _on_sounds_toggled( pressed ):
	pass

func _on_sounds_pressed():
	if(get_node("TextureFrame/sounds").is_pressed()):
		get_parent().enableSound()
	else:
		get_parent().disableSound()

func _on_volumeSlider_value_changed( value ):
	get_parent().setSoundVolume(float(value/100))
