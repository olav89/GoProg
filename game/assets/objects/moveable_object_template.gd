# Script for moveable RigidBodies

extends RigidBody

# Translation variables
var target_trans
var cur_trans

var speed = 0.1

# Permanent Motion
var permanent_targets
var has_target = false

# Yield variables
var notify = false
signal finished

func _ready():
	set_fixed_process(true)

# Sets a new target for translation
func set_target(target):
	has_target = true
	cur_trans = Vector3(0,0,0)
	target_trans = target
	notify = true

# Fixed Process handles the translation and yielding
func _fixed_process(delta):
	# Translate self until close to target translation
	if target_trans != null and cur_trans.distance_to(target_trans) > 0.05:
		var x = target_trans.x
		var z = target_trans.z
		var move = Vector3(x,0,z).normalized()
		move = move * speed
		cur_trans += move
		translate(move)
	# When close to target translation emit a signal (once) to finish the yield
	elif notify:
		notify = false
		emit_signal("finished")
		has_target = false
	elif !has_target and permanent_targets != null:
		set_permanent_targets(permanent_targets)

func set_permanent_targets(targets):
	permanent_targets = targets
	for target in targets:
		set_target(target)
		yield(self, "finished")