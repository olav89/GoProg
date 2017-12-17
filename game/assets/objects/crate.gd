# Crate script
extends "res://assets/objects/moveable_object_template.gd"

func _ready():
	pass

# Checks if a node is equal to self
func is_crate(node):
	var node_id = node.get_instance_ID()
	if get_node(".").get_instance_ID() == node_id:
		return true
	return false