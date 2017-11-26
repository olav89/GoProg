extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	journal_text = "Fire the gun at the crate.\n"
	
	# setup scripts
	run_setup()

# Event for gun hitting a body
func gun_hit(body):
	if is_crate(body):
		won()