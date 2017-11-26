# Script for a simple projectile

extends RigidBody

func _ready():
	get_node("Timer").set_active(true)

# Shoots the projectile
func _start(vel):
	get_node("Timer").set_wait_time(2) # set timer to 2s
	get_node("Timer").start() # start timer
	set_linear_velocity(vel) # set velocity

# Timeout removes projectile from world
func _on_Timer_timeout():
	queue_free() # remove node
