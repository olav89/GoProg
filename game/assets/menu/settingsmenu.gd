extends Control
var icon2 = load("res://assets/art/button_texture/001-speaker-1.tex")
var icon = load("res://assets/art/button_texture/002-speaker.tex")
func _ready():
	pass
	
func _show():
	get_node("TextureFrame/volumeSlider").set_value(get_parent().get_parent().get_node("Player").sample_player.getSoundVolume()*100)
	get_node("TextureFrame/volInlbl").set_text(str(get_node("TextureFrame/volumeSlider").get_value()))
	
	if(get_node("TextureFrame/volumeSlider").get_value()>0):
		get_node("TextureFrame/sounds").set_button_icon(icon)
	else: 
		get_node("TextureFrame/sounds").set_button_icon(icon2)
	
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
		get_parent().get_parent().get_node("Player").sample_player.enableSound()
		get_node("TextureFrame/volumeSlider").set_value(100)
		get_node("TextureFrame/volInlbl").set_text("100")
		get_node("TextureFrame/sounds").set_button_icon(icon)
	else:
		get_parent().get_parent().get_node("Player").sample_player.disableSound()
		get_node("TextureFrame/volumeSlider").set_value(0)
		get_node("TextureFrame/volInlbl").set_text("0")
		get_node("TextureFrame/sounds").set_button_icon(icon2)

#Event for volume slider
func _on_volumeSlider_value_changed( value ):
	get_parent().get_parent().get_node("Player").sample_player.setSoundVolume(float(value/100))
	get_node("TextureFrame/volInlbl").set_text(str(value))
	if( value>0):
		get_node("TextureFrame/sounds").set_button_icon(icon)
		get_node("TextureFrame/sounds").set_pressed(true)
	else:
		get_node("TextureFrame/sounds").set_button_icon(icon2)
		get_node("TextureFrame/sounds").set_pressed(false)


func _on_bounceslider_value_changed( value ):
	var lvlname = get_parent().get_parent().get_node("Player").level
	var lvlnode = get_parent().get_parent().get_parent()
	for node in lvlnode.get_children():
		if (node.get_filename() == "res://assets/objects/crate.tscn"):
			node.set_bounce(value/100)
			