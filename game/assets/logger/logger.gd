# Simple logging functionality
# Script is loaded with AutoLoader
#

extends Node

# Output file
var file
var fname = "res://log.log"
var mode = File.WRITE

# Buffer
var buffer = [10]
var b_ind = 0

# Options
var debug = false
var print_log = false

# Opens file
func _ready():
	file = File.new()
	file.open(fname, mode)
	if file != null:
		log_info("Init...")
		file.close()
		mode = File.READ_WRITE # append new writes
	set_debug(true)
	set_print(true)

func set_debug(enable):
	debug = enable

func set_print(enable):
	print_log = enable

# Called when quitting
func _exit_tree():
	log_info("Quit...")
	write_buffer_to_file()

# Writes buffer to file
func write_buffer_to_file():
	file.open(fname, mode)
	if file != null:
		file.seek_end()
		for i in range(b_ind):
			file.store_string(buffer[i] + "\n")
		file.close()
	b_ind = 0

# Adds a string to the buffer
func append_buffer(s):
	buffer[b_ind] = s
	b_ind += 1
	if b_ind == buffer.size():
		write_buffer_to_file()
	if print_log:
		print(s)

# All log functions
# Each adds a tag to input

func log_info(s):
	append_buffer("INFO:" + s)
func log_warning(s):
	append_buffer("WARNING:" + s)
func log_debug(s):
	if debug:
		append_buffer("DEBUG:" + s)
func log_error(s):
	append_buffer("ERROR:" + s)
