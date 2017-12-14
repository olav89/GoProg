extends "res://assets/levels_assets/defaultenvironment.gd"

var edited_lines
var used_ids = []

func _ready():
	# setup variables
	journal_text = "Change ONE line of code to make sure each light works.\n"
	PATH_LIGHTBOARD = "Lightboard"
	editor_text = """func magic(number):
	if number == 3:
		return 2
	else:
		return (number + 4) % 4
	
for i in range(4):
	var number = magic(i)
	light_switch(number)
"""
	
	# setup scripts
	run_setup()

# Counts how many lines of code has been edited
func execute_code():
	edited_lines = 0
	used_ids = []
	
	.execute_code()
	var eval_array = get_node(PATH_PC).get_screen().get_editor_text_plain().split("\n")
	var eval_default = editor_text.split("\n")
	var i = eval_default.size()
	var j = eval_array.size()
	
	for line in range(j):
		if i >= j and eval_default[line].find(eval_array[line]) == -1 and (
		eval_default[line] != eval_array[line]):
			edited_lines += 1

# Checks if all lights have been turned on
func light_switch(id):
	.light_switch(id)
	used_ids.append(id)
	if used_ids.has(0) and used_ids.has(1) and used_ids.has(2) and used_ids.has(3):
		won()