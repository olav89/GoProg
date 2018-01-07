extends "res://assets/levels_assets/defaultenvironment.gd"


func _ready():
	# setup variables
	set_process(true)
	PATH_CRATE = "Crate"
	PATH_CANNON = "Cannon"
	PATH_LIGHTBOARD = "Lightboard"
	journal_text = "- Access the PC to learn\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	
	editor_text = """# Here you can test out the effect diffrent variables have on items. 
# The Variables a - d are imputs in diffrent functions. see for yourself
	
var a = 1
var b = 2
var c = 3
var d = 4

for i in range(d):
	light_switch(i)

fire_cannon(c)

move_crate_forward(b)
move_crate_backward(a)

#when you are ready to try to advance to the next lvl, 
#manipulate the variables so that the crates moves in front
#of the gun and shoot at it
	"""
	
	# setup scripts
	run_setup()
	
	
func _process(delta):
	pass

func cannon_hit(body):
	if get_node(PATH_CRATE).is_crate(body):
		won()
