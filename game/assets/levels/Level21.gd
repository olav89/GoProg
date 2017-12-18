extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	journal_text = "Fire the cannon at the crate.\n"
	# setup scripts
	run_setup()

# Event for gun hitting a body
func cannon_hit(body):
	if is_crate(body):
		won()