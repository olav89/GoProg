extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	journal_text = "Fire the gun at the crate.\n"
	
	# setup scripts
	run_setup()


func fire_gun(bullets=1):
	if bullets > 10:
		bullets = 10
	elif bullets < 1:
		bullets = 1
	for i in range(bullets):
		var projectile = load("res://assets/objects/projectile.tscn").instance()
		get_node("Gun").add_child(projectile)
		projectile._start(Vector3(0,0,40))
		projectile.get_node("Area").connect("body_enter", self, "gun_hit")

func gun_hit(body):
	if is_crate(body):
		won()