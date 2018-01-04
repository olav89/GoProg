extends "res://assets/levels_assets/defaultenvironment.gd"

# Problem (Conditionals):
#	Only fire cannon if random number is prime
# Main Solutions:
#	If sentence

var fired = []
signal script_finished

func _ready():
	# setup variables
	get_node("Timer").connect("timeout", self, "script_timeout")
	PATH_CANNON = "Cannon"
	editor_text = """# If sentences allows us to run code conditionally
# Check if a number is 2: "if num == 2:"
# Check if a number is 2 or 3: "if num == 2 or num == 3:"
# Make sure the cannon only fires 3 or 7 projectiles
# When you run the code it will test all numbers between 1 and 12 (not shown in editor)

var num = randi()%12 + 1 # random number between 1 and 12

if ?:
	fire_cannon(num)
"""
	journal_text = "Fire the cannon.\n"
	set_help_buttons([HELP_CANNON])
	# setup scripts
	run_setup()

func run_script(input):
	fired = []
	for i in range(1, 13):
		var input_check = input.replace("randi()%12 + 1" , str(i))
		.run_script(input_check)
		get_node("Timer").set_wait_time(0.5)
		get_node("Timer").start()
		yield(self, "script_finished")
	if fired.size() == 2 and fired.find(3) > -1 and fired.find(7) > -1:
		won()

func script_timeout():
	emit_signal("script_finished")

func fire_cannon(bullets=1):
	.fire_cannon(bullets)
	fired.append(bullets)