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

# Parse constants
const OK = 0
const ERR_PARSE = 43

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
]
]

# All help buttons
# Title, Description, [button texts]
var all_help_buttons = [
	["Gravity",
	"Gravity Functions:",
	["invert_gravity_room()",
	"invert_gravity_player()"]],
	["Moving Crate",
	"Movement Functions: (d = distance)",
	["move_crate_left(d)",
	"move_crate_right(d)",
	"move_crate_forward(d)",
	"move_crate_backward(d)"]],
	["Fire Cannon",
	"Fire the cannon: (i = bullets)",
	["fire_cannon(i)"]],
	["Light Switch",
	"Turn on a light: (i = light number)",
	["light_switch(i)"]]
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
		if line != "":
			non_empty_lines += 1
		
		# match with custom functions to add yields and paths
		# if not matched with custom function add the line
		var str_custom_func = match_custom_func(line, leading_spaces(line))
		if str_custom_func != "":
			eval_str += str_custom_func
		else:
			eval_str += line + "\n"
	if non_empty_lines == 0:
		# if all lines were empty add pass to not crash
		eval_str += "pass"
		get_node("/root/logger").log_debug("Empty code exchanged with pass for execution")
	
	eval_str = make_function(eval_str) # put all code in functions
	
	return eval_str

# Parses the script
func get_error_information(eval_str):
	var res
	var eval_array = eval_str.split("\n")
	make_func_names(eval_array)
	var script = make_function(eval_str, true) # does not add code besides eval function
	
	get_node("/root/logger").log_debug("Parsing code: \n" + script)
	var error = parse(script)
	
	if error[0] == OK: # no errors
		res = "Build completed."
	elif error[0] == ERR_PARSE: # parser error
		var err_str = error[1] # error string from parser
		var err_line = error[2] # error line num from parser
		#var err_col = error[3] # not using column
		
		var script_array = script.split("\n") # split script
		var script_line = script_array[err_line - 1] # find the script line that failed the parse
		script_line = script_line.strip_edges() # remove whitespace
		
		var real_line_found = false
		for i in range(eval_array.size()):
			if !real_line_found and eval_array[i].find(script_line) > -1:
				err_line = i + 1 # the original line number
				real_line_found = true
		res = "%s (Line %d)" % [err_str, err_line]
		if !real_line_found:
			get_node("/root/logger").log_error("Parser found error, but error was not found in player code.")
	get_node("/root/logger").log_debug("Build result: \n" + res)
	return res

# Parses a script
# Returns array with error code and information for parse errors
func parse(input):
	var error = []
	var parser = GDParser.new()
	var parse = parser.parse(input, "", false, "", false)
	error.append(parse)
	if parse == ERR_PARSE: # parser error
		error.append(parser.get_error())
		error.append(parser.get_error_line())
		error.append(parser.get_error_column())
	return error

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

# Extract function names for checking function calls
func make_func_names(eval_array):
	func_names = []
	for s in eval_array:
		if s.match("*func*(*):*"): # matches function definition
			var start = s.find("func") + 5 # start of function name
			var end = s.find("(") - 1 # end of function name
			func_names.append(s.substr(start, end-start + 1)) # append string of function name

# Makes functions outside of the main script function eval()
func make_function(input, for_parse=false):
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
			if !for_parse and check_next != null and func_indent > -1 and (
			func_indent >= leading_spaces(check_next).length()) and !has_return:
				functions += leading_spaces(line) + "emit_signal(\"%s_finished\")" % f_name + "\n"
			
			i +=1
		else: # all other code goes into the eval function
			eval += "\t" + line + "\n"
			
			if !for_parse:
				# add yield for functions
				for f in func_names:
					if line.match("*%s(*)*" % f) and !func_names_return.has(f):
						eval += "\t" + leading_spaces(line) + "yield(self, \"%s_finished\")" % f + "\n" # yield for function
			
			i += 1
			func_indent = -1
	var res = ""
	if !for_parse:
		res += signals
	res += eval + " \n" + functions
	return res

# Get the leading spaces and tabs
func leading_spaces(line):
	var spaces = ""
	var i = 0
	while (line != "" and i < line.length()) and (line[i] == " " or line[i] == "\t"):
		spaces += line[i]
		i += 1
	return spaces
