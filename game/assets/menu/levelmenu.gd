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

# Event for loading a new scene
func button_pressed(pressed):
	var btn_text = pressed.get_text()
	goto_scene(PATH_LEVELS + btn_text + ".tscn")

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