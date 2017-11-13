extends Spatial

const DEFAULT = "defaultenviroment/"
const PATH_PLAYER = DEFAULT + "Player"
var journal_text
var PATH_PAD
var PATHS_PC
var PATH_CRATE

var eval_node

var is_level_won = false

var pc_node = null

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
	get_node(PATH_PLAYER).setup(get_node("."), journal_text)
	for pc in PATHS_PC:
		get_node(pc).get_screen().setup(get_node(PATH_PLAYER))

func _fixed_process(delta):
	set_gravity()

func set_gravity():
	# LEAVE THIS HERE FOR RESETTING SCENE
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

func add_gravity_timer():
	if gravity_timer == null:
		gravity_timer = Timer.new()
		gravity_timer.connect("timeout",self,"gravity_timer_finished")
		gravity_timer.set_one_shot(true)
		add_child(gravity_timer)
	gravity_timer.set_wait_time( 2 )
	gravity_timer.start()

func gravity_timer_finished():
	emit_signal("gravity_finished")

func won():
	is_level_won = true
	get_node(PATH_PLAYER).journal.change_journal("Level complete. Proceed to the elevator.")

func is_won():
	return is_level_won

func is_victory_pad(node):
	if get_node(PATH_PAD) == null:
		return false
	return (get_node(PATH_PAD).get_instance_ID() == node.get_instance_ID())

func is_pc(node):
	if PATHS_PC == null:
		return false
	for pc in PATHS_PC:
		if (get_node(pc).is_pc(node)):
			return true
	return false

func is_player(node):
	return get_node(PATH_PLAYER).is_player(node)

# sets the source code of a node to run the code
func run_script(input):
	get_node("/root/logger").log_info("Player Code:\n" + input)
	var script = GDScript.new()
	script.set_source_code("func eval(): " + input)
	script.reload()
	
	if eval_node == null: # initialization of node
		eval_node = Node.new()
		add_child(eval_node)
	eval_node.set_script(script) # set script to the new script
	eval_node.eval() # run the function

# group_execute_code function
# this is what triggers when something wants to execute code
func execute_code():
	pc_node = get_node(PATH_PLAYER).pc_node # last visited PC
	if pc_node == null:
		return
	var eval_array = pc_node.get_screen().get_editor_text() # collects editor text in an array
	var eval_str = ""
	for line in eval_array:
		eval_str += add_path_and_yield(line) # adds paths and yields to lines of code as needed
	run_script(eval_str)

#
# The bread and butter of parsing the written code
# Search for your function and add a yield line for sequential execution
# Calls to the function will happen in this script file
func add_path_and_yield(line, error_check = false):
	var res = ""
	var tab = ""
	while line[0] == "\t" or line[0] == " ":
		# TODO:
		# Fix bug happening with 1 addition and following code:
		# for i in range(4):
		# 	if i < 2:
		#		do_smth()
		#	else:
		#		do_smth()
		# This code gives an indentation error when evaluated:
		# Parser Error: Expected indented block after 'for'
		# With double addition of line[0] the bug is bypassed
		tab += line[0] + line[0]
		line = line.substr(1, line.length())

	# inverting gravity
	if line.find("invert_gravity_room()") > -1 or line.find("invert_gravity_player()") > -1:
		res += tab + "get_parent()." + line + "\n"
		res += tab + "yield(get_node(\"../\"), \"gravity_finished\") \n"
	# moving crate (SINGLE CRATE)
	elif ((line.find("move_crate_left(") > -1) or ( 
		line.find("move_crate_right(") > -1) or ( 
		line.find("move_crate_forward(") > -1) or ( 
		line.find("move_crate_forward(") > -1)) and line.find(")") > -1:
		res += tab + "get_parent()." + line + "\n"
		res += tab + "yield(get_node(\"../\" + get_parent().PATH_CRATE), \"finished\" ) \n"
	elif line.find("var") > -1:
		res += tab + line + "\n"
	elif line.find("for") > -1:
		res += tab + line + "\n"
	elif line.find("while") > -1:
		res += tab + line + "\n"
	elif line.find("if") > -1:
		res += tab + line + "\n"
	elif line.find("elif") > -1:
		res += tab + line + "\n"
	elif line.find("else") > -1:
		res += tab + line + "\n"
	else:
		res += tab + line + "\n"
		if error_check:
			return false
	if error_check:
		return true
	return res

#
# Allows users to "Build" the code and see if there are any errors
# Errors are unrecognized code, but it may still work.
#
func fix_code():
	pc_node = get_node(PATH_PLAYER).pc_node # last visited PC
	if pc_node == null:
		return
	var eval_array = pc_node.get_screen().get_editor_text()
	var eval_str = "Unrecognized code on line(s) "
	var count = 1
	var errors = 0
	for line in eval_array:
		if !add_path_and_yield(line, true):
			eval_str += str(count) + ", "
			errors += 1
		count += 1
	eval_str += "END"
	eval_str = eval_str.replace(", END", ".")
	if errors == 0:
		eval_str = "No errors found"
	pc_node.get_screen().set_editor_debug_text(eval_str)

#
# Place all methods called by the player here
# Signal emits are handled above
#

func invert_gravity_player():
	gravity_direction_player *= -1

func invert_gravity_room():
	gravity_direction_room *= -1

func move_crate_left(dist=0):
	get_node(PATH_CRATE).set_target(Vector3(0,0,dist))

func move_crate_right(dist=0):
	get_node(PATH_CRATE).set_target(Vector3(0,0,-dist))

func move_crate_forward(dist=0):
	get_node(PATH_CRATE).set_target(Vector3(-dist,0,0))

func move_crate_backward(dist=0):
	get_node(PATH_CRATE).set_target(Vector3(dist,0,0))