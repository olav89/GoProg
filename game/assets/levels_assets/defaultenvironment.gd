extends Spatial

const DEFAULT = "defaultenviroment/"
const PATH_PLAYER = DEFAULT + "Player"
const PATH_GUI = DEFAULT + "GUI"
var journal_text
var PATH_PC = DEFAULT + "PC"
var editor_text = ""
var PATH_CRATE
var PATH_TV

var eval_node

var is_level_won = false

var help_buttons
var help_button_selection

var gravity_direction_room = -1
var gravity_direction_room_old = 0
var gravity_direction_player = -1
var gravity_direction_player_old = 0

var gravity_timer
signal gravity_finished

func _ready():
	# adds to group so it gets notified when player wants to execute code
	add_to_group("execute_code_group")
	set_fixed_process(true)
	#set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func run_setup():
	get_node(PATH_PLAYER).setup(get_node("."), get_node(PATH_GUI))
	set_help_buttons()
	get_node(PATH_PC).get_screen().setup(get_node(PATH_GUI), help_buttons, editor_text)
	get_node(PATH_GUI).set_journal_text(journal_text)

func set_help_buttons():
	var all_buttons = get_node("/root/execute").get_help_buttons()
	help_buttons = []
	for i in range(all_buttons.size()):
		if help_button_selection == null or help_button_selection.find(i) > -1:
			help_buttons.append(all_buttons[i])

func _fixed_process(delta):
	set_gravity()

# Adjusts gravity for player and the room
func set_gravity():
	if gravity_direction_room != gravity_direction_room_old:
		PhysicsServer.area_set_param(get_world().get_space(), 
		PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
		Vector3(0, gravity_direction_room, 0))
		gravity_direction_room_old = gravity_direction_room
		add_gravity_timer()
	elif gravity_direction_player != gravity_direction_player_old:
		get_node(PATH_PLAYER).gravity_direction = gravity_direction_player
		gravity_direction_player_old = gravity_direction_player
		add_gravity_timer()

# Adds a timer when gravity changes so effects can happen before next code execution
func add_gravity_timer():
	if gravity_timer == null:
		gravity_timer = Timer.new()
		gravity_timer.connect("timeout",self,"gravity_timer_finished")
		gravity_timer.set_one_shot(true)
		add_child(gravity_timer)
	gravity_timer.set_wait_time( 2 )
	gravity_timer.start()

# When gravity timer is done emit a signal for the next code to execute
func gravity_timer_finished():
	emit_signal("gravity_finished")

# Call this when a level is completed
func won():
	if !is_level_won:
		is_level_won = true
		get_node(DEFAULT + "GUI").change_notification("Level Finished", 20, true)
		if get_node(DEFAULT + "Door").has_method("open"):
			get_node(DEFAULT + "Door").open()
			get_node(DEFAULT + "Door1").open()
		else:
			get_node("/root/logger").log_error("Doors does not have method open")
		save_game()

func is_won():
	return is_level_won

#saves name of solved lvl to file 
func save_game():
	var saved = false
	var savestr = get_name() + "\n"
	var savegame = File.new()
	if(!savegame.file_exists("user://savegame.save")):
		get_node("/root/logger").log_error("No savegame file")
		return null
	var currline={}
	savegame.open("user://savegame.save",File.READ)
	currline = savegame.get_line()
	while(!savegame.eof_reached()):
		var lvlhelp = currline
		if(currline == get_name()):
			saved = true
		savestr += lvlhelp
		currline = savegame.get_line()
	savegame.close()
	if(!saved):
		savegame.open("user://savegame.save",File.WRITE)
		savegame.store_line(savestr)
		savegame.close()
	get_node("/root/logger").log_info("Game Saved")

func is_crate(node):
	if PATH_CRATE == null or get_node(PATH_CRATE) == null:
		return false
	return get_node(PATH_CRATE).is_crate(node)

# Help function checking if a node is a PC
func is_pc(node):
	if PATH_PC == null:
		return false
	return get_node(PATH_PC).is_pc(node)

# Help function checking if a node is a player
func is_player(node):
	return get_node(PATH_PLAYER).is_player(node)


##############################
## CODE EXECUTION FUNCTIONS ##
##############################

# group_execute_code function
# this is what triggers when something wants to execute code
func execute_code():
	var eval_array = get_node(PATH_PC).get_screen().get_editor_text() # collects editor text in an array
	var executable_str = get_node("/root/execute").make_executable(eval_array)
	get_node("/root/logger").log_debug("Executing code")
	run_script(executable_str)

# sets the source code of the designated eval-node
func run_script(input):
	get_node("/root/logger").log_info("Player Code:\n" + input)
	var script = GDScript.new()
	script.set_source_code(input)
	script.reload() # reload for changes to source code to take effect
	
	if eval_node == null: # initialization of node
		eval_node = Node.new()
		add_child(eval_node)
	eval_node.set_script(script)
	eval_node.eval()

#
# Allows users to "Build" the code and see if there are any errors
# Errors are unrecognized code, but it may still work.
#
func fix_code():
	var eval_array = get_node(PATH_PC).get_screen().get_editor_text()
	var error_information = get_node("/root/execute").get_error_information(eval_array)
	get_node("/root/logger").log_debug("Player built code: " + error_information)
	get_node(PATH_PC).get_screen().set_editor_debug_text(error_information)

#
# Place all methods called by the player here
#

func invert_gravity_player():
	gravity_direction_player *= -1
	get_node(PATH_PC).get_screen()._invert()

func invert_gravity_room():
	gravity_direction_room *= -1

func move_crate_left(dist=0):
	if PATH_CRATE == null:
		get_node("/root/logger").log_warning("Attempted to use Crate when not defined in defaultenvironment.gd")
	else:
		get_node(PATH_CRATE).set_target(Vector3(0,0,dist))

func move_crate_right(dist=0):
	if PATH_CRATE == null:
		get_node("/root/logger").log_warning("Attempted to use Crate when not defined in defaultenvironment.gd")
	else:
		get_node(PATH_CRATE).set_target(Vector3(0,0,-dist))

func move_crate_forward(dist=0):
	if PATH_CRATE == null:
		get_node("/root/logger").log_warning("Attempted to use Crate when not defined in defaultenvironment.gd")
	else:
		get_node(PATH_CRATE).set_target(Vector3(-dist,0,0))

func move_crate_backward(dist=0):
	if PATH_CRATE == null:
		get_node("/root/logger").log_warning("Attempted to use Crate when not defined in defaultenvironment.gd")
	else:
		get_node(PATH_CRATE).set_target(Vector3(dist,0,0))

#Level 12 spesific fucntion
func set_a(tall):
	if PATH_TV == null:
		get_node("/root/logger").log_warning("Attempted to use TV when not defined in defaultenvironment.gd")
	else:
		set_a(tall)
#Level 12
func set_b(tall):
	if PATH_TV == null:
		get_node("/root/logger").log_warning("Attempted to use TV when not defined in defaultenvironment.gd")
	else:
		set_b(tall)

func fire_gun(bullets=1):
	if bullets > 20:
		bullets = 20
	elif bullets < 1:
		bullets = 1
	for i in range(bullets):
		var projectile = load("res://assets/objects/projectile.tscn").instance()
		get_node("Gun").add_child(projectile)
		projectile._start(Vector3(0,0,40))
		projectile.get_node("Area").connect("body_enter", self, "gun_hit")