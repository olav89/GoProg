extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/var_5.tscn").instance()

func setup():
	gut.p("ran setup", 2)
	
func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)
	get_tree().get_root().add_child(level)
	get_node("/root/logger").set_print(false)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_win():
	var code = """
angle_cannon(10)
fire_cannon()"""
	level.get_node(level.PATH_PC).get_screen().set_editor_text(code)
	get_node("/root/execute").execute_code()
	yield(yield_for(8), YIELD)
	assert_true(level.is_won())
