# PC Script

extends StaticBody

func _ready():
	pass

# Gets the pc screen node
func get_screen():
	return get_node("PCScreen")

# Checks if a collision node is the pc
func is_pc(node):
	var node_id = node.get_instance_ID()
	if (get_node("PC/Screen/col").get_instance_ID() == node_id) or (
	get_node("PC/PC/col").get_instance_ID() == node_id) or (
	get_node("PC/Keyboard/col").get_instance_ID() == node_id):
		return true
	return false