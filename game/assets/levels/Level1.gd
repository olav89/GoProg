extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	# setup scripts
	run_setup()
