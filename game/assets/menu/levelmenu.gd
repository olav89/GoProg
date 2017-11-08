#
# Script for the level menu
# The loading is done as the tutorial at: 
# http://docs.godotengine.org/en/latest/learning/features/misc/background_loading.html

extends TextureFrame

const PATH_LEVELS = "res://assets/levels/Level"

var num_levels = 30

var loader

func _ready():
	var box = get_node("Levels") # Vertical Box Container
	for i in range(1, num_levels + 1):
		var b = Button.new()
		b.set_text(str(i))
		box.add_child(b) # add button to box, no need to adjust positions
		b.connect("pressed", self, "button_pressed", [b])
		print(b.get_path())
	loadSaveGame()
	

# Event for loading a new scene
func button_pressed(pressed):
	var btn_text = pressed.get_text()
	goto_scene(PATH_LEVELS + btn_text + ".tscn")
	print(pressed.get_path())
	
func goto_scene(path): # game requests to switch to this scene
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		get_node("/root/logger").log_error("Loading failed to start: " + path)
		return
	set_process(true)
	get_node("ProgressBar").show()
	get_node("/root/logger").log_info("Loading start: " + path)
	

func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	# poll your loader
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

func update_progress():
	var progress = 100*(float(loader.get_stage() + 1) / float(loader.get_stage_count()))
	get_node("ProgressBar").set_value(progress)

func set_new_scene(scene_resource):
	var current = get_tree().get_root().get_child( get_tree().get_root().get_child_count() -1 )
	current.queue_free()
	current = scene_resource.instance()
	get_tree().get_root().add_child(current)
	get_tree().set_current_scene(current)
	get_node("/root/logger").log_info("Loading complete.")

func loadSaveGame():
	var savegame = File.new()
	if(!savegame.file_exists("user://savegame.save")):
		get_node("/root/logger").log_error("No savegame file")
	var currline={}
	savegame.open("user://savegame.save", File.READ)
	currline = savegame.get_line()
	while(!savegame.eof_reached()):
		var lvlhelp = currline.substr(5,2)
		var lvl = int(lvlhelp)
		var lvlboolhelp = currline.substr(8,2)
		var lvlbool = int(lvlboolhelp)
		if(lvlbool == 1 ):
			var help = "/root/Background/Levels/@@" + str(lvl +1)
			print(get_node(help))
			var image = load("res://assets/art/button_texture/Pressed_lift_button.tex")
			get_node(help).set_button_icon(image)

		
		currline = savegame.get_line()
	savegame.close()
