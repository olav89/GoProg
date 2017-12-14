# Script for the level menu
# The loading is done as the tutorial at: 
# http://docs.godotengine.org/en/latest/learning/features/misc/background_loading.html

extends TextureFrame

const PATH_LEVEL_MENU = "res://assets/menu/levelmenu.tscn"
const PATH_LEVELS = "res://assets/levels/Level"

# Number of levels
var num_levels = 30

# The loader used to get new scene
var loader

# Adds buttons to the scene and connect them
func _ready():
	var box = get_node("Levels")
	var svg = loadSaveGame()
	var icon = load("res://assets/art/button_texture/Pressed_lift_button.tex")
	for i in range(1, num_levels + 1):
		var b = Button.new()
		b.set_text(str(i))
		box.add_child(b) # add button to box, no need to adjust positions
		b.connect("pressed", self, "button_pressed", [b])
		if svg != null:
			if svg[i-1]==1:
				b.set_button_icon(icon)

# Event for loading a new scene
func button_pressed(pressed):
	var btn_text = pressed.get_text()
	goto_scene(PATH_LEVELS + btn_text + ".tscn")

# Loads a new scene
func goto_scene(path): 
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		get_node("/root/logger").log_error("Loading failed to start: " + path)
		return
	set_process(true)
	get_node("ProgressBar").show()
	get_node("/root/logger").log_info("Loading start: " + path)
	

# Poll loader and check outcome
func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	# poll loader
	var err = loader.poll()
	
	if err == ERR_FILE_EOF: # load finished
		var resource = loader.get_resource()
		loader = null
		set_new_scene(resource)
	elif err == OK:
		update_progress()
	else: # error during loading
		get_node("/root/logger").log_error("Loading error.")
		loader = null

# Updates the progress bar
func update_progress():
	var progress = 100*(float(loader.get_stage() + 1) / float(loader.get_stage_count()))
	get_node("ProgressBar").set_value(progress)

# Add loaded scene into tree and remove current scene
func set_new_scene(scene_resource):
	var current = get_tree().get_root().get_child( get_tree().get_root().get_child_count() -1 )
	current.queue_free()
	current = scene_resource.instance()
	get_tree().get_root().add_child(current)
	get_tree().set_current_scene(current)
	get_node("/root/logger").log_info("Loading complete.")

#loads compleeted lvls and returns array if savegame exists
func loadSaveGame():
	var savegame = File.new()
	if(!savegame.file_exists("user://savegame.save")):
		get_node("/root/logger").log_error("No savegame file")
		return null
	var currline={}
	savegame.open("user://savegame.save", File.READ)
	currline = savegame.get_line()
	var res = IntArray()
	for i in range(100):
		res.append(0)
	while(!savegame.eof_reached()):
		var lvlhelp = currline.substr(5,2)
		var lvl = lvlhelp
		if(lvl != " " and int(lvl) >= 1):
			res.set(int(lvl) - 1,1)
		currline = savegame.get_line()
	savegame.close()
	return res


func _on_btnReset_pressed():
	var savegame = File.new()
	if(!savegame.file_exists("user://savegame.save")):
		get_node("/root/logger").log_error("No savegame file")
		return null
	savegame.open("user://savegame.save",File.WRITE)
	savegame.store_line("")
	savegame.close()
	get_node("/root/logger").log_info("Progression reset")
	get_node("/root/logger").log_info("Loading Level Menu.")
	get_tree().change_scene(PATH_LEVEL_MENU)
