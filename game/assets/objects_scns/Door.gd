extends Spatial

func _ready():
	pass

func open():
	get_node("AnimationPlayer").play("Open Door")
	get_node("SpatialSamplePlayer").play("ding")
