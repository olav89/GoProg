extends "res://addons/gut/test.gd"

var level = load("res://assets/levels/Level13.tscn").instance()

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
	level.get_node("defaultenviroment/Player").translate(Vector3(0,0,-10))
	level.get_node("defaultenviroment").
