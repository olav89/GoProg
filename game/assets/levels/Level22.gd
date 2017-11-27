extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	journal_text = "Change the variables so the gun fires 6 shots.\n"
	editor_text = """var a = 0
var b = 0
fire_gun( (a * b) / 2 )
"""
	# setup scripts
	run_setup()

func fire_gun(bullets=1):
	if bullets == 6:
		won()
	.fire_gun(bullets)