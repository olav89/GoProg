extends Spatial

var PATH_PLAYER = "Player"
var PATH_PC_SCREEN = "PC/PCScreen"
var PATH_PAD = "Crate/VictoryPad"
var PATH_ELEVATOR_DOOR = "Doorframe"

var is_level_won = false

var codes = [
"player.invert_gravity()",
"room.invert_gravity()"
]

var selection = []
var pc_node = null

var is_queued = false

var gravity_direction_room = -1
var gravity_direction_player = -1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# setup scripts
	get_node(PATH_PLAYER).setup(get_node("."), null)
	get_node(PATH_PC_SCREEN).setup(get_node(PATH_PLAYER))
	#get_node(PATH_ELEVATOR_DOOR).setup(get_node("."))
	
	# add codes for all pcs in scene
	get_node(PATH_PC_SCREEN).create_codes(codes)
	
	# adds to group so it gets notified when player wants to execute code
	add_to_group("execute_code_group")
	set_fixed_process(true)
	
func won():
	is_level_won = true

func is_won():
	return is_level_won

func _fixed_process(delta):
	if is_queued:
		if codes[0] in selection:
			gravity_direction_player *= -1
		if codes[1] in selection:
			gravity_direction_room *= -1
			
		is_queued = false
	
	# LEAVE THIS HERE FOR RESETTING SCENE
	PhysicsServer.area_set_param(get_world().get_space(), 
	PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
	Vector3(0, gravity_direction_room, 0))
	get_node("Player").gravity_direction = gravity_direction_player
	

func execute_code():
	pc_node = get_node(PATH_PLAYER).pc_node
	if pc_node == null:
		return
	selection = pc_node.get_node("PCScreen").selection
	is_queued = true