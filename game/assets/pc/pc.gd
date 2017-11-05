#
# PC Script
# Only here to get the PC Screen instance without using paths everywhere
#
extends StaticBody

func _ready():
	pass

func get_screen():
	return get_node("PCScreen")

func is_pc(node):
	var node_id = node.get_instance_ID()
	if (get_node("PC/Screen/col").get_instance_ID() == node_id) or (
	get_node("PC/PC/col").get_instance_ID() == node_id) or (
	get_node("PC/Keyboard/col").get_instance_ID() == node_id):
		return true
	return false