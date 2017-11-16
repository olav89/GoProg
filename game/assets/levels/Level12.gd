extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_PAD = "Crate/VictoryPad"
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	# setup scripts
	run_setup()

