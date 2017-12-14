# Script for a simple projectile

extends RigidBody

func _ready():
	get_node("Timer").set_active(true)

# Shoots the projectile
func _start():
	var exit = get_parent() # the muzzle of the cannon
	var dir = exit.get_node("Dir") # outside muzzle of cannon
	
	# get direction and multiply for speed
	var vel = (dir.get_global_transform().origin - exit.get_global_transform().origin).normalized()
	vel *= 40
	
	get_node("Timer").set_wait_time(2) # set timer to 2s
	get_node("Timer").start() # start timer
	set_linear_velocity(vel) # set velocity
	

# Timeout removes projectile from world
func _on_Timer_timeout():
	queue_free() # remove node
