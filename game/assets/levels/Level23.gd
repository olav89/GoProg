extends "res://assets/levels_assets/defaultenvironment.gd"

var light_ids = []
var correct_ids = []
var num = -1
var can_fire = false

func _ready():
	correct_ids.resize(5)
	# setup variables
	PATH_CANNON = "Cannon"
	PATH_CRATE = "Crate"
	PATH_LIGHTBOARD = "Lightboard"
	editor_text = """# This cannon has been locked with a security code
# The code starts as "0123", but one number is repeated!
# This number is selected randomly (0-3)
# For example: if the number is 0 the code will be 00123
# The full code is entered using the function light_switch
# Your job is to write code that will enter the correct code


var num = randi()%4 # select random number

for ?:
	light_switch(?)
"""
	journal_text = "Fire the cannon.\n"
	set_help_buttons([HELP_CANNON, HELP_GRAVITY, HELP_CRATE, HELP_LIGHT])
	# setup scripts
	run_setup()

func run_script(input):
	light_ids = []
	num = randi()%4
	correct_ids = [0,1,2,3]
	correct_ids.insert(num, num)
	input = input.replace("randi()%4" , str(num))
	.run_script(input)

func light_switch(id):
	light_ids.append(id)
	if light_ids.size() == 5:
		var correct = 0
		for i in range(light_ids.size()):
			if light_ids[i] == correct_ids[i]:
				correct += 1
		if correct == 5:
			can_fire = true
			fire_cannon()
	.light_switch(id)

func fire_cannon():
	if can_fire:
		.fire_cannon()
		won()