# Script for the Cannon
extends Spatial

var notify = false
signal finished

const rot_vec = Vector3(1, 0, 0)
var rot_target = 0
var rot_cur = 0

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if rot_target != null and abs(rot_target - rot_cur) > 1:
		var deg = -delta
		if rot_target - rot_cur > 0:
			deg = delta
		deg *= 15
		rot_cur += deg
		rotate(rot_vec, deg2rad(deg))
	elif notify:
		notify = false
		emit_signal("finished")

func _rotate(angle):
	rot_target += angle
	notify = true

func fire_sound():
	get_node("SpatialSamplePlayer").play("cannon2")