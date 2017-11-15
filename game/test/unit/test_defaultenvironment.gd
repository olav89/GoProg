extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level1.tscn").instance()
var player
var pc

func setup():
	gut.p("ran setup", 2)
	
func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)
	get_tree().get_root().add_child(level)
	player = level.get_node(level.PATH_PLAYER)
	player.setup(level, "Testing")
	pc = level.get_node(level.PATHS_PC[0])
	player.pc_node = pc
	get_node("/root/logger").set_print(false)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func set_text(s):
	pc.get_screen().set_editor_text(s)

# Test that all crate functions are recognized
func test_crate_functions_recognized():
	assert_true(level.add_path_and_yield("move_crate_left()", true),
	"move crate left")
	assert_true(level.add_path_and_yield("move_crate_left(2)", true),
	"move crate left 2")
	assert_true(level.add_path_and_yield("move_crate_right()", true),
	"move crate right")
	assert_true(level.add_path_and_yield("move_crate_right(2)", true),
	"move crate right 2")
	assert_true(level.add_path_and_yield("move_crate_forward()", true),
	"move crate forward")
	assert_true(level.add_path_and_yield("move_crate_forward(2)", true),
	"move crate forward 2")
	assert_true(level.add_path_and_yield("move_crate_backward()", true),
	"move crate backward")
	assert_true(level.add_path_and_yield("move_crate_backward(2)", true),
	"move crate backward 2")

# Test that all gravity functions are recognized
func test_gravity_functions_recognized():
	assert_true(level.add_path_and_yield("invert_gravity_room()", true),
	"invert gravity room")
	assert_true(level.add_path_and_yield("invert_gravity_player()", true),
	"invert gravity player")

# Test that make_function separates code correctly
func test_make_simple_function():
	var input = """
	func test():
		print(2)
	test()"""
	
	var eval_str = level.make_function(input)
	assert_true(eval_str.match("*func eval():*test()*func test():*print(2)*"))