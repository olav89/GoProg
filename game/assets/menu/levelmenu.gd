#
# Script for the level menu
# 
#

extends TextureFrame

var PATH_LEVELS = "res://assets/levels/"

var num_levels = 1

func _ready():
	var box = get_node("Levels") # Vertical Box Container
	for i in range(1, num_levels + 1):
		var b = Button.new()
		b.set_text("Level" + str(i))
		box.add_child(b) # add button to box, no need to adjust positions
		b.connect("pressed", self, "button_pressed", [b])

# Event for loading a new scene
func button_pressed(pressed):
	var btn_text = pressed.get_text()
	get_tree().change_scene(PATH_LEVELS + btn_text + ".tscn")
