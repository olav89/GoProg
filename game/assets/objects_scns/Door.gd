# Script for elevator doors

extends Spatial

func _ready():
	pass

# Opens door, plays animation and sound
func open():
	get_node("AnimationPlayer").play("Open Door")
	get_node("SpatialSamplePlayer").play("ding")
