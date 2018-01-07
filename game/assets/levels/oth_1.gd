extends "res://assets/levels_assets/defaultenvironment.gd"

# Problem (Simple function calls and timing):
#	Fire a cannon at a crate
#	Other crates are moving
#	Collision between crates is a failure
# Main Solutions:
#	Find safe path, move, invert gravity and shoot
#	Shoot crates out of the way
#	Collide with crates as player to move them away

var crates = [
"Crate1",
"Crate2",
"Crate3",
"Crate4"
]

func _ready():
	# setup variables
	journal_text = "Shoot the crate without having it collide with other crates.\n"
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	get_node(PATH_CRATE).connect("body_enter", self, "crate_hit")
	
	editor_text = """# "Shoot the crate without having it collide with other crates."""
	# setup scripts
	run_setup()
	
	var size = 7
	var targets = [
	Vector3(size,0,0),
	Vector3(0,0,size),
	Vector3(-size,0,0),
	Vector3(0,0,-size)
	]
	
	for crate in crates:
		get_node(crate).set_permanent_targets(targets)

func crate_hit(body):
	if is_a_crate(body):
		lost()

func is_a_crate(body):
	for crate in crates:
		if body.get_name() == crate:
			return true
	return false

func cannon_hit(body):
	if is_crate(body):
		won()
