extends RigidBody

var target_trans
var cur_trans
var notify = false

func _ready():
	set_fixed_process(true)

func set_target(target):
	cur_trans = Vector3(0,0,0)
	target_trans = target
	notify = true

func _fixed_process(delta):
	if target_trans != null and cur_trans.distance_to(target_trans) > 0.05:
		var x = target_trans.x / 50
		var z = target_trans.z / 50
		cur_trans.x += x
		cur_trans.z += z
		translate(Vector3(x,0,z))
	elif notify:
		get_tree().call_group(0, "execute_code_group", "queue_done")
		notify = false


func player_interact():
	pass