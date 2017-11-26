# Script for a moveable crate
# NB: When player selects a function that uses set_target() a yield is added
#     This is why a signal is emitted when translation is finished

extends RigidBody

# Translation variables
var target_trans
var cur_trans

# Yield variables
var notify = false
signal finished

func _ready():
	set_fixed_process(true)

# Checks if a node is equal to self
func is_crate(node):
	var node_id = node.get_instance_ID()
	if get_node(".").get_instance_ID() == node_id:
		return true
	return false

# Sets a new target for translation
func set_target(target):
	cur_trans = Vector3(0,0,0)
	target_trans = target
	notify = true

# Fixed Process handles the translation and yielding
func _fixed_process(delta):
	# Translate self until close to target translation
	if target_trans != null and cur_trans.distance_to(target_trans) > 0.05:
		var x = target_trans.x / 50
		var z = target_trans.z / 50
		cur_trans.x += x
		cur_trans.z += z
		translate(Vector3(x,0,z))
	# When close to target translation emit a signal (once) to finish the yield
	elif notify:
		notify = false
		emit_signal("finished")


func player_interact():
	pass