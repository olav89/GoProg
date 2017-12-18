# Execution script
# Modifies player code to make it runnable

extends Node

# Activation Cooldown
var activation_cd = 0

# Path and function for parent (The Level node)
var parent = "get_parent()"
var path = "\"../\""

# Variable for saving function names
var func_names

# The order of arrays for custom functions
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
	[]
],
[
	["*fire_cannon(*)*"],
	["fire_", "%s.fire_" % parent],
	[]
],
[
	["*light_switch(*)*"],
	["light_switch", "%s.light_switch" % parent],
	["yield(get_node(%s + %s.PATH_LIGHTBOARD), \"blink_finished\" )" % [path, parent]]
],
[
	["*angle_cannon(*)*"],
	["angle_cannon", "%s.angle_cannon" % parent],
	[]
]
]

# All help buttons
# Title, Description, [button texts]
var all_help_buttons = [
	["Gravity",
	"Gravity Functions.",
	["invert_gravity_room()",
	"invert_gravity_player()"]],
	["Moving Crate",
	"Movement Functions. Parameter: integer",
	["move_crate_left()",
	"move_crate_right()",
	"move_crate_forward()",
	"move_crate_backward()"]],
	["Fire Cannon",
	"Fire the cannon. Parameter: integer",
	["fire_cannon()"]],
	["Light Switch",
	"Turn on a light. Parameter: integer (1-4)",
	["light_switch()"]],
	["Angle Cannon",
	"Angle the cannon. Parameter: integer",
	["angle_cannon()"]]
	]

func _ready():
	set_process(true)

func _process(delta):
	# Countdown for activation cooldown
	if activation_cd > 0:
		activation_cd -= delta

# Gets all help buttons
func get_help_buttons():
	return all_help_buttons

# Function called for executing code
func execute_code():
	if activation_cd <= 0:
		# Call execute_code_group when cooldown is over
		get_tree().call_group(0, "execute_code_group", "execute_code")
		activation_cd = 1.5

# Takes an array of codelines and returns an executable string
func make_executable(eval_array):
	var eval_str = "" # the string to be returned
	
	make_func_names(eval_array) # find all functions
	
	var non_empty_lines = 0
	for line in eval_array:
		# if a line is not empty add to counter
		if line != "":
			non_empty_lines += 1
		eval_str += match_code(line) # matches code and modifies with paths and yields
	if non_empty_lines == 0:
		# if all lines were empty add pass to not crash
		eval_str += "pass"
		get_node("/root/logger").log_debug("Empty code exchanged with pass for execution")
	
	eval_str = make_function(eval_str) # put all code in functions
	return eval_str

# Checks an array of codelines for errors (matching only)
func get_error_information(eval_array):
	var res = "Unrecognized code on line(s) \n"
	
	var line_number = 1 # counter for which line we are checking
	var errors = 0
	make_func_names(eval_array)
	for line in eval_array:
		if !match_code(line, true):
			# If code was not matched add the line number to error message
			res += str(line_number) + ", "
			errors += 1
		line_number += 1
	res = res.substr(0, res.length() - 2) # remove last comma and space
	if errors == 0:
		res = "No errors found"
	return res

# Extract function names for checking function calls
func make_func_names(eval_array):
	func_names = []
	for s in eval_array:
		if s.match("*func*(*):*"): # matches function definition
			var start = s.find("func") + 5 # start of function name
			var end = s.find("(") - 1 # end of function name
			func_names.append(s.substr(start, end-start + 1)) # append string of function name

# Matches custom functions for a codeline
func match_custom_func(line, tab):
	var str_append = ""
	
	for custom_func in custom_functions: # for each custom function
		for str_match in custom_func[MATCH_NAME]: # for all possible matchings
			if line.match(str_match):
				# if a match is found replace for pathing and add a yield
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
	
	var str_custom_func = match_custom_func(line, tab) # match custom functions first
	if str_custom_func != "":
		res += str_custom_func
	elif line.match("*var*"):
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
	elif line.match("*func*(*):*"):
		res += line + "\n"
	elif line.match("*return*:*"):
		res += line + "\n"
	elif line.match("*(*)*"): # function call
		var found = false
		for f in func_names: # try matching with known functions first
			if line.match("*%s(*)*" % f):
				res += line + "\n"
				found = true
		if !found: # if not found yet, let it be but return as error
			res += line + "\n"
			if error_check:
				return false
	elif line == "": # remove empty lines
		pass
	elif line.match("*#*"): # comments
		res += line + "\n"
	elif line.match("*=*"): # assign
		res += line + "\n"
	else:
		res += line + "\n"
		if error_check:
			return false
	if error_check:
		return true
	return res

# Makes functions outside of the main script function eval()
func make_function(input):
	# add signals to avoid race conditions
	var signals = ""
	for func_name in func_names:
		signals += "signal %s_finished" % func_name + "\n"
	
	var eval = "func eval(): \n" # our evaluation function
	var functions = "" # string for saving the players functions
	var i = 0
	var input_array = input.split("\n", false) # dont allow empty
	
	var func_indent = -1
	var line
	var f_name = ""
	var has_return = false
	var func_names_return = []
	
	while i < input_array.size():
		line = input_array[i]
		
		if line.find("func") > -1:
			has_return = false
			# If a function is found save its indentation
			for func_name in func_names:
				if line.find(func_name) > -1:
					f_name = func_name
			func_indent = leading_spaces(line).length()
			functions +=  line + "\n"
			i +=1
		elif func_indent > -1 and func_indent < leading_spaces(line).length():
			# If function indentation is 0 or more, and less than current line
			# Add code to the function
			
			functions +=  line + "\n"
			
			var check_next
			
			if line.find("return") > -1:
				has_return = true
				func_names_return.append(f_name)
			
			
			if i+1 < input_array.size():
				check_next = input_array[i+1]
			if check_next != null and func_indent > -1 and (
			func_indent >= leading_spaces(check_next).length()) and !has_return:
				functions += leading_spaces(line) + "emit_signal(\"%s_finished\")" % f_name + "\n"
			
			i +=1
		else: # all other code goes into the eval function
			eval += "\t" + line + "\n"
			
			# add yield for functions
			for f in func_names:
				if line.match("*%s(*)*" % f) and !func_names_return.has(f):
					eval += "\t" + leading_spaces(line) + "yield(self, \"%s_finished\")" % f + "\n" # yield for function
			
			i += 1
			func_indent = -1
	var res = signals + eval + " \n" + functions
	return res

# Get the leading spaces and tabs
func leading_spaces(line):
	var spaces = ""
	var i = 0
	while (line != "" and i < line.length()) and (line[i] == " " or line[i] == "\t"):
		spaces += line[i]
		i += 1
	return spaces
