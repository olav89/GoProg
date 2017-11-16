#extends Spatial
extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_PAD = "Crate/VictoryPad"
	PATHS_AND_CODES_PC = [
	[DEFAULT + "PC",DEFAULT + "PC/PCScreen",
	["player.invert_gravity()",
	"room.invert_gravity()"]]
	]
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	#var rtt = get_node("defaultenviroment/Tv/Viewport").get_render_target_texture()
	#get_node("defaultenviroment/Tv").set_texture(rtt)
	
	# setup scripts
	run_setup()

func _process(delta):
	if is_queued:
		var codes = PATHS_AND_CODES_PC[selection_pc][CODES]
		if selection_pc == 0 and queue_pos < selection.size():
			var code = selection[queue_pos]
			# gravity
			if code == codes[0]:
				gravity_direction_player *= -1
			elif code == codes[1]:
				gravity_direction_room *= -1
			# moving crate
			var move_dist = 4
			
			is_queued = false
			