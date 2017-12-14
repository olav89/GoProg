# Script for the Cannon
extends Spatial

func _ready():
	pass

func fire_sound():
	get_node("SpatialSamplePlayer").play("cannon")