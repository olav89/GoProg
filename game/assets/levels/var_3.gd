extends "res://assets/levels_assets/defaultenvironment.gd"


func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	PATH_LIGHTBOARD = "Lightboard"
	journal_text = "- Access the PC to learn\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	
	editor_text = """   
#in This level you may try to use the following setup to move 
#the crate in front of the gun, you may however need to 
#change something

var bool1 = true
var bool2 = false



if(bool2):
	move_crate_forward(1)
	for i in range(4):
		light_switch(i)
		while(i==1):
			fire_cannon()
		if(bool1 && i ==4 || bool2 and i == 1):
			move_crate_left(7)
	"""
	
	# setup scripts
	run_setup()
	
	
func _process(delta):
	pass

func cannon_hit(body):
	if get_node(PATH_CRATE).is_crate(body):
		won()
