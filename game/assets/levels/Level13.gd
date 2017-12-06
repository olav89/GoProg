extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	journal_text = "- Move Crate using a for loop \n"
	journal_text += "- Interact with the PC by pressing E.\n"
	# setup scripts
	run_setup()


