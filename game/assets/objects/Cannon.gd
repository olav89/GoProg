# Script for the Cannon
extends Spatial

var notify = false
signal finished

var fire_timer
signal fire_finished

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
	if fire_timer == null:
		fire_timer = Timer.new()
		fire_timer.set_one_shot(true)
		fire_timer.connect("timeout", self, "fire_timeout")
		add_child(fire_timer)
	fire_timer.set_wait_time(1.5)
	fire_timer.start()

func fire_timeout():
	emit_signal("fire_finished")