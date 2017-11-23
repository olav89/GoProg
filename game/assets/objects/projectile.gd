extends RigidBody

func _ready():
	get_node("Timer").set_active(true)

func _start(vel):
	get_node("Timer").set_wait_time(2)
	get_node("Timer").start()
	set_linear_velocity(vel)

func _on_Timer_timeout():
	queue_free()
