# Script for the level menu
# The loading is done as the tutorial at: 
# http://docs.godotengine.org/en/latest/learning/features/misc/background_loading.html

extends TextureFrame

const PATH_LEVEL_MENU = "res://assets/menu/levelmenu.tscn"
const PATH_LEVELS = "res://assets/levels/"
const PATH_TIP = "lblTip"

# Number of levels
var num_levels = 30

# The loader used to get new scene
var loader

# Text tips to draw randomly from
var tips = [
"Levels can often be solved with many different strategies!",
"Creativity is critical!",
"Variables never forget your birthday!",
"If you keep repeating the same lines of code try a loop!",
"The reviews are in, and everyone hates these messages!",
"If you're happy and you know it, make a func!",
"Damages caused by cannons will be taken out of your paycheck!",
"no crates were hurt in the making of this game"
]
var tip_opacity = 0.2
var tip_delta = 0.01

# Adds buttons to the scene and connect them
func _ready():
	var box = get_node("Levels")

	num_levels = _num_lvls()
	for i in range(1, num_levels + 1):
		var b = Button.new()
		var icon = load("res://assets/art/button_texture/Pressed_lift_button.tex")
		b.set_text(str(i))
		if(checkSaved(b)):
			b.set_button_icon(icon)
		box.add_child(b) # add button to box, no need to adjust positions
		b.connect("pressed", self, "button_pressed", [b])
		
	var tip_index = floor(rand_range(0, tips.size()))
	get_node(PATH_TIP).set_text("\"" + tips[tip_index] + "\"")
	set_fixed_process(true)

func checkSaved(b):
	
	var btn_text = b.get_text()
	var lvls=[]
	for i in range(num_lvls_of("var")):
		lvls.append("var")
	for i in range(num_lvls_of("for")):
		lvls.append("for")
	for i in range(num_lvls_of("ifl")):
		lvls.append("ifl")
	for i in range(num_lvls_of("oth")):
		lvls.append("oth")
	var check

	if(lvls[int(btn_text)-1] == "var"):
		check= "var_" + btn_text
	elif(lvls[int(btn_text)-1] == "for"):
		 check= "for_" + str(int(btn_text)-lvls.find("for"))
	elif(lvls[int(btn_text)-1] == "ifl"):
		check = "ifl_" + str(int(btn_text)-lvls.find("ifl"))
	elif(lvls[int(btn_text)-1] == "oth"):
		check = "oth_" + str(int(btn_text)-lvls.find("oth"))
	var svg = loadSaveGame()
	print(svg.size())
	if(svg!=null):
		for i in range(svg.size()):
			if svg[i] == check:
				return true
	else:
		print(b)
		return false

func _fixed_process(delta):
	tip_opacity += tip_delta
	if tip_opacity <= 0.2 or tip_opacity >= 1.0:
		tip_delta *= -1
	get_node(PATH_TIP).set_opacity(tip_opacity)

# Event for loading a new scene
func button_pressed(pressed):
	
	var btn_text = pressed.get_text()	
	var lvls=[]
	for i in range(num_lvls_of("var")):
		lvls.append("var")
	for i in range(num_lvls_of("for")):
		lvls.append("for")
	for i in range(num_lvls_of("ifl")):
		lvls.append("ifl")
	for i in range(num_lvls_of("oth")):
		lvls.append("oth")
	
	if(lvls[int(btn_text)-1] == "var"):
		goto_scene( PATH_LEVELS + "var_" + btn_text + ".tscn")
	elif(lvls[int(btn_text)-1] == "for"):
		goto_scene( PATH_LEVELS + "for_" + str(int(btn_text)-lvls.find("for")) + ".tscn")
	elif(lvls[int(btn_text)-1] == "ifl"):
		goto_scene( PATH_LEVELS + "ifl_" + str(int(btn_text)-lvls.find("ifl"))  + ".tscn")
	elif(lvls[int(btn_text)-1] == "oth"):
		goto_scene( PATH_LEVELS + "oth_" + str(int(btn_text)-lvls.find("oth"))  + ".tscn")
	
func num_lvls_of(type):
	var files = []
	var dir = Directory.new()
	dir.open("res://assets/levels")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if file.begins_with(type):
				if file.ends_with(".gd"):
					files.append(file)
		
	dir.list_dir_end()
	return files.size()

# Loads a new scene
func goto_scene(path): 
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		get_node("/root/logger").log_error("Loading failed to start: " + path)
		return
	set_process(true)
	get_node("ProgressBar").show()
	get_node("/root/logger").log_info("Loading start: " + path)

func _num_lvls():
	var files = []
	var dir = Directory.new()
	dir.open("res://assets/levels")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if file.ends_with(".gd"):
				files.append(file)
	
	dir.list_dir_end()
	return files.size()

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
	var saves=[]
	currline = savegame.get_line()
	while(!savegame.eof_reached()):
		saves.append(currline)
		currline = savegame.get_line()
	savegame.close()
	return saves


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
