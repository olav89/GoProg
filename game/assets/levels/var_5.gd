extends "res://assets/levels_assets/defaultenvironment.gd"

# Problem (Simple function calls):
#	Fire cannon at a crate
#	Obstacles blocks shot at the start
#	Crate cannot be moved to the cannon
# Main Solutions:
#	Angle cannon to shoot over obstacles
#	Invert gravity + angle cannon for easy shot

func _ready():
	# setup variables
	PATH_CANNON = "Cannon"
	PATH_CRATE = "Crate"
	journal_text = "Hit the crate with the cannon.\n"
	set_help_buttons([HELP_CANNON, HELP_GRAVITY, HELP_CRATE])
	editor_text = """# Hit the crate with the cannon """
	
	# setup scripts
	run_setup()

func cannon_hit(body):
	if get_node(PATH_CRATE).is_crate(body):
		won()