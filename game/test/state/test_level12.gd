extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level12.tscn").instance()

func setup():
	gut.p("ran setup", 2)
	
func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)
	get_tree().get_root().add_child(level)
	#get_node("/root/logger").set_print(false)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_win():
	var code = """set_a(1)
set_b(4)
"""


	level.get_node(level.PATH_PC).get_screen().set_editor_text(code)
	get_node("/root/execute").execute_code()
	yield(yield_for(2), YIELD)
	assert_true(level.is_won())
	var door = level.get_node("defaultenviroment/Door/Door").get_translation()
	var door1 = level.get_node("defaultenviroment/Door1/Door").get_translation()
	assert_eq(door, Vector3(2, 0, 0))
	assert_eq(door1, Vector3(2,0,0))

