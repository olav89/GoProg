extends Spatial

const PATH_PLAYER = "Player"
const PATH_PAD = "Crate/VictoryPad"

const PC = 0
const SCREEN = 1
const CODES = 2
const PATHS_AND_CODES_PC = [
["PC","PC/PCScreen",
["player.invert_gravity()",
"room.invert_gravity()"]]
]

var is_level_won = false

var selection = []
var selection_pc = -1
var pc_node = null

var is_queued = false

var gravity_direction_room = -1
var gravity_direction_player = -1

func _ready():
	get_node("/root/logger").set_debug(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# setup scripts
	get_node(PATH_PLAYER).setup(get_node("."))
	for pc in PATHS_AND_CODES_PC:
		get_node(pc[SCREEN]).setup(get_node(PATH_PLAYER))
		get_node(pc[SCREEN]).create_codes(pc[CODES])
	
	# adds to group so it gets notified when player wants to execute code
	add_to_group("execute_code_group")
	set_fixed_process(true)
	
func won():
	is_level_won = true

func is_won():
	return is_level_won

func _fixed_process(delta):
	if is_queued:
		var codes = PATHS_AND_CODES_PC[selection_pc][CODES]
		if selection_pc == 0:
			if codes[0] in selection:
				gravity_direction_player *= -1
			if codes[1] in selection:
				gravity_direction_room *= -1
			
		is_queued = false
	
	# LEAVE THIS HERE FOR RESETTING SCENE
	PhysicsServer.area_set_param(get_world().get_space(), 
	PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
	Vector3(0, gravity_direction_room, 0))
	get_node(PATH_PLAYER).gravity_direction = gravity_direction_player
	

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
	return (get_node(PATH_PAD).get_instance_ID() == node.get_instance_ID())

func is_pc(node):
	for pc in PATHS_AND_CODES_PC:
		if (get_node(pc[PC]).is_pc(node)):
			return true
	return false
