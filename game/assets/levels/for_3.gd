extends "res://assets/levels_assets/defaultenvironment.gd"

var hit1 = false
var hit2 = false
var hit3 = false

var crates = [
"Crate",
"Crate 2",
"Crate 3"
]

func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	journal_text = "- Move Crate using a for loop and shoot them all \n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	editor_text="""# The objective is to make a function
# to fire the gun, change wich crate to controll,
# and move the next crate up in front of the gun
# either change gravity or change the angle of the 
# gun to hit the one in the roof

for i in range(3):
	#fire
	#change
"""
	
	# setup scripts
	run_setup()
	
	
func _process(delta):
	if(hit1 && hit2 && hit3):
		won()

func is_a_crate(body):
	for crate in crates:
		if body.get_name() == crate:
			return true
	return false
	
func what_crate(body):
	return body.get_name()

func cannon_hit(body):
	if is_a_crate(body):
		if(what_crate(body) == "Crate"):
			hit1 = true
		elif(what_crate(body) == "Crate 2"):
			hit2 = true
		elif(what_crate(body) == "Crate 3"):
			hit3 = true