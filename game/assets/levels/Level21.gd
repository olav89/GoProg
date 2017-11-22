extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	journal_text = "Hello.\n"
	
	# setup scripts
	run_setup()


func fire_gun(bullets):
	for i in range(bullets):
		var projectile = load("res://assets/objects/projectile.tscn").instance()
		get_node("Gun").add_child(projectile)
		projectile._start(Vector3(0,0,40))