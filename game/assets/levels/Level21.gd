extends "res://assets/levels_assets/defaultenvironment.gd"

# Problem (Simple function calls):
#	Fire a cannon at a crate
#	Obstacles separate crate from cannon
#	
# Main Solutions:
#	Move crate around obstacles to cannon
#	Invert gravity, move crate, invert gravity
#	Angle cannon to shoot over obstacles


func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	journal_text = "Fire the cannon at the crate.\n"
	set_help_buttons(["Cannon", "Crate", "Gravity"])
	get_help_buttons()
	editor_text = """# Helpful measurements: (Or maybe you can think of another way?)
var a = 13
var b = 17
var c = 5"""
	# setup scripts
	run_setup()

# Event for gun hitting a body
func cannon_hit(body):
	if is_crate(body):
		won()