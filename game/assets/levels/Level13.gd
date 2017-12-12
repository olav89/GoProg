extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	journal_text = "- Move Crate using a for loop \n"
	journal_text += "- Interact with the PC by pressing E.\n"
	# setup scripts
	run_setup()
	get_node(PATH_PLAYER).set_translation(Vector3(-15.0,1.0,15.0))
	get_node(PATH_PLAYER).set_rotation(Vector3(0.0,0.0,0.0))
	get_node("defaultenviroment/Table").set_translation(Vector3(-13.0,0.0,15.0))
	get_node(PATH_PC).set_translation(Vector3(-12.0,1.8,14.5))
	get_node(PATH_CRATE).set_scale(Vector3(2.0,2.0,2.0))