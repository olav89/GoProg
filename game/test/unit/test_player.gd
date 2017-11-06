extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level1.tscn").instance()
var player

func setup():
	gut.p("ran setup", 2)
	get_tree().get_root().add_child(level)
	player = level.get_node(level.PATH_PLAYER)
	player.setup(level)
	get_node("/root/logger").set_print(false)
	
func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

#
# Treat this as a bug
# Forcing key-press in two ways makes the test pass, otherwise not...
# Tests that pressing victory pad wins the level
func test_victory():
	var pad = level.get_node(level.PATH_PAD)
	player._on_Area_area_enter(pad)
	Input.action_press("interact")
	var e = InputEvent()
	e.set_as_action("interact", true)
	e.type = InputEvent.KEY
	Input.parse_input_event(e)
	
	assert_true(level.is_won(), "After pressing victory pad the level is won")

