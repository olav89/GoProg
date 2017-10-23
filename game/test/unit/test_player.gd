extends "res://addons/gut/test.gd"

var player = load("res://assets/player/player.gd").new()

func setup():
	gut.p("ran setup", 2)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_level_not_won():
	assert_false(player.is_level_won, "Level should not be won initially")
