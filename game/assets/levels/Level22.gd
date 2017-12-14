extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	journal_text = "Change the variables at the pc so the cannon fires 6 shots.\n"
	editor_text = """# Variables are useful for saving data
# Declare a variable typing "var my_variable"
# Set a variables value when declaring it (var my_variable = 2),
# or give it a value later (my_variable = 2)
# To get a variables value later you can type "my_variable"

# Give the variables a and b values so the cannon fires 6 bullets.
# Hint: a * b means a multiplied with b
var a = 0
var b
b = 0

var bullets = (a * b) / 2
fire_cannon(bullets)"""
	# setup scripts
	run_setup()

func fire_cannon(bullets=1):
	if bullets == 6:
		won()
	.fire_cannon(bullets)