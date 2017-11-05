# Logger

## Setup and access
* *logger.gd* is loaded into the tree by using [AutoLoad](http://docs.godotengine.org/en/stable/learning/step_by_step/singletons_autoload.html)
* Access the logger with `get_node("/root/logger")`.
* The log is saved to *res://log.log*

## Options
* `set_debug(true)` enables the logging of DEBUG information, which by default is disabled
* `set_print(true)` enables logging to be printed to console, which by default is disabled

## Logging functions
All functions can be called by using `get_node("/root/logger").FUNCTION(s)` where *s* is a string and *FUNCTION* is one of the following functions:
* `log_info(s)`
* `log_warning(s)`
* `log_debug(s)`
* `log_error(s)`

## Entering and exiting the tree
As *logger.gd* is loaded into the tree the following code is executed to open the log-file.
```gdscript
file = File.new()
file.open("res://log.log", File.WRITE)
if file != null:
	log_info("Init...")
```

As Godot is shutting down the function *_exit_tree()* is called in all connected nodes, and in *logger.gd* it is implemented to close the log-file.
```gdscript
func _exit_tree():
	log_info("Quit...")
	file.close()
```
