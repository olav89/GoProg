# This script contains reusable code for levels
# Levels extends this script and can override functions
# Calling this scripts functions from overridden functions is done with .function()

extends Spatial

# Paths
const DEFAULT = "defaultenviroment/"
const PATH_PLAYER = DEFAULT + "Player"
const PATH_GUI = DEFAULT + "GUI"
var PATH_PC = DEFAULT + "PC"
var PATH_CRATE
var PATH_TV
var PATH_LIGHTBOARD
var PATH_CANNON

# Text strings
var journal_text
var editor_text = ""

# Node used for evaluations
var eval_node

# Level progress variables
var is_level_won = false
var is_level_lost = false

# Help buttons for PC Screen
var help_button_selection = []
# Title, Description, [button texts]
# WARNING: APPEND NEW BUTTONS!!!
var help_buttons = [
	["Gravity",
	"Gravity Functions.",
	["invert_gravity_room()",
	"invert_gravity_player()"]],
	["Moving Crate",
	"Movement Functions. Parameter: integer",
	["move_crate_left()",
	"move_crate_right()",
	"move_crate_forward()",
	"move_crate_backward()"]],
	["Cannon",
	"Fire or angle the cannon. Parameter: integer",
	["fire_cannon()",
	"angle_cannon()"]],
	["Light Switch",
	"Turn on a light. Parameter: integer (1-4)",
	["light_switch()"]],
	["If sentences",
	"Sample if sentences.",
	["""if exp: 
	# code""",
	"""if exp: 
	# code 
elif exp2: 
	# code""",
	"""if exp: 
	# code 
else: 
	# code"""
	]],
	["Loops",
	"Sample loops.",
	["""for i in range(n): 
	# code""",
	"""var i = 0 
while i < 20: 
	# code"""
	]],
	["Comparisons",
	"Sample comparisons.",
	["a == b",
	"a != b",
	"a > b",
	"a < b",
	"a >= b",
	"a <= b"
	]]
	]

var HELP_GRAVITY = help_buttons[0][0]
var HELP_CRATE = help_buttons[1][0]
var HELP_CANNON = help_buttons[2][0]
var HELP_LIGHT = help_buttons[3][0]
var HELP_IF = help_buttons[4][0]
var HELP_LOOP = help_buttons[5][0]
var HELP_COMPARE = help_buttons[6][0]

# Gravity
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
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Setup function 
func run_setup():
	get_node(PATH_PLAYER).setup(get_node("."), get_node(PATH_GUI))
	
	if help_button_selection.size() == 0:
		set_all_help_buttons()
	get_node(PATH_PC).get_screen().setup(get_node(PATH_GUI), help_button_selection, editor_text)
	get_node(PATH_GUI).set_journal_text(journal_text)

# Adds help buttons
func set_help_buttons(names):
	for name in names:
		var found = false
		for btn in help_buttons:
			if btn[0].find(name) > -1:
				help_button_selection.append(btn)
				found = true
		if !found:
			get_node("/root/logger").log_debug("Could not find help button for: %s" % name)

# Selects all help buttons
func set_all_help_buttons():
	help_button_selection = help_buttons

# Physics process
func _fixed_process(delta):
	set_gravity()

# Adjusts gravity for player and the room
func set_gravity():
	if gravity_direction_room != gravity_direction_room_old:
		PhysicsServer.area_set_param(get_world().get_space(), 
		PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
		Vector3(0, gravity_direction_room, 0))
		gravity_direction_room_old = gravity_direction_room
		add_gravity_timer() # for yielding
	elif gravity_direction_player != gravity_direction_player_old:
		get_node(PATH_PLAYER).gravity_direction = gravity_direction_player
		gravity_direction_player_old = gravity_direction_player
		add_gravity_timer() # for yielding

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

# Called when a level is won
func won():
	if !is_level_won and !is_level_lost:
		is_level_won = true
		get_node(DEFAULT + "GUI").change_notification("Level Finished", 20, true)
		if get_node(DEFAULT + "Door").has_method("open"):
			get_node(DEFAULT + "Door").open()
			get_node(DEFAULT + "Door1").open()
		else:
			get_node("/root/logger").log_error("Doors does not have method open")
		save_game()

func lost():
	if !is_level_won:
		is_level_lost = true
		get_node(DEFAULT + "GUI").change_notification("Level Failed, reset in 3 seconds", 3, true)
		
		var reset_timer = Timer.new()
		reset_timer.connect("timeout",self,"reset_level")
		reset_timer.set_one_shot(true)
		add_child(reset_timer)
		reset_timer.set_wait_time( 3 )
		reset_timer.start()

func reset_level():
	get_node("/root/logger").log_info("Resetting scene.")
	get_tree().reload_current_scene() # reload scene

# To check if a level is completed
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
		if(currline == get_name()):
			saved = true
		if(!saved):
			savestr += currline +"\n"
		currline = savegame.get_line()
	savegame.close()
	if(!saved):
		savegame.open("user://savegame.save",File.WRITE)
		savegame.store_line(savestr)
		savegame.close()
	get_node("/root/logger").log_info("Game Saved")

# Checks if a node is the moveable crate
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
	if executable_str != "":
		run_script(executable_str)
	else:
		get_node(PATH_GUI).change_notification("Code Compiling Failed", 2, true)

# sets the source code of the designated eval-node
func run_script(input):
	get_node("/root/logger").log_debug("Executing code")
	var script = GDScript.new()
	script.set_source_code(input)
	script.reload() # reload for changes to source code to take effect
	
	if eval_node == null: # initialization of node
		eval_node = Node.new()
		add_child(eval_node)
	eval_node.set_script(script)
	eval_node.eval()

# Allows users to "Build" the code and see if there are any syntax errors
func fix_code():
	var eval_str = get_node(PATH_PC).get_screen().get_editor_text_plain()
	var error_information = get_node("/root/execute").get_error_information(eval_str)
	get_node(PATH_PC).get_screen().set_editor_debug_text(error_information)

###############################################
# Place all methods called by the player here #
###############################################

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

#Level 13 crate help functions
func change_crate(cratenmb):
	if PATH_CRATE == null:
		get_node("/root/logger").log_warning("PATH_CRATE = null")
	else:
		var chelp = DEFAULT + "Crate " + str(cratenmb)
		print(chelp)
		if has_node(chelp):
			PATH_CRATE = chelp
		elif cratenmb == 1:
			PATH_CRATE = "Crate"
		else:
			get_node("/root/logger").log_warning("Attemoted to use Crate when not defined in defaultenviroment.gd")
			

# Fires projectiles from a cannon object
func fire_cannon(bullets=1):
	if PATH_CANNON == null:
		get_node("/root/logger").log_warning("PATH_CANNON not defined")
		return
	get_node("Cannon").fire_sound()
	if bullets > 20:
		bullets = 20
	elif bullets < 1:
		bullets = 1
	for i in range(bullets):
		var projectile = load("res://assets/objects/projectile.tscn").instance()
		get_node("Cannon/Exit").add_child(projectile)
		projectile._start()
		projectile.get_node("Area").connect("body_enter", self, "cannon_hit")

# Empty function, implement on a level by level basis
func cannon_hit(body):
	pass

func angle_cannon(angle=0):
	if PATH_CANNON == null:
		get_node("/root/logger").log_warning("PATH_CANNON not defined")
	else:
		get_node(PATH_CANNON)._rotate(angle)

func light_switch(id):
	if PATH_LIGHTBOARD == null:
		get_node("/root/logger").log_warning("Attempted to use Lightboard when not defined in defaultenvironment.gd")
	else:
		get_node(PATH_LIGHTBOARD).blink(id)