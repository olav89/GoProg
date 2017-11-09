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
	
	# setup scripts
	run_setup()

func _fixed_process(delta):
	if is_queued:
		var codes = PATHS_AND_CODES_PC[selection_pc][CODES]
		if selection_pc == 0:
			if codes[0] in selection:
				gravity_direction_player *= -1
			if codes[1] in selection:
				gravity_direction_room *= -1
			
		is_queued = false