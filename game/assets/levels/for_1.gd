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
	journal_text = "- Move the Crates using a for loop  \n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	editor_text=""" 
# The objective is to make a function which
# fire the gun, change which crate to controll,
# and move the next crate up in front of the gun

func test(?):
	fire_cannon() 
	change_crate(?+1)
	move_crate_forward(?+?)
	

for i in range(?):
	test(i) 
"""

	
	# setup scripts
	run_setup()
	
	
func _process(delta):
	if(hit1 && hit2 && hit3):
		won()

func is_a_crate(body):
	for crate in crates:
		if body.get_name() == crate:
			print("true rate")
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