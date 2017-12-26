extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CANNON = "Cannon"
	PATH_CRATE = "Crate"
	journal_text = "Hit the crate with the cannon.\n"
	set_help_buttons([HELP_CANNON, HELP_GRAVITY, HELP_CRATE])
	# setup scripts
	run_setup()

func cannon_hit(body):
	if get_node(PATH_CRATE).is_crate(body):
		won()