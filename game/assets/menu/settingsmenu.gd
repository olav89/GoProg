extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _show():
	get_node("TextureFrame/volumeSlider").set_value(get_parent().sample_player.getSoundVolume())
	get_node("TextureFrame/volInlbl").set_text(str(get_node("TextureFrame/volumeSlider").get_value()))
	show()

func _hide():
	hide()

#Event for Back button
func _on_btnBack_pressed():
	_hide()
	get_parent().get_node("IngameMenu")._show()

##Evnet for mute button
func _on_sounds_pressed():
	if(get_node("TextureFrame/sounds").is_pressed()):
		get_parent().sample_player.enableSound()
		get_node("TextureFrame/volumeSlider").set_value(100)
		get_node("TextureFrame/volInlbl").set_text("100")
	else:
		get_parent().sample_player.disableSound()
		get_node("TextureFrame/volumeSlider").set_value(0)
		get_node("TextureFrame/volInlbl").set_text("0")

#Event for volume slider
func _on_volumeSlider_value_changed( value ):
	get_parent().sample_player.setSoundVolume(float(value/100))
	get_node("TextureFrame/volInlbl").set_text(str(value))
