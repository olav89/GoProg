extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	journal_text = "Fire the cannon at the crate.\n"
	editor_text = """move_crate_right()
move_crate_left()
move_crate_forward()
move_crate_backward()
fire_cannon(10)"""
	# setup scripts
	run_setup()

# Event for gun hitting a body
func cannon_hit(body):
	if is_crate(body):
		won()