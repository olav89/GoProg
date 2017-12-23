extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level1.tscn").instance()
var execute
const OK = 0
const ERR_PARSE = 43

func setup():
	gut.p("ran setup", 2)
	
func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)
	get_tree().get_root().add_child(level)
	execute = get_node("/root/execute")
	get_node("/root/logger").set_print(false)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_get_error_information():
	var t1 = execute.get_error_information("""print(1)
if 2.3 print
	print(2)""")
	var t2 = execute.get_error_information("print(1)")
	assert_true(t1.find("Line 2") > -1)
	assert_true(t2.find("Line 1") == -1)

func test_parser_oneliners():
	var func_def = "func test():\n\t"
	assert_eq(execute.parse(func_def + "print(20)")[0], OK) # func calls
	assert_eq(execute.parse(func_def + "var a = 2")[0], OK) # number vars
	assert_eq(execute.parse(func_def + "var b = \"test\"")[0], OK) # string vars
	assert_eq(execute.parse(func_def + "var a = some_func()")[0], OK) # regression
	
	assert_eq(execute.parse(func_def + "var a = some _func()")[0], ERR_PARSE) # wrong space
	assert_eq(execute.parse(func_def + func_def)[0], ERR_PARSE) # func inside func

func test_match_custom_func():
	assert_ne(execute.match_custom_func("invert_gravity_room()"), "")
	assert_ne(execute.match_custom_func("invert_gravity_player()"), "")
	assert_ne(execute.match_custom_func("move_crate_left()"), "")
	assert_ne(execute.match_custom_func("move_crate_right()"), "")
	assert_ne(execute.match_custom_func("move_crate_forward()"), "")
	assert_ne(execute.match_custom_func("move_crate_backward()"), "")
	assert_ne(execute.match_custom_func("light_switch()"), "")
	assert_ne(execute.match_custom_func("fire_cannon()"), "")
	assert_ne(execute.match_custom_func("angle_cannon()"), "")

# Extracting function names from code array
func test_make_func_names():
	var code = ["func testA():", "print(\"this is not a function\")",
		"func wrong", "func testingB():"]
	execute.make_func_names(code)
	var expected = ["testA", "testingB"]
	assert_eq(execute.func_names, expected, "test_make_func_names")

# Test that make_function separates code correctly
func test_make_function_simple():
	var input = """
	func test():
		print(2)
	test()"""
	
	# Expected behavior is to make two functions test() and eval()
	# eval() contains all code that is not inside the test() function
	
	var eval_str = execute.make_function(input)
	assert_true(eval_str.match("*func eval():*test()*func test():*print(2)*"),
	"test_make_simple_function")

func test_make_function_yield():
	execute.func_names = ["test"]
	var input = """func test():
	print()
test()"""
	var res = execute.make_function(input)
	var expected = """signal test_finished
func eval():
	test()
	yield(self, "test_finished")

func test():
	print()
	emit_signal("test_finished")
"""
	assert_eq(res, expected)

func test_make_function_return():
	execute.func_names = ["test"]
	var input = """func test():
	return 2
test()"""
	var res = execute.make_function(input)
	var expected = """signal test_finished
func eval():
	test()

func test():
	return 2
"""
	assert_eq(res, expected)

func test_leading_spaces():
	assert_eq(execute.leading_spaces("  twospaces"), "  ", "two spaces")
	assert_eq(execute.leading_spaces("\ttest"), "\t", "one tab")
	assert_eq(execute.leading_spaces("\t  test"), "\t  ", "one tab two spaces")
	assert_eq(execute.leading_spaces("  \ttest"), "  \t", "two spaces one tab")

