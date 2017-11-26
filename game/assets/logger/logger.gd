# Simple logging functionality
# Script is loaded with AutoLoader
#

extends Node

# Output file
var file

# Options
var debug = false
var print_log = false

# Opens file
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

# Called when quitting
func _exit_tree():
	log_info("Quit...")
	file.close() # close file

# Writes a string to file
func write_to_file(s):
	if file != null:
		file.store_string(s + "\n")
	if print_log:
		print(s)

# All log functions
# Each adds a tag to input before writing it to file

func log_info(s):
	write_to_file("INFO:" + s)
func log_warning(s):
	write_to_file("WARNING:" + s)
func log_debug(s):
	if debug:
		write_to_file("DEBUG:" + s)
func log_error(s):
	write_to_file("ERROR:" + s)
