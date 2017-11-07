extends Spatial

const DEFAULT = "defaultenviroment/"
const PATH_PLAYER = DEFAULT + "Player"
var PATH_PAD

const PC = 0
const SCREEN = 1
const CODES = 2
var PATHS_AND_CODES_PC

var is_level_won = false

var selection = []
var selection_pc = -1
var pc_node = null

var is_queued = false

var gravity_direction_room = -1
var gravity_direction_player = -1

func _ready():
	# adds to group so it gets notified when player wants to execute code
	add_to_group("execute_code_group")
	set_fixed_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func run_setup():
	get_node(PATH_PLAYER).setup(get_node("."))
	for pc in PATHS_AND_CODES_PC:
		get_node(pc[SCREEN]).setup(get_node(PATH_PLAYER))
		get_node(pc[SCREEN]).create_codes(pc[CODES])

func _fixed_process(delta):
	set_gravity()

func set_gravity():
	# LEAVE THIS HERE FOR RESETTING SCENE
	PhysicsServer.area_set_param(get_world().get_space(), 
	PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
	Vector3(0, gravity_direction_room, 0))
	get_node(PATH_PLAYER).gravity_direction = gravity_direction_player

func won():
	is_level_won = true

func is_won():
	return is_level_won

func execute_code():
	pc_node = get_node(PATH_PLAYER).pc_node
	if pc_node == null:
		return
	for i in range(PATHS_AND_CODES_PC.size()):
		if pc_node == get_node(PATHS_AND_CODES_PC[i][PC]):
			selection_pc = i
	selection = pc_node.get_screen().selection
	is_queued = true

func is_victory_pad(node):
	if get_node(PATH_PAD) == null:
		return false
	return (get_node(PATH_PAD).get_instance_ID() == node.get_instance_ID())

func is_pc(node):
	if PATHS_AND_CODES_PC == null:
		return false
	for pc in PATHS_AND_CODES_PC:
		if (get_node(pc[PC]).is_pc(node)):
			return true
	return false

func is_player(node):
	return get_node(PATH_PLAYER).is_player(node)

func this_is_a_demonstration():
	get_node("/root/logger").log_debug("Demonstration from defaultenviroment.gd")