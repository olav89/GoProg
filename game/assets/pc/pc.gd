#
# PC Script
# Only here to get the PC Screen instance without using paths everywhere
#
extends StaticBody

func _ready():
	pass

func get_screen():
	return get_node("PCScreen")