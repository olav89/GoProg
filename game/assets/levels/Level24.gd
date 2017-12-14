extends "res://assets/levels_assets/defaultenvironment.gd"

var crates = [
"Crate1",
"Crate2",
"Crate3",
"Crate4"
]

func _ready():
	# setup variables
	journal_text = "Shoot the crate without colliding with other objects.\n"
	PATH_CRATE = "Crate"
	get_node(PATH_CRATE).connect("body_enter", self, "crate_hit")
	
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
