extends Node

var activation_cd = 0

var func_names
var parent = "get_parent()" # get parent node
var path = "\"../\"" # path to parent
const MATCH_NAME = 0
const MATCH_REPLACE = 1
const MATCH_YIELD = 2

#
#	All custom functions go here
#
#	First array: all matches for a function
#	http://docs.godotengine.org/en/stable/classes/class_string.html#class-string-match
#
#	Second array: what to replace if a match is found
#
#	Third array: the yield call required
var custom_functions = [
[
	["*invert_gravity_room()*","*invert_gravity_player()*"],
	["invert_gravity", "%s.invert_gravity" % parent],
	["yield(%s, \"gravity_finished\")" % parent]
],
[
	["*move_crate_left(*)*","*move_crate_right(*)*",
	"*move_crate_forward(*)*","*move_crate_backward(*)*"],
	["move_crate", "%s.move_crate" % parent],
	["yield(get_node(%s + %s.PATH_CRATE), \"finished\" )" % [path, parent]]
],
[
	["*set_a(*)*", "*set_b(*)*"],
	["set_", "%s.set_" % parent],
	["yield(get_node(%s + %s.PATH_TV), \"finished\")" % [path, parent]]
],
[
	["*fire_gun(*)*"],
	["fire_", "%s.fire_" % parent],
	[]
]
]

# Append help buttons
var all_help_buttons = [
	["Gravity",
	"""
	Gravity Functions:
	invert_gravity_room()
	invert_gravity_player()
	"""],
	["Moving Crate",
	"""
	Movement Functions:
	move_crate_left(d)
	move_crate_right(d)
	move_crate_forward(d)
	move_crate_backward(d)
	d = distance to move
	"""],
	["Fire Gun",
	"""
	Fire the gun using:
	fire_gun(i)
	i = the number of bullets fired
	"""]
	]

func get_help_buttons():
	return all_help_buttons

func _ready():
	set_process(true)

func _process(delta):
	if activation_cd > 0:
		activation_cd -= delta

func execute_code():
	if activation_cd <= 0:
		get_tree().call_group(0, "execute_code_group", "execute_code")
		activation_cd = 1.5

func make_executable(eval_array):
	var eval_str = ""
	
	make_func_names(eval_array) # extract names of functions
	
	var non_empty_lines = 0
	for line in eval_array:
		if line != "":
			non_empty_lines += 1
		eval_str += match_code(line) # matches code and modifies with paths and yields
	if non_empty_lines == 0:
		eval_str += "pass"
		get_node("/root/logger").log_debug("Empty code exchanged with pass for execution")
	
	eval_str = make_function(eval_str)
	return eval_str

func get_error_information(eval_array):
	var res = "Unrecognized code on line(s) \n"
	
	var line_number = 1
	var errors = 0
	make_func_names(eval_array)
	for line in eval_array:
		if !match_code(line, true):
			res += str(line_number) + ", "
			errors += 1
		line_number += 1
	res = res.substr(0, res.length() - 2)
	if errors == 0:
		res = "No errors found"
	return res
	

# Extract function names for checking function calls
func make_func_names(eval_array):
	func_names = []
	for s in eval_array:
		if s.match("*func*(*):*"):
			var start = s.find("func") + 5
			var end = s.find("(") - 1
			func_names.append(s.substr(start, end-start + 1))


func match_custom_func(line, tab):
	var str_append = ""
	
	for custom_func in custom_functions:
		for str_match in custom_func[MATCH_NAME]:
			if line.match(str_match):
				str_append += line.replace(custom_func[MATCH_REPLACE][0], custom_func[MATCH_REPLACE][1]) + "\n"
				if custom_func[MATCH_YIELD].size() == 1:
					str_append += tab + custom_func[MATCH_YIELD][0] + "\n"
	return str_append

# Simple parse from player input to runnable code
# Functions that take time to complete are coupled with yields
# Add known functions even if you make no changes so they are recognized
func match_code(line, error_check = false):
	var res = ""
	
	var tab = leading_spaces(line) # get the indentation
	
	var str_custom_func = match_custom_func(line, tab)
	if str_custom_func != "":
		res += str_custom_func
	elif line.match("*var*=*"):
		res += line + "\n"
	elif line.match("*for*:*"):
		res += line + "\n"
	elif line.match("*while*:*"):
		res += line + "\n"
	elif line.match("*if*:*"):
		res += line + "\n"
	elif line.match("*elif*:*"):
		res += line + "\n"
	elif line.match("*else*:*"):
		res += line + "\n"
	elif line.match("*func*():*"):
		res += line + "\n"
	elif line.match("*return*:*"):
		res += line + "\n"
	elif line.match("*(*)*"): # function call
		var found = false
		for f in func_names:
			if line.match("*%s(*)*" % f):
				res += line + "\n"
				found = true
		if !found:
			res += line + "\n"
			if error_check:
				return false
	elif line == "":
		pass
	else:
		res += line + "\n"
		if error_check:
			return false
	if error_check:
		return true
	return res

# Makes functions outside of the main script function eval()
func make_function(input):
	var eval = "func eval(): \n"
	var functions = ""
	var i = 0
	var input_array = input.split("\n", false) # dont allow empty
	
	var func_indent = -1
	var line
	while i < input_array.size():
		line = input_array[i]
		if line.find("func") > -1:
			func_indent = leading_spaces(line).length()
			functions +=  line + "\n"
			i +=1
		elif func_indent > -1 and func_indent < leading_spaces(line).length():
			functions +=  line + "\n"
			i +=1
		else:
			eval += "\t" + line + "\n"
			i += 1
			func_indent = -1
	var res = eval + " \n" + functions
	return res

# Get the leading spaces and tabs
func leading_spaces(line):
	var spaces = ""
	var i = 0
	while (line != "" and i < line.length()) and (line[i] == " " or line[i] == "\t"):
		spaces += line[i]
		i += 1
	return spaces
