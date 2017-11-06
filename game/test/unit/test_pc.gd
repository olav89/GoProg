extends "res://addons/gut/test.gd"

var pc = load("res://assets/pc/pc.tscn").instance()

var testcodes = ["code1", "code2"]

func setup():
	gut.p("ran setup", 2)
	pc.get_node("PCScreen").create_codes(testcodes)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

# get_screen method gets the screen node
func test_get_screen():
	assert_eq(pc.get_node("PCScreen"), pc.get_screen(), "get_screen should provide same node as using path")

# only collision objects should be recognized as the PC
func test_is_pc():
	assert_true(pc.is_pc(pc.get_node("PC/Screen/col")), "Collision with screen")
	assert_true(pc.is_pc(pc.get_node("PC/PC/col")), "Collision with chassis")
	assert_true(pc.is_pc(pc.get_node("PC/Keyboard/col")), "Collision with keyboard")
	assert_false(pc.is_pc(pc), "Collision with PC node")
	assert_false(pc.is_pc(pc.get_screen()), "Collision with PC screen node (2D)")