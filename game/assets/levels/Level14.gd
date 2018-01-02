extends "res://assets/levels_assets/defaultenvironment.gd"

var hit1 = false
var hit2 = false
var hit3 = false

var crates = [
"Crate",
"Crate 2",
"Crate 3",
"Crate 4",
"Crate 5",
]



	
func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	journal_text = "- Move Crate using a for loop and shoot them all \n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	editor_text=""" 
#The objective is to make a function
#to fire the gun, change wich crate to controll,
#and move the next crate up in front of the gun
# use a if loop to only shoot the first, third and last crate

func test(a):
	fire_cannon() 
	change_crate(a+1)
	move_crate_forward(a+3)
	if(a==2):
		fire_cannon()

for i in range(2):
	test(i) """

	
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
			print("1")
		elif(what_crate(body) == "Crate 3"):
			hit2 = true
			print("2")
		elif(what_crate(body) == "Crate 5"):
			hit3 = true
			print("3")