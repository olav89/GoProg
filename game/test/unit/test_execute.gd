extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level1.tscn").instance()
var execute

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

# Extracting function names from code array
func test_make_func_names():
	var code = ["func testA():", "print(\"this is not a function\")",
		"func wrong", "func testingB():"]
	execute.make_func_names(code)
	var expected = ["testA", "testingB"]
	assert_eq(execute.func_names, expected, "test_make_func_names")

# Test that make_function separates code correctly
func test_make_simple_function():
	var input = """
	func test():
		print(2)
	test()"""
	
	# Expected behavior is to make two functions test() and eval()
	# eval() contains all code that is not inside the test() function
	
	var eval_str = execute.make_function(input)
	assert_true(eval_str.match("*func eval():*test()*func test():*print(2)*"),
	"test_make_simple_function")

# Test that common code is recognized
func test_match_misc_identifiers():
	assert_true(execute.match_code("var a = 2", true), "var")
	assert_true(execute.match_code("for i in range(20):", true), "for")
	assert_true(execute.match_code("while a < 2:", true), "while")
	assert_true(execute.match_code("if a != b:", true), "if")
	assert_true(execute.match_code("elif a == b:", true), "elif")
	assert_true(execute.match_code("else:", true), "else")
	assert_true(execute.match_code("func test():", true), "func")

func test_leading_spaces():
	assert_eq(execute.leading_spaces("  twospaces"), "  ", "two spaces")
	assert_eq(execute.leading_spaces("\ttest"), "\t", "one tab")
	assert_eq(execute.leading_spaces("\t  test"), "\t  ", "one tab two spaces")
	assert_eq(execute.leading_spaces("  \ttest"), "  \t", "two spaces one tab")

# Test that all crate functions are recognized
func test_crate_functions_recognized():
	assert_true(execute.match_code("move_crate_left()", true),
	"move crate left")
	assert_true(execute.match_code("move_crate_left(2)", true),
	"move crate left 2")
	assert_true(execute.match_code("move_crate_right()", true),
	"move crate right")
	assert_true(execute.match_code("move_crate_right(2)", true),
	"move crate right 2")
	assert_true(execute.match_code("move_crate_forward()", true),
	"move crate forward")
	assert_true(execute.match_code("move_crate_forward(2)", true),
	"move crate forward 2")
	assert_true(execute.match_code("move_crate_backward()", true),
	"move crate backward")
	assert_true(execute.match_code("move_crate_backward(2)", true),
	"move crate backward 2")

# Test that all gravity functions are recognized
func test_gravity_functions_recognized():
	assert_true(execute.match_code("invert_gravity_room()", true),
	"invert gravity room")
	assert_true(execute.match_code("invert_gravity_player()", true),
	"invert gravity player")

