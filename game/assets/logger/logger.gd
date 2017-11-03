#
# Simple logging functionality
# Script is loaded with AutoLoader
#

extends Node

var file
var debug = false
var print_log = false

func _ready():
	file = File.new()
	file.open("res://log.log", File.WRITE)
	if file != null:
		log_info("Init...")
	set_debug(true)
	set_print(true)

func set_debug(enable):
	debug = enable

func set_print(enable):
	print_log = enable

func _exit_tree():
	log_info("Quit...")
	file.close()

func write_to_file(s):
	if file != null:
		file.store_string(s + "\n")
	if print_log:
		print(s)

func get_time_string():
	var time = OS.get_time()
	return str(time.hour) + ":" + str(time.minute) + ":" + str(time.second)
	
func log_info(s):
	write_to_file("INFO:" + s)
func log_warning(s):
	write_to_file("WARNING:" + s)
func log_debug(s):
	if debug:
		write_to_file("DEBUG:" + s)
func log_error(s):
	write_to_file("ERROR:" + s)
